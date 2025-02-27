#include "raylib.h"

#define MAX_OBJECTS 10
#define MAX_LIGHTS  5

typedef struct {
    Vector3 position;
    Color   color;
} Light;

typedef struct {
    Vector3 position;
    Color   color;
} Object;

int main(void) {
    // Initialization
    InitWindow(800, 600, "Raylib Light Shader Example");
    Camera camera     = {0};
    camera.position   = (Vector3){0.0f, 2.0f, 6.0f};
    camera.target     = (Vector3){0.0f, 0.0f, 0.0f};
    camera.up         = (Vector3){0.0f, 1.0f, 0.0f};
    camera.fovy       = 45.0f;
    camera.projection = CAMERA_PERSPECTIVE;

    // Arrays of lights and objects
    Light lights[MAX_LIGHTS] = {
        { {2.0f, 2.0f, 2.0f}, {255, 255, 255, 255}},
        {{-3.0f, 3.0f, 3.0f},     {255, 0, 0, 255}},
    };

    Object objects[MAX_OBJECTS] = {
        {{0.0f, 0.0f, 0.0f}, {255, 128, 80, 255}}, // First object
        {{3.0f, 0.0f, 0.0f},    {0, 255, 0, 255}}  // Second object
    };

    Model  model  = LoadModelFromMesh(GenMeshCube(2.0f, 2.0f, 2.0f));
    Shader shader = LoadShader("light.vs", "light.fs");

    // Get shader locations
    int locLightPos    = GetShaderLocation(shader, "lightPos");
    int locLightColor  = GetShaderLocation(shader, "lightColor");
    int locObjectColor = GetShaderLocation(shader, "objectColor");

    model.materials[0].shader = shader;

    while (!WindowShouldClose()) {
        UpdateCamera(&camera, CAMERA_ORBITAL);

        // Clear the screen
        BeginDrawing();
        ClearBackground(RAYWHITE);

        // Set shader values for lights
        BeginMode3D(camera);

        // Create arrays of light positions and colors to pass to the shader
        Vector3 lightPositions[MAX_LIGHTS];
        Vector3 lightColors[MAX_LIGHTS];
        for (int i = 0; i < MAX_LIGHTS; i++) {
            lightPositions[i] = lights[i].position;
            lightColors[i]
                = (Vector3){(float)lights[i].color.r / 255.0f,
                            (float)lights[i].color.g / 255.0f,
                            (float)lights[i].color.b / 255.0f}; // Normalize color to 0.0 - 1.0
        }

        // Set the light positions and colors in the shader (arrays)
        SetShaderValueV(shader, locLightPos, lightPositions, SHADER_UNIFORM_VEC3, MAX_LIGHTS);
        SetShaderValueV(shader, locLightColor, lightColors, SHADER_UNIFORM_VEC3, MAX_LIGHTS);

        // Iterate over all objects and update shader for each object
        for (int i = 0; i < MAX_OBJECTS; i++) {
            SetShaderValue(
                shader,
                locObjectColor,
                (float *)&objects[i].color,
                SHADER_UNIFORM_VEC3
            );
            DrawModel(model, objects[i].position, 1.0f, WHITE); // Render the object
        }

        EndMode3D();

        DrawText("Lighting with GLSL in Raylib", 10, 10, 20, DARKGRAY);
        EndDrawing();
    }

    // Cleanup
    UnloadShader(shader);
    UnloadModel(model);
    CloseWindow();

    return 0;
}
