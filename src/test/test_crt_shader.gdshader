shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.05;
uniform float distortion_strength : hint_range(0.0, 1.0) = 0.1;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.5;
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.03;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5);
    vec2 offset = uv - center;
    float radius = length(offset);

    // Barrel distortion
    uv = center + offset * (1.0 + distortion_strength * radius * radius);

    // Sample screen texture
    vec3 color = texture(SCREEN_TEXTURE, uv).rgb;

    // Scanlines
    float scanline = sin(uv.y * 240.0 * 3.1415) * scanline_intensity;
    color -= scanline;

    // Vignette
    float vignette = smoothstep(0.8, vignette_strength, radius);
    color *= vignette;

    // Flicker / noise
    float noise = rand(uv + TIME) * noise_intensity;
    color += noise;

    COLOR = vec4(color, 1.0);
}

