const rl = @import("raylib");
const v3 = rl.Vector3;

pub const Light = struct {
    position: v3,
    color: rl.Color,
    shader: rl.Shader,

    loc_lightPos: i32,
    loc_lightColor: i32,
    loc_viewPos: i32,
    loc_mvp: i32,
    loc_model: i32,
    loc_normalMat: i32,

    pub fn init(position: v3, color: rl.Color, shader: rl.Shader) Light {
        return Light{
            .position = position,
            .color = color,
            .shader = shader,

            .loc_lightPos = rl.getShaderLocation(shader, "lightPos"),
            .loc_lightColor = rl.getShaderLocation(shader, "lightColor"),
            .loc_viewPos = rl.getShaderLocation(shader, "viewPos"),
            .loc_mvp = rl.getShaderLocation(shader, "mvp"),
            .loc_model = rl.getShaderLocation(shader, "model"),
            .loc_normalMat = rl.getShaderLocation(shader, "normalMat"),
        };
    }

    pub fn update(self: *Light, camera: rl.Camera3D) void {
        const model = rl.Matrix.identity();
        const mvp = model.multiply(camera.getMatrix());
        const normalMat = model.invert().transpose();
        const camPos = camera.position;
        const lightPos = self.position;
        const lightColor = [_]f32{
            @as(f32, @floatFromInt(self.color.r)) / 255.0,
            @as(f32, @floatFromInt(self.color.g)) / 255.0,
            @as(f32, @floatFromInt(self.color.b)) / 255.0,
        };

        rl.setShaderValueMatrix(self.shader, self.loc_mvp, mvp);
        rl.setShaderValueMatrix(self.shader, self.loc_model, model);
        rl.setShaderValueMatrix(self.shader, self.loc_normalMat, normalMat);
        rl.setShaderValue(self.shader, self.loc_lightPos, &lightPos, rl.ShaderUniformDataType.vec3);
        rl.setShaderValue(self.shader, self.loc_lightColor, &lightColor, rl.ShaderUniformDataType.vec3);
        rl.setShaderValue(self.shader, self.loc_viewPos, &camPos, rl.ShaderUniformDataType.vec3);
    }
};
