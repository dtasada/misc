#version 330

in vec3 vertexPosition;
in vec3 vertexNormal;

uniform mat4 mvp;       // model view projection matrix
uniform mat4 model;     // model matrix
uniform mat4 normalMat; // normal matrix


out vec3 fragPos;
out vec3 fragNormal;

void main() {
    fragPos    = vec3(model * vec4(vertexPosition, 1.0));   // transform position to world space
    fragNormal = normalize(mat3(normalMat) * vertexNormal); // transform normal to world space

    gl_Position = mvp * vec4(vertexPosition, 1.0);
}
