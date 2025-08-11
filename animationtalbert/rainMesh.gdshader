shader_type spatial;
render_mode unshaded;

void fragment() {
    float dist = length(UV - vec2(0.5));
    ALPHA = smoothstep(0.5, 0.2, dist);
    ALBEDO = vec3(0.8, 0.8, 1.0); // Couleur bleu clair de la goutte
}