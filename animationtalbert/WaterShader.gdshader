//shader_type spatial;
////render_mode specular_toon;
//render_mode diffuse_toon;
//uniform float height_scale = 0.5;
//
//uniform sampler2D noise;
//const float calmness = 100.0; // 1 - 100
//const float wave_speed = 0.5;
//uniform float wave_angle = 45;
//uniform float wave_height = 3.0;//In meters
//const float DEG2RAD = 0.0174533; // π / 180
//
//float wave(vec2 position) {
//
	////position += texture(noise, position / calmness).x * 2.0 - 1.0;
	////vec2 wv = 1.0 - abs(sin(position));
	////return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0);
	//position += texture(noise, position / calmness).x * 1.0 - 1.0;
	//vec2 wave_dir = vec2(cos(wave_angle*DEG2RAD), sin(wave_angle*DEG2RAD));
	//float projection = dot(position, wave_dir);
	//float wv = 1.0 - abs(sin(projection));
	////return pow(1.0 - pow(wv, 0.65), 4.0);
	//return wv;
//}
//
//float height(vec2 position, float time) {
	//// Change your MeshInstance3D PlaneMesh to 10 x 10
//
	////float d = wave((position + time) * 0.4) * 0.3;
	//float d = wave((position + time*wave_speed) * 0.4);
	//// Give the user control over how many waves and in what direction
//
	////for(int i = 0; i < num_of_additional_waves_in_x_direction; i++) {
		//////Randomise magic number 0.3 and 0.3 to a range beteen 0.1 and 1
		////d += wave((position + time) * 0.3) * 0.3;
	////}
	////
	////for(int i = 0; i < num_of_additional_waves_in_z_direction; i++) {
		//////Randomise magic number 0.3 and 0.3 to a range beteen 0.1 and 1
		////d += wave((position - time) * 0.3) * 0.3;
	////}
//
	//// Statically create the waves
//
	////d += wave((position - time) * 0.3) * 0.3;
	////d += wave((position + time) * 0.5) * 0.2;
	////d += wave((position - time) * 0.6) * 0.2;
	////d += wave((position + time*wave_speed) * 0.3) * 0.3;
	////d += wave((position + time*wave_speed) * 0.5) * 0.2;
	////d += wave((position + time*wave_speed) * 0.6) * 0.2;
	//return d;
//}
//
//
//void vertex() {
//
	//// Called for every vertex the material is visible on.
//
	////Do I change the below to height(tex_position, TIME); ?
	//// Version - 1
	////tex_position = VERTEX.xz / 5.0 + 0.5;
	////float _height = texture(noise, tex_position).x;
//
	////VERTEX.y += _height * height_scale;
//
//
	//vec2 pos = VERTEX.xz;
	//float k = height(pos, TIME);
//
	//// Version - 2
  	////VERTEX.y = k;
	////VERTEX.y = k * (2.41/3000.0)/0.3;
	////VERTEX.y = k * (2.41 / 3000.0) + (5.89 / 3000.0);
	//VERTEX.y = (k*2.41)/3000.0;
	//NORMAL = normalize(vec3(
		//k - height(pos + vec2(0.1, 0.0), TIME),
		//0.1,
		//k - height(pos + vec2(0.0, 0.1), TIME)
	//));
//
//}
//
//void fragment() {
	//// Called for every pixel the material is visible on.
//
	//float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	////NORMAL_MAP = texture(normalmap, tex_position).xyz;
//
	//RIM = 0.2;
	//METALLIC = 0.0;
	//ROUGHNESS = 0.01 * (1.0 - fresnel);
	//ALBEDO = vec3(0.01, 0.03, 0.1) + (0.1 * fresnel);
//
//}
//
////void light() {
	//// Called for every pixel for every light affecting the material.
	//// Uncomment to replace the default light processing function with this one.
////}```
shader_type spatial;
render_mode diffuse_toon;

uniform sampler2D noise;
const float wave_height = 2.41; // en mètres
uniform float wave_angle = 45.0; // en degrés
const float wave_speed = 0.5;
const float calmness = 100.0;
const float DEG2RAD = 0.0174533;

float wave(vec2 position) {
	position += texture(noise, position / calmness).x * 1.0 - 1.0;
	vec2 wave_dir = vec2(cos(wave_angle * DEG2RAD), sin(wave_angle * DEG2RAD));
	float projection = dot(position, wave_dir);
	float wv = 1.0 - abs(sin(projection));
	return wv;
}

float height(vec2 position, float time) {
	// Superposition de plusieurs vagues
	float h = 0.0;
	h += wave((position + time * wave_speed) * 0.3);
	//h += wave((position - time * wave_speed) * 0.4) * 0.2;
	//h += wave((position + time * wave_speed) * 0.6) * 0.2;
	return h;
}

void vertex() {
	vec2 pos = VERTEX.xz*50.0;
	float k = height(pos, TIME);
	VERTEX.y += (k * wave_height) / 3000.0;

	// Normale approximée
	const float delta = 0.01;
	vec2 dx = vec2(delta, 0.0);
	vec2 dz = vec2(0.0, delta);

	float hL = height(pos - dx, TIME);
	float hR = height(pos + dx, TIME);
	float hD = height(pos - dz, TIME);
	float hU = height(pos + dz, TIME);

	vec3 normal = normalize(vec3(hL - hR, 2.0 * delta, hD - hU));
	NORMAL = normal;
}

void fragment() {
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = vec3(0.01, 0.03, 0.1) + (0.1 * fresnel);
}
