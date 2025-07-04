#version 330

in vec3 fragPos;
in vec3 fragNormal;

out vec4 finalColor;

uniform vec3  lightPos;         // light position in world space
uniform vec3  lightColor;       // light color
uniform vec3  viewPos;          // camera position
uniform vec3  baseColor;        // base material color
uniform float emissiveStrength; // sun glow intensity
uniform bool  shouldGlow;

void main() {
    // normalize vectors
    vec3 norm       = normalize(fragNormal);
    vec3 lightDir   = normalize(lightPos - fragPos);
    vec3 viewDir    = normalize(viewPos - fragPos);
    vec3 reflectDir = reflect(-lightDir, norm);

    // phong lighting
    float ambientStrength = 0.8;
    vec3  ambient         = ambientStrength * lightColor;

    float distance    = length(lightPos - fragPos);
    float attenuation = 1.0 / (1.0 + 0.01 * distance + 0.0001 * distance * distance);

    float diff    = max(dot(norm, lightDir), 0.0);
    vec3  diffuse = diff * lightColor * attenuation;

    float specularStrength = 0.5;
    float shininess        = 32.0;
    float spec             = pow(max(dot(viewDir, reflectDir), 0.0), shininess);
    vec3  specular         = specularStrength * spec * lightColor * attenuation;

    vec3 emissive = shouldGlow ? baseColor * emissiveStrength : vec3(0.0);

    vec3 result = (ambient + diffuse + specular) * baseColor + emissive;
    finalColor  = vec4(result, 1.0);
}
