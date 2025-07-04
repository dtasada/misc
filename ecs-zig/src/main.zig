const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const ecs = @import("ecs.zig");

fn render_entities(state: *ecs.State) !void {
    var archetype_it = state.archetype_map.iterator();
    var i: u32 = 0;
    while (archetype_it.next()) |pair| {
        const entities = pair.value_ptr;
        if (entities.items.len == 0) continue;

        for (entities.items) |entity| {
            var buf: [512]u8 = undefined;
            const height = 64;
            const y = 32 + height * @as(f32, @floatFromInt(i));
            {
                const formatted = try std.fmt.bufPrintZ(&buf, "ecs.Entity: id={}, archetype={}", .{
                    entity.id,
                    entity.get_archetype(),
                });

                const bounds = rl.Rectangle.init(32, y, 512, height);
                _ = rg.textBox(bounds, formatted, 32, false);
            }

            {
                const width = 128;

                var components: std.AutoHashMap(ecs.Component, bool) = try entity.get_components(state);
                defer components.deinit();

                var c_it = components.iterator();
                var j: u32 = 0;
                while (c_it.next()) |component_bool| : (j += 1) {
                    const x = 576 + width * @as(f32, @floatFromInt(j));
                    const bounds = rl.Rectangle.init(x, y, 128, height);

                    const component = component_bool.key_ptr.*;
                    const has_component = component_bool.value_ptr.*;

                    if (has_component) {
                        const formatted = try std.fmt.bufPrintZ(&buf, "Remove {s}", .{@tagName(component)});
                        if (rg.labelButton(bounds, formatted))
                            try entity.remove_component(component, state);
                    } else {
                        const formatted = try std.fmt.bufPrintZ(&buf, "Add {s}", .{@tagName(component)});
                        if (rg.labelButton(bounds, formatted))
                            try entity.add_component(component, state);
                    }
                }
            }
        }

        i += 1;
    }
}

pub fn main() !void {
    const state = try ecs.State.create();
    defer state.destroy();

    rl.initWindow(1920, 1080, "ECS");
    defer rl.closeWindow();

    var e = ecs.Entity.init(state);
    defer e.deinit(state);
    try e.add_component(ecs.Component.Velocity, state);
    try e.add_component(ecs.Component.Position, state);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();

        rl.clearBackground(rl.Color.black);

        try render_entities(state);

        rl.endDrawing();
    }
}
