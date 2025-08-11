shader_type spatial;
render_mode unshaded;
uniform sampler2D Ortho: source_color;
uniform sampler2D NextOrtho: source_color;
uniform sampler2D CurrentMesh;
uniform sampler2D NextMesh;
uniform sampler2D TopoMesh;
uniform sampler2D NextTopo;
uniform sampler2D mask_texture;  // Texture de découpe
uniform bool use_mask;
uniform float blend_factor : hint_range(0.0, 1.0);
uniform int visual_renderer : hint_enum("Comparative", "Heat_Map", "Real_World") = 2;
uniform float height_exageration=1.0;
varying float h;
//const float max_height = 11.676; //Ce max_height à été trouvé en parcourant les hauteurs des fichiers tif
								 //Il sert à replacer les hauteurs entre 0 et 1 afin d'obtenir une palette de couleurs cohérente
const float max_height = 8.0;
//varying float h;
varying float v_height;

const vec3 spectral_colors[11] = vec3[](
    vec3(0.61960784313725492, 0.003921568627450980, 0.25882352941176473),
    vec3(0.83529411764705885, 0.24313725490196078 , 0.30980392156862746),
    vec3(0.95686274509803926, 0.42745098039215684 , 0.2627450980392157 ),
    vec3(0.99215686274509807, 0.68235294117647061 , 0.38039215686274508),
    vec3(0.99607843137254903, 0.8784313725490196  , 0.54509803921568623),
    vec3(1.0                , 1.0                 , 0.74901960784313726),
    vec3(0.90196078431372551, 0.96078431372549022 , 0.59607843137254901),
    vec3(0.6705882352941176 , 0.8666666666666667  , 0.64313725490196083),
    vec3(0.4                , 0.76078431372549016 , 0.6470588235294118 ),
    vec3(0.19607843137254902, 0.53333333333333333 , 0.74117647058823533),
    vec3(0.36862745098039218, 0.30980392156862746 , 0.63529411764705879)
);
const vec3 viridis_colors[11] = vec3[](
    vec3(0.2670, 0.0049, 0.3294),
    vec3(0.2832, 0.1411, 0.4588),
    vec3(0.2545, 0.2650, 0.5308),
    vec3(0.2071, 0.3726, 0.5537),
    vec3(0.1649, 0.4714, 0.5581),
    vec3(0.1280, 0.5670, 0.5517),
    vec3(0.1340, 0.6584, 0.5170),
    vec3(0.2669, 0.7487, 0.4405),
    vec3(0.4785, 0.8212, 0.3181),
    vec3(0.7414, 0.8735, 0.1504),
    vec3(0.9932, 0.9062, 0.1439)
);
void vertex() {
	//VERTEX.y = texture(heightmap, UV).r * 0.025;
	//float h = texture(heightmap, UV).r * 0.025;
	//float h = mix(texture(heightmap,UV).r*0.025,texture(NextHeightmap,UV).r*0.025,blend_factor);
//
    //// Ignore les valeurs aberrantes (> 20 m ici)
    //if (h < -10.0 || h > 20.0) {
        //h = 0.0;
    //}
//
    //VERTEX.y += h;
	float h1 = texture(CurrentMesh, UV).r;
    float h2 = texture(NextMesh, UV).r;
	float h3 = texture(TopoMesh,UV).r;
	float h4 = texture(NextTopo,UV).r;
	float mask = texture(mask_texture, UV).r;
    bool valid_h1 = h1 > -10.0 && h1 < 50.0;
    bool valid_h2 = h2 > -10.0 && h2 < 50.0;
	bool valid_h3 = h3 > -10.0 && h3 < 50.0;
	bool valid_h4 = h4 > -10.0 && h4 < 50.0;

    if (valid_h1 && valid_h2) {
        // Interpolation normale
        h = mix(h1, h2, blend_factor);
    } else if(valid_h1&&!valid_h2){
		h = h1;
	}else if(!valid_h1&&valid_h2){
		h = h2;
	}else if(valid_h3&&valid_h4){
		h = mix(h3,h4,blend_factor);
	}else{
		h = 0.0;
	}
	/*
	Par défaut VERTEX.y = texture(heightmap, UV).r * 0.025;
	0.025 étant défini pour une taille de Mesh de 40, 40 * 0.025 = 1
	Ici la taille de la mesh étant de 3000 pour une réprésentation échelle réelle,
	0.025 * (3000/40) = 1.875 d'où le 1.875 utilisé pour conserver la bonne proportion
	*/
	VERTEX.y += h*1.875*height_exageration;
    //VERTEX.y += h*300.0;
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
	float mask = texture(mask_texture, UV).r;
	if(use_mask){
		if (v_height==0.0){
			//ALPHA = 0.0;
			 discard;
		}
	}
	vec3 final_color;
	if(visual_renderer==0){
		float h0 = texture(CurrentMesh, UV).r;
		float h1 = texture(NextMesh, UV).r;
		bool valid_h0 = h0 > -10.0 && h0 < 20.0;
		bool valid_h1 = h1 > -10.0 && h1 < 20.0;
		if(!valid_h0){
			if(valid_h1){
				h0=h1;
			}else{
				h0=0.0;
			}
		}
		if(!valid_h1){
			if(valid_h0){
				h1=h0;
			}else{
				h1=0.0;
			}
		}
		//h0 = clamp(h0/max_height,0.0,1.0);
		//h1 = clamp(h1/max_height,0.0,1.0);
		h0 = h0/max_height;
		h1 = h1/max_height;
		float diff = h1 - h0;

		float scale = 1.0;
		float enhanced_diff = sign(diff) * pow(abs(diff), 0.5);
		float centered = clamp(enhanced_diff * scale, -1.0, 1.0);
		//float centered = clamp(diff * scale, -1.0, 1.0);
		float t = (centered + 1.0) * 0.5;
		//vec3 col1 = vec3(0.263, 0.576, 0.765); // blue
		//vec3 col2 = vec3(0.573, 0.773, 0.871); // light blue
		//vec3 col3 = vec3(0.97, 0.97, 0.97); // white
		//vec3 col4 = vec3(0.957, 0.647, 0.510); // pink
		//vec3 col5 = vec3(0.84, 0.379, 0.302); // red
		//if (t < 0.25) {
			//final_color = mix(col1, col2, smoothstep(0.0, 0.25, t));
		//} else if (t < 0.5) {
			//final_color = mix(col2, col3, smoothstep(0.25, 0.5, t));
		//} else if (t < 0.75) {
			//final_color = mix(col3, col4, smoothstep(0.5, 0.75, t));
		//} else {
			//final_color = mix(col4, col5, smoothstep(0.75, 1.0, t));
		//}
		
		float scaled_t = t * float(10); // 11 couleurs → 10 intervalles
		int idx = 10-int(floor(scaled_t));
		float local_t = fract(scaled_t);

		vec3 color_a = spectral_colors[idx];
		vec3 color_b = spectral_colors[min(idx + 1, 10)];
		final_color = mix(color_a, color_b, smoothstep(0.0, 1.0, local_t));
	}if(visual_renderer==1){
		float gray_value = clamp(h/max_height,0.0,1.0);
		//float gray_value = mix(texture(CurrentMesh,UV).r,texture(NextMesh,UV).r,blend_factor);
		//Viridis
		//vec3 col1 = vec3(0.267, 0.004, 0.329); // violet
		//vec3 col2 = vec3(0.255, 0.267, 0.529); // mauve
		//vec3 col3 = vec3(0.165, 0.471, 0.557); // cyan
		//vec3 col4 = vec3(0.133, 0.659, 0.518); // vert
		//vec3 col5 = vec3(0.992, 0.906, 0.145); // jaune
		//if (gray_value < 0.25) {
			//final_color = mix(col1, col2, smoothstep(0.0, 0.25, gray_value));
		//} else if (gray_value < 0.5) {
			//final_color = mix(col2, col3, smoothstep(0.25, 0.5, gray_value));
		//} else if (gray_value < 0.75) {
			//final_color = mix(col3, col4, smoothstep(0.5, 0.75, gray_value));
		//} else {
			//final_color = mix(col4, col5, smoothstep(0.75, 1.0, gray_value));
		//}
		float scaled_t = gray_value * float(10);
		int idx = int(floor(scaled_t));
		float local_t = fract(scaled_t);

		vec3 color_a = viridis_colors[idx];
		vec3 color_b = viridis_colors[min(idx + 1, 10)];
		final_color = mix(color_a, color_b, smoothstep(0.0, 1.0, local_t));

	}else if (visual_renderer==2){
		bool mix_ortho = true;
		if(mix_ortho){
			final_color = mix(texture(Ortho,UV).rgb,texture(NextOrtho,UV).rgb,blend_factor);
		}else{
			final_color = texture(Ortho,UV).rgb;
		}
	}
	//ALBEDO = texture(ortho, UV).rgb;
	ALBEDO = final_color;
}