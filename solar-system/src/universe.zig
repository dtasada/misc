const std = @import("std");
const rl = @import("raylib");
const v3 = rl.Vector3;

const Light = @import("lights.zig").Light;

pub const Universe = struct {
    pub const scale: f32 = 1.0 / 1e5;
    pub const gravitationalConstant: f32 = 6.67384e-11 * scale;

    pub const distanceEarthMoon: f32 = 3.844e5 * scale;
    pub const distanceEarthSun: f32 = 1.496e8 * scale;
    pub const massOfEarth: f32 = 5.972e24 * scale;
    pub const massOfMoon: f32 = 7.335e22 * scale;
    pub const massOfSun: f32 = 1.988416e30 * scale;
    pub const radiusOfEarth: f32 = 6.378e3 * scale;
    pub const radiusOfMoon: f32 = 1.7374e3 * scale;
    pub const radiusOfSun: f32 = 6.957e5 * scale;

    pub fn calc_orbit_vel(orbit_radius: f32, orbit_body_mass: f32) f32 {
        return std.math.sqrt(gravitationalConstant * orbit_body_mass / orbit_radius);
    }
};

pub const CelestialBody = struct {
    mass: f32,
    radius: f32,
    position: v3,
    initialVelocity: v3,
    currentVelocity: v3,
    color: rl.Color,
    identifier: []const u8,
    model: rl.Model,
    light_source: ?Light,

    fn init(
        identifier: []const u8,
        position: v3,
        initialVelocity: v3,
        mass: f32,
        radius: f32,
        color: rl.Color,
        shader: rl.Shader,
        model_: ?rl.Model,
        light_color: ?rl.Color,
    ) CelestialBody {
        const model = if (model_) |m| m else rl.loadModelFromMesh(rl.genMeshSphere(radius, 32, 32)) catch {
            @panic("Failed to load model from mesh");
        };
        model.materials[0].shader = shader;

        return CelestialBody{
            .position = position,
            .mass = mass,
            .radius = radius,
            .initialVelocity = initialVelocity,
            .currentVelocity = v3.zero(),
            .color = color,
            .identifier = identifier,
            .model = model,
            .light_source = if (light_color) |lc| Light.init(position, lc, shader) else null,
        };
    }

    pub fn deinit(self: *CelestialBody) void {
        rl.unloadModel(self.model);
    }

    pub fn sun(position: v3, shader: rl.Shader) CelestialBody {
        return CelestialBody.init(
            "Sun",
            position,
            v3.zero(),
            Universe.massOfSun,
            Universe.radiusOfSun,
            rl.Color.yellow,
            shader,
            null,
            rl.Color.white,
        );
    }

    pub fn earth(sun_: CelestialBody, shader: rl.Shader) CelestialBody {
        return CelestialBody.init(
            "Earth",
            sun_.position.add(v3.init(Universe.distanceEarthSun, 0, 0)),
            v3.init(0, 0, Universe.calc_orbit_vel(Universe.distanceEarthSun, Universe.massOfSun)),
            Universe.massOfEarth,
            Universe.radiusOfEarth,
            rl.Color.sky_blue,
            shader,
            null,
            null,
        );
    }

    pub fn moon(earth_: CelestialBody, shader: rl.Shader) CelestialBody {
        return CelestialBody.init(
            "Moon",
            earth_.position.add(v3.init(Universe.distanceEarthMoon, 0, 0)),
            v3.init(0, 0, Universe.calc_orbit_vel(Universe.distanceEarthMoon, Universe.massOfEarth)),
            Universe.massOfMoon,
            Universe.radiusOfMoon,
            rl.Color.dark_gray,
            shader,
            null,
            null,
        );
    }

    pub fn start(self: *CelestialBody) void {
        self.currentVelocity = self.initialVelocity;
    }

    pub fn updateVelocity(self: *CelestialBody, allBodies: std.ArrayList(CelestialBody)) void {
        for (allBodies.items) |*other| {
            if (other != self) {
                const sqrtDistance = self.position.distanceSqr(other.position);
                const forceDirection = other.position.subtract(self.position).normalize();
                const force = forceDirection.scale(Universe.gravitationalConstant * self.mass * other.mass / sqrtDistance);
                const acceleration = force.scale(1 / self.mass);
                self.currentVelocity = self.currentVelocity.add(acceleration.scale(rl.getFrameTime()));
            }
        }
    }

    pub fn updatePosition(self: *CelestialBody) void {
        self.position = self.position.add(self.currentVelocity.scale(rl.getFrameTime()));
    }

    pub fn draw(self: *CelestialBody, shader: rl.Shader, camera: rl.Camera3D) void {
        if (self.light_source) |*light| {
            rl.setShaderValue(shader, rl.getShaderLocation(shader, "shouldGlow"), &@as(f32, 1.0), rl.ShaderUniformDataType.float);
            rl.setShaderValue(shader, rl.getShaderLocation(shader, "emissiveStrength"), &@as(f32, 1.0), rl.ShaderUniformDataType.float);
            light.update(camera);
        } else {
            rl.setShaderValue(shader, rl.getShaderLocation(shader, "emissiveStrength"), &@as(f32, 0.0), rl.ShaderUniformDataType.float);
            rl.setShaderValue(shader, rl.getShaderLocation(shader, "shouldGlow"), &@as(f32, 0.0), rl.ShaderUniformDataType.float);
        }

        const baseColor = [_]f32{
            @as(f32, @floatFromInt(self.color.r)) / 255.0,
            @as(f32, @floatFromInt(self.color.g)) / 255.0,
            @as(f32, @floatFromInt(self.color.b)) / 255.0,
        };
        rl.setShaderValue(shader, rl.getShaderLocation(shader, "baseColor"), &baseColor, rl.ShaderUniformDataType.vec3);
        rl.drawModel(self.model, self.position, 1.0, self.color);
    }
};
