const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const v2 = rl.Vector2;
const v3 = rl.Vector3;

const Light = @import("lights.zig").Light;
const Universe = @import("universe.zig").Universe;
const CelestialBody = @import("universe.zig").CelestialBody;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const alloc = gpa.allocator();

    // Initialize window and OpenGL context
    rl.initWindow(1280, 720, "universe");
    rl.setConfigFlags(rl.ConfigFlags{
        .msaa_4x_hint = true,
        .window_maximized = true,
        .window_resizable = true,
    });
    rl.setTargetFPS(60);
    rl.setExitKey(rl.KeyboardKey.q);

    rl.disableCursor();
    rl.hideCursor();

    // Set up lighting
    const light_shader = try rl.loadShader("./resources/shaders/gpt.vert.glsl", "./resources/shaders/gpt.frag.glsl");

    // Set up game variables
    var allBodies = std.ArrayList(CelestialBody).init(alloc);
    defer allBodies.deinit();

    try allBodies.append(CelestialBody.sun(v3.zero(), light_shader));
    try allBodies.append(CelestialBody.earth(allBodies.getLast(), light_shader));
    try allBodies.append(CelestialBody.moon(allBodies.getLast(), light_shader));

    var camera = rl.Camera3D{
        .position = v3.init(20, 20, 20),
        .target = allBodies.items[0].position,
        .up = v3.init(0, 1, 0),
        .fovy = 90,
        .projection = rl.CameraProjection.perspective,
    };

    var started = false;
    var showVelocity = false;
    var cameraMode = rl.CameraMode.third_person;

    while (!rl.windowShouldClose()) {
        // Pre-draw logic
        if (rl.isKeyDown(rl.KeyboardKey.p)) {
            started = true;
            for (allBodies.items) |*body| body.start();
        }

        if (rl.isKeyDown(rl.KeyboardKey.f)) {
            cameraMode = if (cameraMode == rl.CameraMode.free) rl.CameraMode.third_person else rl.CameraMode.free;
        }

        if (rl.isKeyPressed(rl.KeyboardKey.escape)) {
            if (rl.isCursorHidden()) {
                rl.enableCursor();
                rl.showCursor();
            } else {
                rl.disableCursor();
                rl.hideCursor();
            }
        }

        if (started) {
            for (allBodies.items) |*body| {
                body.updateVelocity(allBodies);
            }
            for (allBodies.items) |*body| {
                body.updatePosition();
            }
        }

        // Start drawing
        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);

        camera.update(cameraMode);
        camera.begin();

        light_shader.activate();

        for (allBodies.items) |*body| {
            body.draw(light_shader, camera);
        }

        camera.end();
        light_shader.deactivate();

        if (rl.isCursorHidden()) {
            rl.drawFPS(10, 10);
            rl.drawText(rl.textFormat("camera pos: %.2f, %.2f, %.2f", .{ camera.position.x, camera.position.y, camera.position.z }), 10, 32, 24, rl.Color.white);
        } else {
            _ = rg.guiCheckBox(rl.Rectangle.init(20, 20, 20, 20), "Show velocity", &showVelocity);
        }

        for (allBodies.items, 0..) |*body, i| {
            const fmt = rl.textFormat("%s: %.2f, %.2f, %.2f", .{
                @as([*c]const u8, @ptrCast(body.identifier)),
                body.position.x,
                body.position.y,
                body.position.z,
            });
            rl.drawText(fmt, 10, @as(i32, @intCast(i + 2)) * 32, 24, rl.Color.white);
        }

        rl.endDrawing();
    }

    rl.unloadShader(light_shader);
    rl.closeWindow();
}
