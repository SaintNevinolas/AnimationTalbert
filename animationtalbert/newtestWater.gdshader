shader_type spatial;
render_mode unshaded;

uniform float wave_height = 3.0; // en mètres
const float wave_length = 1.0; // en mètres
const float wave_speed = 0.5;  // m/s
uniform float wave_angle = 45.0; // en degrés
const float DEG2RAD = 0.0174533;

void vertex() {
	// Position du vertex
	//vec2 pos = VERTEX.xz;
	vec2 pos = NODE_POSITION_WORLD.xz;
	// Direction des vagues
	vec2 dir = vec2(cos(wave_angle * DEG2RAD), sin(wave_angle * DEG2RAD));

	// Phase animée
	float phase = dot(pos, dir) / wave_length + TIME * wave_speed;

	// Hauteur normalisée [-1, 1]
	float k = sin(phase);

	// Application : on veut que k = 1 donne +wave_height, donc :
	// Le plan est positionné à la base (niveau mer) dans la scène
	VERTEX.y += (k * wave_height) / 3000.0;

	// Normale recalculée simplement (approx)
	const float delta = 0.01;
	vec2 dx = vec2(delta, 0.0);
	vec2 dz = vec2(0.0, delta);

	float hL = sin(dot(pos - dx, dir) / wave_length + TIME * wave_speed);
	float hR = sin(dot(pos + dx, dir) / wave_length + TIME * wave_speed);
	float hD = sin(dot(pos - dz, dir) / wave_length + TIME * wave_speed);
	float hU = sin(dot(pos + dz, dir) / wave_length + TIME * wave_speed);

	vec3 normal = normalize(vec3((hL - hR), 2.0 * delta, (hD - hU)));
	NORMAL = normal;
}

void fragment() {
	ALBEDO = vec3(0.05, 0.1, 0.2); // couleur bleutée simple
}
