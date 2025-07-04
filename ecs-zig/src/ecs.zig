const std = @import("std");

const Bitmask = u64;
const BitOne = @as(Bitmask, 1);

pub const State = struct {
    const Self = @This();

    entity_count: u32,
    gpa: std.heap.GeneralPurposeAllocator(.{}),
    alloc: std.mem.Allocator,
    archetype_map: std.AutoHashMap(Archetype, std.ArrayList(*Entity)),

    pub fn create() !*Self {
        var page_allocator = std.heap.page_allocator;
        const state_ptr = try page_allocator.create(Self);

        state_ptr.entity_count = 0;
        state_ptr.gpa = std.heap.GeneralPurposeAllocator(.{}){};
        state_ptr.alloc = state_ptr.gpa.allocator();
        state_ptr.archetype_map = std.AutoHashMap(Archetype, std.ArrayList(*Entity)).init(state_ptr.alloc);

        return state_ptr;
    }

    pub fn destroy(self: *Self) void {
        {
            var iterator = self.archetype_map.iterator();
            while (iterator.next()) |entry|
                entry.value_ptr.deinit();
        }

        self.archetype_map.deinit();
        _ = self.gpa.deinit();

        var page_allocator = std.heap.page_allocator;
        page_allocator.destroy(self);
    }

    pub fn print_archetypes(self: Self) void {
        var it = self.archetype_map.iterator();
        std.debug.print("{{\n", .{});
        while (it.next()) |entry| {
            std.debug.print("  {}: [", .{entry.key_ptr.*});
            for (entry.value_ptr.items, 0..) |item, i| {
                if (i > 0) std.debug.print(", ", .{});
                std.debug.print("{}", .{item});
            }
            std.debug.print("]\n", .{});
        }
        std.debug.print("}}\n", .{});
    }
};

const Archetype = struct {
    const Self = @This();

    components: Bitmask,

    pub fn has_component(self: Self, c: Component) bool {
        return (self.components & (BitOne << @intFromEnum(c))) != 0;
    }

    pub fn init(components: Bitmask) Self {
        return .{
            .components = components,
        };
    }
};

const ComponentType = struct { id: u6 };
pub const Component = enum(u6) { // max of 2^6=64 components
    Position,
    Velocity,
    Size,

    pub fn init(c: Component) type {
        return switch (c) {
            .Position => struct {
                id: @intFromEnum(c),
                x: f32,
                y: f32,
                pub fn move() void {}
            },
            .Velocity => struct {
                id: @intFromEnum(c),
                dx: f32,
                dy: f32,
                pub fn fast() void {}
            },
            .Size => struct {
                id: @intFromEnum(c),
                w: f32,
                h: f32,
                pub fn grow() void {}
            },
        };
    }

    const count = @typeInfo(Component).@"enum".fields.len;
};

pub const Entity = struct {
    const Self = @This();

    id: u32,
    components: Bitmask,

    pub fn init(state: *State) Self {
        state.entity_count += 1;
        return Self{
            .id = state.entity_count,
            .components = 0,
        };
    }

    pub fn deinit(_: *Self, state: *State) void {
        state.entity_count -= 1;
    }

    pub fn add_component(self: *Self, c: Component, state: *State) !void {
        self.components |= BitOne << @intFromEnum(c);
        try self.refresh_maps(state);
    }

    pub fn remove_component(self: *Self, c: Component, state: *State) !void {
        self.components &= ~(BitOne << @intFromEnum(c));
        try self.refresh_maps(state);
    }

    pub fn refresh_maps(self: *Self, state: *State) !void {
        // Check if archetype already exists in state.archetype_map, if not create it
        const archetype_key = try state.archetype_map.getOrPut(self.get_archetype());
        if (!archetype_key.found_existing)
            archetype_key.value_ptr.* = std.ArrayList(*Entity).init(state.alloc);

        // Refresh the map
        var it = state.archetype_map.iterator();
        while (it.next()) |pair| {
            const archetype_ptr = pair.key_ptr;

            var list_ptr = pair.value_ptr;
            var list_contains_self = false;
            for (list_ptr.items, 0..) |entity_ptr, i| {
                if (entity_ptr == self) {
                    list_contains_self = true;
                    if (archetype_ptr.components != self.get_archetype().components)
                        _ = list_ptr.orderedRemove(i);
                }
            }

            if (!list_contains_self and archetype_ptr.components == self.get_archetype().components)
                try list_ptr.append(self);
        }
    }

    pub fn has_component(self: Self, c: Component) bool {
        return (self.components & (BitOne << @intFromEnum(c))) != 0;
    }

    pub fn get_components(self: Self, state: *State) !std.AutoHashMap(Component, bool) {
        var result = std.AutoHashMap(Component, bool).init(state.alloc);

        inline for (@typeInfo(Component).@"enum".fields) |field|
            try result.put(
                @enumFromInt(field.value),
                ((self.components & (BitOne << @as(Bitmask, field.value))) != 0),
            );

        return result;
    }

    pub fn get_archetype(self: Self) Archetype {
        return Archetype.init(self.components);
    }
};
