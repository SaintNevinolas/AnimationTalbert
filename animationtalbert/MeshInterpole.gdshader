shader_type spatial;
render_mode unshaded;
uniform sampler2D CurrentMesh;
uniform sampler2D NextMesh;
uniform sampler2D mask_texture;  // Texture de découpe
uniform bool use_mask;
uniform bool use_height_diff=false;
uniform float blend_factor : hint_range(0.0, 1.0);
varying float v_height;

void vertex() {
	// Called for every vertex the material is visible on.
	vec2 uv = UV;
	float final_height = mix(texture(CurrentMesh,uv).r,texture(NextMesh,uv).r,blend_factor);
	float mask = texture(mask_texture, uv).r;
	//VERTEX.y += final_height;
	VERTEX.y += final_height*0.1;
	if(use_mask){
		if (mask > 0.1) {
	        //VERTEX.y += final_height * 0.1;  // Extrusion dans la direction Y
			v_height = VERTEX.y;
	    } else {
	        VERTEX.y = 0.0; // Maintenir la position du sommet à zéro dans les zones masquées
			v_height = 0.0;
	    }
	}
}

void fragment() {
	// Called for every pixel the material is visible on.
	float mask = texture(mask_texture, UV).r;
	if(use_mask){
		if (v_height==0.0){
			//ALPHA = 0.0;
			 discard;
		}
	}
	vec3 final_color;
	if(!use_height_diff){
		float gray_value = mix(texture(CurrentMesh,UV).r,texture(NextMesh,UV).r,blend_factor);
		//ALBEDO = vec3(gray_value)*0.5;
		//vec3 low_color = vec3(0.0,0.2,0.4);
		//vec3 mid_color = vec3(0.6,0.5,0.3);
		//vec3 high_color = vec3(0.2,0.2,0.2);
		//vec3 mountain = vec3(0.3,0.2,0.1);
		//vec3 final_color = mix(low_color,mid_color,smoothstep(0,0.2,gray_value));
		//final_color = mix(final_color,high_color,smoothstep(0.2,0.5,gray_value));
		//final_color = mix(final_color,mountain,smoothstep(0.5,1.0,gray_value));

		//vec3 col1 = vec3(0.22, 0.29, 0.75); // blue
		//vec3 col2 = vec3(0.40, 0.64, 0.85); // light blue
		//vec3 col3 = vec3(0.97, 0.97, 0.97); // white
		//vec3 col4 = vec3(0.98, 0.60, 0.61); // pink
		//vec3 col5 = vec3(0.84, 0.19, 0.15); // red
		//Viridis
		vec3 col1 = vec3(0.267, 0.004, 0.329); // violet
		vec3 col2 = vec3(0.255, 0.267, 0.529); // mauve
		vec3 col3 = vec3(0.165, 0.471, 0.557); // cyan
		vec3 col4 = vec3(0.133, 0.659, 0.518); // vert
		vec3 col5 = vec3(0.992, 0.906, 0.145); // jaune
		if (gray_value < 0.25) {
			final_color = mix(col1, col2, smoothstep(0.0, 0.25, gray_value));
		} else if (gray_value < 0.5) {
			final_color = mix(col2, col3, smoothstep(0.25, 0.5, gray_value));
		} else if (gray_value < 0.75) {
			final_color = mix(col3, col4, smoothstep(0.5, 0.75, gray_value));
		} else {
			final_color = mix(col4, col5, smoothstep(0.75, 1.0, gray_value));
		}
	}else{
		float h0 = texture(CurrentMesh, UV).r;
		float h1 = texture(NextMesh, UV).r;
		//float diff = h1 - h0;
		//
		//vec3 up_color   = vec3(0.84, 0.19, 0.15); // rouge (plus haut)
		//vec3 down_color = vec3(0.22, 0.29, 0.75); // bleu (plus bas)
		//vec3 neutral    = vec3(0.97, 0.97, 0.97); // blanc
//
		//if (diff > 0.0) {
			//final_color = mix(neutral, up_color, smoothstep(0.0, 1.0, diff));
		//} else {
			//final_color = mix(neutral, down_color, smoothstep(0.0, 1.0, -diff));
		//}
		float diff = h1 - h0;

		float scale = 3.0;
		float centered = clamp(diff * scale, -1.0, 1.0);
		float t = (centered + 1.0) * 0.5;

		//vec3 col1 = vec3(0.22, 0.29, 0.75); // blue
		//vec3 col2 = vec3(0.40, 0.64, 0.85); // light blue
		//vec3 col3 = vec3(0.97, 0.97, 0.97); // white
		//vec3 col4 = vec3(0.98, 0.60, 0.61); // pink
		//vec3 col5 = vec3(0.84, 0.19, 0.15); // red
		vec3 col1 = vec3(0.263, 0.576, 0.765); // blue
		vec3 col2 = vec3(0.573, 0.773, 0.871); // light blue
		vec3 col3 = vec3(0.97, 0.97, 0.97); // white
		vec3 col4 = vec3(0.957, 0.647, 0.510); // pink
		vec3 col5 = vec3(0.84, 0.379, 0.302); // red
		if (t < 0.25) {
			final_color = mix(col1, col2, smoothstep(0.0, 0.25, t));
		} else if (t < 0.5) {
			final_color = mix(col2, col3, smoothstep(0.25, 0.5, t));
		} else if (t < 0.75) {
			final_color = mix(col3, col4, smoothstep(0.5, 0.75, t));
		} else {
			final_color = mix(col4, col5, smoothstep(0.75, 1.0, t));
		}
	}
	ALBEDO = final_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
