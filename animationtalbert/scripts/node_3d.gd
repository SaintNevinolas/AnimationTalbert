extends Node3D

@onready var WaterSillon : Node3D = get_node("XROrigin3D/WaterSillon2")
@onready var WaterFaille : Node = get_node("XROrigin3D/WaterFaille2")
@onready var SillonGroup : Node = get_node("XROrigin3D/SillonGroup2")
@onready var FailleGroup : Node = get_node("XROrigin3D/FailleGroup2")
@onready var SillonSize : int = get_node("XROrigin3D/SillonGroup2").get_child_count()
@onready var FailleSize : int = get_node("XROrigin3D/FailleGroup2").get_child_count()
@onready var CameraSillon : Camera3D = get_node("CameraSillon")
@onready var CameraFaille : Camera3D = get_node("CameraFaille")
@onready var TextLabel : Label = get_node("Control/Label")
@onready var XRTextLabel : Label = get_node("SubViewport/Control/Label")
@onready var TimelineSillon : HSlider = get_node("Control/TimelineSliderSillon")
@onready var TimelineFaille : HSlider = get_node("Control/TimelineSliderFaille")
@onready var controller : XRController3D = get_node("XROrigin3D/LeftHand")
@onready var right_controller : XRController3D = get_node("XROrigin3D/RightHand")
@onready var stormParticles : GPUParticles3D = get_node("XROrigin3D/StormParticles")
@onready var cloudParticles : GPUParticles3D = get_node("XROrigin3D/CloudParticles")
@onready var rangeSlider : Control = get_node("Control/RangeSlider")
@onready var viewport_2d :XRToolsViewport2DIn3D= $XROrigin3D/XRUI

var terrain_material : ShaderMaterial
var blend_speed = 1.0
var blend_value = 0.0 
var file_faille_names = []
var file_sillon_names = []
var current_files = []
var is_mesh_sillon : bool = true #True if mesh is on Sillon, False if on Faille
var next_mesh_sillon : int = 1
var next_mesh_faille : int = 1

var Time_since_swap : int = 0
var Current_shown_sillon : int = 0
var Current_shown_faille : int = 0
var is_started : bool = false
var timelineSillonDragged : bool = false

var xr_interface : OpenXRInterface
signal focus_lost
signal focus_gained
#signal focus_recentered
var xr_is_focused : bool = false
var terrainTween : Tween
var weatherTween : Tween
var tidesTween : Tween
var tides_running : bool = false
var playTides : bool = false
var is_paused : bool = false
#var play_texture := preload("res://texture/playButton.png")
#var pause_texture := preload("res://texture/pauseButton.png")
var use_ortho : bool = true
var geodot_mnt = []
var ortho_dic = {}
var topo_dic = {}
var mnt_dic = {}
var ui_root : Control
var visual_renderer : float = 2; #Par défaut vue réelle

@export var maximum_refresh_rate : int = 90
@export var echelle : float = 3000.0 #L'echelle correspond à la taille d'objet créé par Geodot
###ATTENTION En cas de modification de l'echelle, changer aussi la valeur dans le shader
@export var longitude : float = 252340.0
@export var latitude : float = 6882300.0
@export var hauteur_mer : float = 8.20 #hauteur de la mer en mètres
@export var elevation_houle : float = 0.0 # élévation de la houle en mètres
@export var surcote : float = 0.0 # niveau de surcote en mètres
@export var printDEBUG : bool = true;
func _ready() -> void:
	#Récupérer les fichiers .png de la faille et du sillon pour interpolation
	var so :Node3D= get_node("XROrigin3D/SillonOrtho")
	so.scale = Vector3(1/echelle,1/echelle,1/echelle)
	WaterSillon.position.y = (5.89)/echelle
	get_node("XROrigin3D/TestWater").position.y = (5.89)/echelle
	get_node("XROrigin3D/MeshInstance3D2").position = Vector3(get_node("XROrigin3D/MeshInstance3D2").position.x,(8.2)/echelle,get_node("XROrigin3D/MeshInstance3D2").position.z)
	#get_node("XROrigin3D/MeshInstance3D2").position = Vector3(get_node("XROrigin3D/MeshInstance3D2").position.x,9.09/echelle,get_node("XROrigin3D/MeshInstance3D2").position.z)
	#get_node("XROrigin3D/MeshInstance3D2").position = Vector3(get_node("XROrigin3D/MeshInstance3D2").position.x,8.09/echelle,get_node("XROrigin3D/MeshInstance3D2").position.z)
	#get_node("XROrigin3D/MeshInstance3D2").position = Vector3(get_node("XROrigin3D/MeshInstance3D2").position.x,5.89/echelle,get_node("XROrigin3D/MeshInstance3D2").position.z)
	#get_node("XROrigin3D/MeshInstance3D2").position = Vector3(get_node("XROrigin3D/MeshInstance3D2").position.x,4.83/echelle,get_node("XROrigin3D/MeshInstance3D2").position.z)
	#get_node("XROrigin3D/MeshInstance3D2").position = Vector3(get_node("XROrigin3D/MeshInstance3D2").position.x,2.63/echelle,get_node("XROrigin3D/MeshInstance3D2").position.z)
	#get_node("XROrigin3D/MeshInstance3D2").position = Vector3(get_node("XROrigin3D/MeshInstance3D2").position.x,0.58/echelle,get_node("XROrigin3D/MeshInstance3D2").position.z)
	#get_node("XROrigin3D/MeshInstance3D2").position = Vector3(get_node("XROrigin3D/MeshInstance3D2").position.x,-1.42/echelle,get_node("XROrigin3D/MeshInstance3D2").position.z)
	#get_node("XROrigin3D/MeshInstance3D2").position = Vector3(get_node("XROrigin3D/MeshInstance3D2").position.x,-3.82/echelle,get_node("XROrigin3D/MeshInstance3D2").position.z)
	#get_node("XROrigin3D/MeshInstance3D2").position = Vector3(get_node("XROrigin3D/MeshInstance3D2").position.x,-5.03/echelle,get_node("XROrigin3D/MeshInstance3D2").position.z)
	file_faille_names = []
	file_sillon_names = []
	if use_ortho:
		var terrain = $XROrigin3D/SillonOrtho/MeshInstance3D
		terrain_material=terrain.mesh.surface_get_material(0)
		terrain_material.set_shader_parameter("height_exageration",1.0)
		#terrain_material.set_shader_parameter("height_scale",1.0)
		var dir = DirAccess.open("res://geoData/mnt")
		if dir:
			dir.list_dir_begin()
			var file:String
			if printDEBUG: print("Déplcamenet vers user:// de geoData/mnt")
			while true:
				file = dir.get_next()
				if file=="":
					break;
				if printDEBUG:print(file)
				copy_to_user("res://geoData/mnt/"+file)
			dir.list_dir_end()
		dir = DirAccess.open("res://geoData/topoBourg")
		if dir:
			dir.list_dir_begin()
			var file:String
			if printDEBUG: print("Déplcamenet vers user:// de geoData/topoBourg")
			while true:
				file = dir.get_next()
				if file=="":
					break;
				if printDEBUG: print(file)
				copy_to_user("res://geoData/topoBourg/"+file)
			dir.list_dir_end()
		dir = DirAccess.open("res://geoData/ortho")
		if dir:
			dir.list_dir_begin()
			var file:String
			if printDEBUG: print("Déplcamenet vers user:// de geoData/ortho")
			while true:
				file = dir.get_next()
				if file=="":
					break;
				if printDEBUG: print(file)
				copy_to_user("res://geoData/ortho/"+file)
			dir.list_dir_end()
		dir = DirAccess.open("user://geoData/mnt")
		if printDEBUG: print("Open dir : ",dir)
		if dir:
			var file_list =[]
			dir.list_dir_begin()
			var file:String
			var img
			while true:
				file = dir.get_next()
				if file=="":
					break
				file_list.append(file)
			dir.list_dir_end()
			file_list.sort()
			for f in file_list:
				if printDEBUG: print(f)
				if f.ends_with(".tif"):
					var real_path = ProjectSettings.globalize_path("user://geoData/mnt/"+f)
					file_sillon_names.append(real_path)
					@warning_ignore("static_called_on_instance")
					img = Geodot.get_raster_layer(real_path).get_image(
						longitude,
						latitude,
						int(echelle),
						int(echelle),
						GeoImage.BILINEAR
					)
					#print("img ",img)
					geodot_mnt.append(img.get_image_texture())
					mnt_dic.set(f.substr(0,f.length()-4),img.get_image_texture())
			if printDEBUG: print("geodotMNT SIZE ",geodot_mnt.size())
			terrain_material.set_shader_parameter("CurrentMesh",geodot_mnt[0])
			terrain_material.set_shader_parameter("NextMesh",geodot_mnt[next_mesh_sillon])
			#var t1 = Time.get_unix_time_from_system()
			#var mnt_res_mnt = MNTDictionary.new()
			#mnt_res_mnt.textures = mnt_dic
			#ResourceSaver.save(mnt_res_mnt,"res://mnt_cache.tres")
			#var t2 = Time.get_unix_time_from_system()
			#print("save MntCache1 temps : ",t2-t1)
			dir.list_dir_end()
		dir = DirAccess.open("user://geoData/topoBourg")
		if printDEBUG: print("Open dir : ",dir)
		if dir:
			var file_list =[]
			dir.list_dir_begin()
			var file:String
			var img
			while true:
				file = dir.get_next()
				if file=="":
					break
				file_list.append(file)
			dir.list_dir_end()
			file_list.sort()
			for f in file_list:
				if printDEBUG: print(f)
				if f.ends_with(".tif"):
					var real_path = ProjectSettings.globalize_path("user://geoData/topoBourg/"+f)
					@warning_ignore("static_called_on_instance")
					img = Geodot.get_raster_layer(real_path).get_image(
						longitude,
						latitude,
						int(echelle),
						int(echelle),
						GeoImage.BILINEAR
					)
					#print("img ",img)
					topo_dic.set(f,img.get_image_texture())
			terrain_material.set_shader_parameter("TopoMesh",topo_dic[topo_dic.keys()[0]])
			terrain_material.set_shader_parameter("NextTopo",topo_dic[topo_dic.keys()[0]])
			#var t1 = Time.get_unix_time_from_system()
			#var mnt_res_mnt = MNTDictionary.new()
			#mnt_res_mnt.textures = mnt_dic
			#ResourceSaver.save(mnt_res_mnt,"res://mnt_cache.tres")
			#var t2 = Time.get_unix_time_from_system()
			#print("save MntCache1 temps : ",t2-t1)
			dir.list_dir_end()
		dir = DirAccess.open("user://geoData/ortho")
		if dir:
			var file_list = []
			dir.list_dir_begin()
			var file:String
			var img
			while true:
				file = dir.get_next()
				#print("File ",file)
				if file=="":
					break
				file_list.append(file)
				#else:
					#print("Path exists : ",ResourceLoader.exists("user://geoData/ortho/"+file)," ",FileAccess.file_exists("user://geoData/ortho/"+file))
			dir.list_dir_end()
			file_list.sort()
			for f in file_list:
				if f.ends_with(".jpeg"):
					#||file.ends_with(".jpeg.import")
					#print(file)
					var real_path = ProjectSettings.globalize_path("user://geoData/ortho/"+f)
					
					if printDEBUG: print(f," chemin user:// : ",real_path)
					#if tex and tex is Texture2D:
					@warning_ignore("static_called_on_instance")
					img = Geodot.get_raster_layer(real_path).get_image(
						longitude,
						latitude,
						int(echelle),
						int(echelle),
						GeoImage.BILINEAR
					)
					ortho_dic.set(f.substr(0,f.length()-5),img.get_image_texture())
					#else:
						#print("Fail to load texture ",path.get_basename())
			terrain_material.set_shader_parameter("Ortho",ortho_dic[ortho_dic.keys()[0]])
			terrain_material.set_shader_parameter("NextOrtho",ortho_dic[ortho_dic.keys()[0]])
			copy_to_user("res://geoData/masque/masque.tif")
			@warning_ignore("static_called_on_instance")
			img = Geodot.get_raster_layer(ProjectSettings.globalize_path("user://geoData/masque/masque.tif")).get_image(
				longitude,
				latitude,
				int(echelle),
				int(echelle),
				GeoImage.BILINEAR
			)
			terrain_material.set_shader_parameter("mask_texture",img.get_image_texture())
			if printDEBUG:
				print("dic mnt :")
				for key in mnt_dic.keys():
					print(key," ",mnt_dic[key])
				print("Dic orth ")
				for key in ortho_dic.keys():
					print(key," ",ortho_dic[key])
	else:
		var terrain = $XROrigin3D/SillonInterpole/StaticBody3D/MeshInstance3D
		terrain_material=terrain.mesh.surface_get_material(0)
		terrain_material.set_shader_parameter("use_mask",false)
		terrain_material.set_shader_parameter("mask_texture",load("res://maskSillon.png"))
		var dir = DirAccess.open("res://geoData/3DObjects/Sillon")
		if dir:
			dir.list_dir_begin()
			var file
			while true:
				file = dir.get_next()
				if file=="":
					break
				if file.ends_with(".png.import"):
					file_sillon_names.append("res://geoData/3DObjects/Sillon/"+file.replace(".import",""))
				#print(file)
			dir.list_dir_end()
		else:
			print("Impossible d'ouvrir le dossier")
		dir = DirAccess.open("res://geoData/3DObjects/Faille")
		if dir:
			dir.list_dir_begin()
			var file
			while true:
				file = dir.get_next()
				if file=="":
					break
				if file.ends_with(".png.import"):
					file_faille_names.append("res://geoData/3DObjects/Faille/"+file.replace(".import",""))
				#print(file)
			dir.list_dir_end()
		else:
			print("Impossible d'ouvrir le dossier")
			
		#var p : PackedStringArray = DirAccess.get_files_at("geoData/3DObjects/Faille")
		#file_faille_names = []
		#for s in p:
			#if s.ends_with(".png"):
				#file_faille_names.append("geoData/3DObjects/Faille/"+s)
		#p = DirAccess.get_files_at("geoData/3DObjects/Sillon")
		#file_sillon_names = []
		#for s in p:
			#if s.ends_with(".png"):
				#file_sillon_names.append("geoData/3DObjects/Sillon/"+s)
	current_files = file_sillon_names
	SillonSize = file_sillon_names.size()
	#Tout cacher par défaut
	for n:Node in SillonGroup.get_children():
		n.hide()
	for n:Node in FailleGroup.get_children():
		n.hide()
	SillonGroup.get_child(Current_shown_sillon).show()
	FailleGroup.get_child(Current_shown_faille).hide()
	TextLabel.text = SillonGroup.get_child(Current_shown_sillon).name.erase(0,7)
	XRTextLabel.text = SillonGroup.get_child(Current_shown_sillon).name.erase(0,7)
	WaterFaille.hide()
	TimelineFaille.hide()
	#WaterSillon.show()
	#CameraSillon.current = true
	#print(FailleSize)
	#print(SillonSize)
	#XR Code 
	#var JsonFile = FileAccess.open("res://geoData/CoucheDonnees.geojson",FileAccess.READ)
	#if JsonFile:
		#print("JsonFile exists")
		#var FileContent = JsonFile.get_as_text()
		#var parsed = JSON.parse_string(FileContent)
		#if parsed :
			#print(parsed)
			#for feature in parsed["features"]:
				##print(feature)
				#for attr in feature["properties"]:
					#print(attr," ",feature["properties"][attr])
	#else: 
		#print("JsonFile doesnt exists")
	if !ui_root:
		ui_root=get_node("Control")
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR intialized correctly")
		print(xr_interface.get_capabilities())
		
		#if xr_interface.get_capabilities()&XRInterface:
		var vp : Viewport = get_viewport()
		#change viewport to HMD
		vp.use_xr = true
		#turn off vsync
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		#Enable VRS 
		if RenderingServer.get_rendering_device():
			vp.vrs_mode = Viewport.VRS_XR
		elif int(ProjectSettings.get_setting("xr/openxr/foveation_level")) == 0:
			push_warning("OpenXR : Recommend setting foveation level to High in project settings")
		#Connect the OpenXR events
		xr_interface.session_begun.connect(_on_openxr_session_begun)
		xr_interface.session_focussed.connect(_on_openxr_focused_state)
		xr_interface.session_stopping.connect(_on_openxr_stopping)
		xr_interface.session_visible.connect(_on_openxr_visible_state)
		print(controller.tracker)
		print("Profil OpenXR actif :", xr_interface.get_action_sets())
		print("Tracking origin mode:", XRServer.primary_interface.ar_is_anchor_detection_enabled)
		#xr_interface.pose_recentered.connect(_on_openxr_pose_recentered)
		#print(XRServer.find_interface("OpenXR").)
		TimelineSillon = get_node("SubViewport2/Control/TimelineSliderSillon")
		await get_tree().process_frame
		ui_root = viewport_2d.scene_node
		if ui_root:
			print(ui_root.get_node("TimelineSliderSillon"))
			if ui_root.get_node("TimelineSliderSillon"):
				TimelineSillon.hide()
				TimelineSillon = ui_root.get_node("TimelineSliderSillon")
				rangeSlider=ui_root.get_node("RangeSlider")
			#print("UIROOTRANGESLIDER MAX VALUE",ui_root.get_node("RangeSlider").max_value)
			ui_root.connect("timeline_drag_started",Callable(self,"_on_timeline_slider_sillon_drag_started"))
			ui_root.connect("timeline_drag_ended",Callable(self,"_on_timeline_slider_sillon_drag_ended"))
			ui_root.connect("timeline_value_changed",Callable(self,"_on_timeline_slider_sillon_value_changed"))
			ui_root.connect("play_button_toggled",Callable(self,"_on_play_button_toggled"))
			ui_root.connect("check_button_toggled",Callable(self,"_on_check_button_toggled"))
			ui_root.connect("ortho_scale_value_changed",Callable(self,"_on_ortho_scale_value_changed"))
			ui_root.connect("ortho_height_scale_value_changed",Callable(self,"_on_ortho_height_scale_value_changed"))
			ui_root.connect("water_button_toggled",Callable(self,"_on_water_button_toggled"))
			#print(right_controller.get_is_active())
			#if right_controller.get_is_active():
			#viewport_2d.screen_size.x=viewport_2d.screen_size.x/3.0
			#viewport_2d.screen_size.y=viewport_2d.screen_size.y/3.0
			#viewport_2d.get_parent().remove_child(viewport_2d)
			#right_controller.add_child(viewport_2d)
			#viewport_2d.global_transform = Transform3D()
	else:
		print("OpenXR not initialized, check if the headset is connected")
		#get_tree().quit()
		get_viewport().use_xr=false
		CameraSillon.current=true
		get_node("XROrigin3D/LeftHand").hide()
		viewport_2d.hide()
	var menu = ui_root.get_node("Menu")
	#print("Menu :",menu)
	menu.connect("change_view",Callable(self,"_on_change_view_button_pressed"))
	TimelineSillon.show()
	TimelineSillon.step=0.01
	TimelineSillon.max_value = SillonSize-1
	TimelineSillon.tick_count = SillonSize
	#applyWeather(0.0,80)
	#await weatherTween.finished


func _physics_process(delta: float) -> void:
	#print("proc ",TimelineSillon.value," ",blend_value," ",next_mesh_sillon)
	#print(get_node("XROrigin3D/SillonInterpole").scale)
	if terrain_material==null:
		get_tree().quit()
	if !tides_running && playTides:
		applyTides(WaterSillon)
	else:
		if !is_paused:
			if !timelineSillonDragged:
				updateMesh(delta)

#func _process(_delta: float) -> void:
	#if is_started && $AnimationPlayer.is_playing():
		##if CameraSillon.current :
		#var current_time : int = Time.get_ticks_msec()
		#if Current_shown_sillon>=17:
			#if current_time-Time_since_swap>1000:
				#Time_since_swap=current_time
				#if Current_shown_sillon == SillonSize-1 :
					#var child : Node3D = SillonGroup.get_child(Current_shown_sillon)
					#child.hide()
					#child = SillonGroup.get_child(0)
					#child.show()
					#Current_shown_sillon=0
				#else :
					#var child : Node3D = SillonGroup.get_child(Current_shown_sillon)
					#child.hide()
					#child = SillonGroup.get_child(Current_shown_sillon+1)
					#child.show()
					#Current_shown_sillon+=1
				#print(Current_shown_sillon)
				#updateLabel()
		#elif current_time - Time_since_swap>250:
			#Time_since_swap=current_time
			#if Current_shown_sillon == SillonSize-1 :
				#var child : Node3D = SillonGroup.get_child(Current_shown_sillon)
				#child.hide()
				#child = SillonGroup.get_child(0)
				#child.show()
				#Current_shown_sillon=0
			#else :
				#var child : Node3D = SillonGroup.get_child(Current_shown_sillon)
				#child.hide()
				#child = SillonGroup.get_child(Current_shown_sillon+1)
				#child.show()
				#Current_shown_sillon+=1
			#print(Current_shown_sillon)
			#updateLabel()
		##elif CameraFaille.current :
		##	var current_time : int = Time.get_ticks_msec()
		##	if current_time - Time_since_swap>250:
		##		Time_since_swap=current_time
		##		if Current_shown_faille == FailleSize-1 :
		##			var child : Node3D = FailleGroup.get_child(Current_shown_faille)
		##			child.hide()
		##			child = FailleGroup.get_child(0)
		##			child.show()
		##			Current_shown_faille=0
		##		else :
		##			var child : Node3D = FailleGroup.get_child(Current_shown_faille)
		##			child.hide()
		##			child = FailleGroup.get_child(Current_shown_faille+1)
		##			child.show()
		##			Current_shown_faille+=1
		##		print(Current_shown_faille)
		##		updateLabel()
func copy_to_user(file_path: String):
	# On enlève le "res://" pour retrouver le chemin relatif
	var rel_path := file_path.replace("res://", "")
	var dst_path := "user://" + rel_path
	
	# Créer les dossiers intermédiaires dans user://
	var parts := rel_path.get_base_dir().split("/")
	var current := "user://"
	for part in parts:
		current += part + "/"
		if not DirAccess.dir_exists_absolute(current):
			DirAccess.make_dir_absolute(current)
	
	var src_file = FileAccess.open(file_path, FileAccess.READ)
	if src_file:
		var dst_file = FileAccess.open(dst_path, FileAccess.WRITE)
		if dst_file:
			dst_file.store_buffer(src_file.get_buffer(src_file.get_length()))
			dst_file.close()
		src_file.close()
	
	# Retourne le chemin absolu pour Geodot
	return ProjectSettings.globalize_path(dst_path)


func updateLabel(obj:Resource) -> void:
	var date : String
	if !use_ortho:
		date = obj.resource_path.get_file().erase(0,7)
		date =  date.substr(0,date.length()-6)
	else:
		date = mnt_dic.keys()[next_mesh_sillon]
	TextLabel.text = date
	XRTextLabel.text = date
	#TimelineSillon.set_value_no_signal()
#func updateLabel() -> void:
	
	#if CameraSillon.current:
	#TextLabel.text = SillonGroup.get_child(Current_shown_sillon).name.erase(0,7)
	#TimelineSillon.set_value_no_signal(Current_shown_sillon)
#	else:
#		TextLabel.text = FailleGroup.get_child(Current_shown_faille).name.erase(0,7)
#		TimelineFaille.set_value_no_signal(Current_shown_faille)

func updateMesh(delta:float)->void:
	if blend_value<1.0:
		blend_value+=delta*blend_speed
		if blend_value>1.0:
			blend_value=1.0
		terrain_material.set_shader_parameter("blend_factor",blend_value)
		TimelineSillon.set_value_no_signal(next_mesh_sillon-1+blend_value)
	else:
		var next_mesh = loadMesh()
		updateLabel(next_mesh)
		if use_ortho:
			updateOrtho()
		updateTopo()
		terrain_material.set_shader_parameter("CurrentMesh",next_mesh)
		##print("Start from ",next_mesh.resource_path)
		incrementNextMesh()
		blend_value=0.0
		terrain_material.set_shader_parameter("blend_factor",blend_value)
		var next_mesh2 = loadMesh()
		##print("to ",next_mesh2.resource_path)
		terrain_material.set_shader_parameter("NextMesh",next_mesh2)

func loadMesh()-> Resource:
	var mesh
	if use_ortho:
		#print("Change for sillonOrtho")
		mesh = geodot_mnt[next_mesh_sillon]
	else:
		if is_mesh_sillon:
			mesh = load(current_files[next_mesh_sillon])
		else:
			mesh = load(current_files[next_mesh_faille])
	return mesh

func updateOrtho():
	#print("Update Ortho ",mnt_dic.keys()[next_mesh_sillon])
	var Ortho = getOrtho()
	var NextOrthoShader = terrain_material.get_shader_parameter("NextOrtho")
	var OrthoShader = terrain_material.get_shader_parameter("Ortho")
	if NextOrthoShader!=Ortho:
		print("changement")
		terrain_material.set_shader_parameter("NextOrtho",Ortho)
	elif OrthoShader!=NextOrthoShader:
		terrain_material.set_shader_parameter("Ortho",Ortho) 

func updateTopo():
	#print("Update Ortho ",mnt_dic.keys()[next_mesh_sillon])
	var Topo = getTopo()
	var NextTopoShader = terrain_material.get_shader_parameter("NextTopo")
	var TopoShader = terrain_material.get_shader_parameter("TopoMesh")
	if NextTopoShader!=Topo:
		print("changement")
		terrain_material.set_shader_parameter("NextTopo",Topo)
	elif TopoShader!=NextTopoShader:
		terrain_material.set_shader_parameter("TopoMesh",Topo)	
func getOrtho():
	var stop : bool = false
	incrementNextMesh()
	var index = next_mesh_sillon
	unincrementNextMesh()
	var currentMnt :String = mnt_dic.keys()[index]
	print("CURRENT MNT ",currentMnt)
	var Ortho : String
	while !stop:
		currentMnt = mnt_dic.keys()[index]
		for key:String in ortho_dic.keys():
			if key.contains(currentMnt.substr(0,4)):
				print(key," ",mnt_dic.keys()[next_mesh_sillon])
				Ortho = key
				stop = true
		index=index-1
		if index==-1:
			print("pas trouvé")
			stop=true
			Ortho = ortho_dic.keys()[0]
	return ortho_dic[Ortho]

func getTopo():
	var stop : bool = false
	incrementNextMesh()
	var index = next_mesh_sillon
	unincrementNextMesh()
	var currentMnt :String = mnt_dic.keys()[index]
	#print("CURRENT MNT ",currentMnt)
	var Topo : String
	while !stop:
		currentMnt = mnt_dic.keys()[index]
		for key:String in topo_dic.keys():
			if key.contains(currentMnt.substr(0,4)):
				print(key," ",mnt_dic.keys()[next_mesh_sillon])
				Topo = key
				stop = true
		index=index-1
		if index==-1:
			print("pas trouvé")
			stop=true
			Topo = topo_dic.keys()[0]
	return topo_dic[Topo]
func loadMeshLowestHandle()->Resource:
	var mesh
	if rangeSlider.handle1_value<rangeSlider.handle2_value:
		if use_ortho:
			mesh = geodot_mnt[rangeSlider.handle1_value]
		else:
			mesh = load(current_files[rangeSlider.handle1_value])
	else:
		if use_ortho:
			mesh = geodot_mnt[rangeSlider.handle2_value]
		else:
			mesh = load(current_files[rangeSlider.handle2_value])
	return mesh
func loadMeshHighestHandle()->Resource:
	var mesh
	if rangeSlider.handle1_value>rangeSlider.handle2_value:
		if use_ortho:
			mesh = geodot_mnt[rangeSlider.handle1_value]
		else:
			mesh = load(current_files[rangeSlider.handle1_value])
	else:
		if use_ortho:
			mesh = geodot_mnt[rangeSlider.handle2_value]
		else:
			mesh = load(current_files[rangeSlider.handle2_value])
	return mesh
func incrementNextMesh()->void:
	if is_mesh_sillon:
		if next_mesh_sillon==file_sillon_names.size()-1:
			next_mesh_sillon = 0
		else:
			next_mesh_sillon=next_mesh_sillon+1
	else:
		if next_mesh_faille==file_faille_names.size()-1:
			next_mesh_faille=0
		else:
			next_mesh_faille=next_mesh_sillon+1

func unincrementNextMesh()->void:
	if is_mesh_sillon:
		if next_mesh_sillon==0:
			next_mesh_sillon = file_sillon_names.size()-1
		else:
			next_mesh_sillon=next_mesh_sillon-1
	else:
		if next_mesh_faille==0:
			next_mesh_faille=file_faille_names.size()
		else:
			next_mesh_faille=next_mesh_sillon-1

func changeInterpolation()->void:
	is_mesh_sillon=!is_mesh_sillon
	if current_files==file_sillon_names:
		current_files=file_faille_names
		#WaterSillon.position.y = -0.025
	else:
		current_files=file_sillon_names
	TimelineSillon.max_value = current_files.size()
	
#func applyWeather(_windStrength:float,rainAmount:float) -> void:
	#if weatherTween:
		#weatherTween.kill()
	#
	#weatherTween = get_tree().create_tween()
	#weatherTween.tween_property(stormParticles,"amount_ratio",(rainAmount*100)/8000,5)
	#weatherTween.tween_property(cloudParticles,"amount_ratio",(rainAmount*10)/800,5)
	#
#func stopWeather()->void:
	#if weatherTween:
		#weatherTween.kill()
	#weatherTween = get_tree().create_tween()
	#weatherTween.tween_property(stormParticles,"amount_ratio",0,5)
	#weatherTween.tween_property(cloudParticles,"amount_ratio",0,5)

func applyTides(water:Node3D)->void:
	tides_running = true
	var final_pos = get_position_y_for_scale(water.scale.y,ui_root.get_node("OrthoHeightScale").value)
	var twelvth = (final_pos - water.position.y)/12.0
	#print("Déplacement de ",initial_pos," jusqu'à ",final_pos, "douzième : ",twelvth)
	#print(get_position_y_for_scale(1.0))
	#print(get_position_y_for_scale(3000.0))
	#print(get_position_y_for_scale(1500.0))
	#print(get_position_y_for_scale(100.0))
	#print("Montée")
	for i in range(12):
		var value = int(2 - abs(i%6 - 2.5) + 0.5)+1  # Pour obtenir les nombres 1 2 3 3 2 1 = règle des douxièmes
		tidesTween = get_tree().create_tween()
		if i==6:print("Descente")
		if i<6:#Montée de la marée
			tidesTween.tween_property(water,"position",Vector3(water.position.x,
			water.position.y+(value*twelvth),water.position.z),1.2)
		else:#Descente de la marée
			tidesTween.tween_property(water,"position",Vector3(water.position.x,
			water.position.y-(value*twelvth),water.position.z),1.2)
		await tidesTween.finished
	print("water pos : ",water.position)
	tides_running = false
	
##Fonction pour connaître la hauteur à laquelle le plan d'eau sera placée pour une marée haute
func remap(value, in_min, in_max, out_min, out_max)->float:
	return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min)
func get_position_y_for_scale(ObjectScale: float,HeightExageration: float) -> float:
	var out_min = lerp(0.002, 0.04, clamp((HeightExageration - 1.0) / 9.0, 0.0, 1.0))
	return remap(ObjectScale, 1.0, echelle, out_min, 60.0)

func _input(event: InputEvent) -> void:
	#print(event)
	#if event is InputEventJoypadMotion:
	#	print("Axis:", event.axis, " Value:", event.axis_value)
	if event is InputEventKey:
		if event.is_pressed():
			if !is_started :
				if event.keycode == KEY_S :
					changeInterpolation()
					#if CameraSillon.current:
						#is_started = true
						#$AnimationPlayer.play("Sillon")
					#else:
						#is_started = true
						#$AnimationPlayer.play("Faille")
				if event.keycode == KEY_M:
					terrain_material.set_shader_parameter("use_mask",true)
					#var sillonInt = $XROrigin3D/SillonInterpole
					#sillonInt.scale = Vector3(8.0,8.0,8.0)
					#scale_up(sillonInt,8.0)
					#await terrainTween.finished
				if event.keycode == KEY_T:
					playTides = !playTides
				#if event.keycode == KEY_W:
					#applyWeather(0.0,80)
					#await weatherTween.finished
			elif event.keycode == KEY_SPACE && !$AnimationPlayer.is_playing():
				if CameraSillon.current :
					is_started = false
					TimelineFaille.show()
					WaterFaille.show()
					FailleGroup.get_child(Current_shown_faille).show()
					CameraFaille.current = true
					SillonGroup.get_child(Current_shown_sillon).hide()
					WaterSillon.hide()
					TimelineSillon.hide()
					Time_since_swap = Time.get_ticks_msec()
				elif CameraFaille.current :
					is_started = false
					TimelineSillon.show()
					WaterSillon.show()
					SillonGroup.get_child(Current_shown_sillon).show()
					CameraSillon.current = true
					FailleGroup.get_child(Current_shown_faille).hide()
					WaterFaille.hide()
					TimelineFaille.hide()
					Time_since_swap = Time.get_ticks_msec()
				#updateLabel()
		elif event.is_released():
			if event.keycode == KEY_M:
				#var sillonInt = $XROrigin3D/SillonInterpole
				#scale_up(sillonInt,1.0)
				#await terrainTween.finished
				terrain_material.set_shader_parameter("use_mask",false)
			#if event.keycode == KEY_W:
				#stopWeather()
				#await weatherTween.finished

func _on_timeline_slider_sillon_value_changed(value: float) -> void:
	#SillonGroup.get_child(Current_shown_sillon).hide()
	#SillonGroup.get_child(int(value)).show()
	#Current_shown_sillon = int(value)
	#updateLabel()
	#print(value)
	if visual_renderer!=0:
		blend_value=0.0
		terrain_material.set_shader_parameter("blend_factor",blend_value)
		if(int(value)==file_sillon_names.size()):
			value=0.0
		print("Timeline value changed ",next_mesh_sillon," ",file_sillon_names.size())
		next_mesh_sillon=int(value)
		print(value," ",int(value))
		var mesh = loadMesh()
		print("From ",mesh.resource_path.get_file())
		terrain_material.set_shader_parameter("CurrentMesh",mesh)
		updateLabel(mesh)
		if use_ortho:
			updateOrtho()
		updateTopo()
		incrementNextMesh()
		var nextMesh = loadMesh()
		#unincrementNextMesh()
		print("to ",nextMesh.resource_path.get_file())
		terrain_material.set_shader_parameter("NextMesh",nextMesh)


func _on_timeline_slider_faille_value_changed(value: float) -> void:
	FailleGroup.get_child(Current_shown_faille).hide()
	FailleGroup.get_child(int(value)).hide()
	Current_shown_faille = int(value)
	#updateLabel()

# Handle OpenXR session ready
func _on_openxr_session_begun() -> void:
	# Get the reported refresh rate
	var current_refresh_rate = xr_interface.get_display_refresh_rate()
	if current_refresh_rate > 0:
		print("OpenXR: Refresh rate reported as ", str(current_refresh_rate))
		# See if we have a better refresh rate available
		var new_rate = current_refresh_rate
		var available_rates : Array = xr_interface.get_available_display_refresh_rates()
		if available_rates.size() == 0:
			print("OpenXR: Target does not support refresh rate extension")
		elif available_rates.size() == 1:
			# Only one available, so use it
			new_rate = available_rates[0]
		else:
			for rate in available_rates:
				if rate > new_rate and rate <= maximum_refresh_rate:
					new_rate = rate

		# Did we find a better rate?
		if current_refresh_rate != new_rate:
			print("OpenXR: Setting refresh rate to ", str(new_rate))
			xr_interface.set_display_refresh_rate(new_rate)
			current_refresh_rate = new_rate

		# Now match our physics rate
		Engine.physics_ticks_per_second = current_refresh_rate
	else:
		print("OpenXR: No refresh rate given by XR runtime")



# Handle OpenXR visible state
func _on_openxr_visible_state() -> void:
	# We always pass this state at startup,
	# but the second time we get this it means our player took off their headset
	if xr_is_focused:
		print("OpenXR lost focus")

		xr_is_focused = false
		# pause our game
		get_tree().paused = true

		emit_signal("focus_lost")

# Handle OpenXR focused state
func _on_openxr_focused_state() -> void:
	print("OpenXR gained focus")
	xr_is_focused = true

	# unpause our game
	get_tree().paused = false

	emit_signal("focus_gained")
	

# Handle OpenXR stopping state
func _on_openxr_stopping() -> void:
	# Our session is being stopped.
	print("OpenXR is stopping")
	


# Handle OpenXR pose recentered signal
#func _on_openxr_pose_recentered() -> void:
	## User recentered view, we have to react to this by recentering the view.
	## This is game implementation dependent.
	#emit_signal("pose_recentered")


func _on_left_hand_button_pressed(button_name: String) -> void:
	print("Button pressed : ",button_name)
	if button_name == "trigger_click":
		is_started = !is_started
		set_meta("trigger_click",true)
	elif button_name == "menu_button":
		changeInterpolation()
	elif button_name == "select_button": 
		set_meta("select_click",true)
	elif button_name == "primary_touch":
		terrain_material.set_shader_parameter("use_mask",true)
		var sillonInt = $XROrigin3D/SillonInterpole
		#sillonInt.scale = Vector3(8.0,8.0,8.0)
		scale_up(sillonInt,8.0)
		await terrainTween.finished

func scale_up(obj:Node3D,end_scale:float):
	if terrainTween:
		terrainTween.kill()
	terrainTween = get_tree().create_tween()
	terrainTween.tween_property(obj,"scale",Vector3(end_scale,end_scale,end_scale),0.8)
	#terrainTween.tween_callback(obj.queue_free)

func _on_left_hand_button_released(button_name: String) -> void:
	print("Button released : ",button_name)
	if button_name == "trigger_click":
		set_meta("trigger_click",false)
	elif button_name == "select_button":
		set_meta("select_click",false)
	elif button_name == "primary_touch":
		var sillonInt = $XROrigin3D/SillonInterpole
		scale_up(sillonInt,1.0)
		await terrainTween.finished
		terrain_material.set_shader_parameter("use_mask",false)


func _on_left_hand_input_float_changed(_button_name: String, _value: float) -> void:
	pass
	#print("Value changed : ",button_name," ",value)


func _on_timeline_slider_sillon_drag_started() -> void:
	print("start drag")
	timelineSillonDragged=true
	TimelineSillon.step=1.0


func _on_timeline_slider_sillon_drag_ended(value_changed: bool) -> void:
	print("end drag ", value_changed," ",TimelineSillon.value)
	#blend_value= TimelineSillon.value
	TimelineSillon.step=0.01
	timelineSillonDragged=false


func _on_left_hand_input_vector_2_changed(button_name: String, value: Vector2) -> void:
	print("Vec2 ",button_name," ",value)


func _on_play_button_toggled(toggled_on: bool) -> void:
	var playButton : TextureButton = ui_root.get_node("PlayButton")
	is_paused = toggled_on
	print("Is paused ",is_paused)
	#terrain_material.set_shader_parameter("use_height_diff",is_paused)
	if is_paused:
		playButton.texture_normal = load("res://texture/playButton.png")
		terrain_material.set_shader_parameter("blend_factor",1.0)
		terrain_material.set_shader_parameter("CurrentMesh",loadMeshLowestHandle())
		terrain_material.set_shader_parameter("NextMesh",loadMeshHighestHandle())
		#terrain_material.set_shader_parameter("visual_renderer",0)
	else:
		playButton.texture_normal = load("res://texture/pauseButton.png")
		if use_ortho:
			#print("Current files ",int(TimelineSillon.value)," ",int(round(TimelineSillon.value)))
			#print("Les vrais ",next_mesh_sillon)
			terrain_material.set_shader_parameter("CurrentMesh",mnt_dic[mnt_dic.keys()[int(TimelineSillon.value)]])
			if int(TimelineSillon.value)==TimelineSillon.max_value:
				terrain_material.set_shader_parameter("NextMesh",mnt_dic[mnt_dic.keys()[0]])
			else:
				terrain_material.set_shader_parameter("NextMesh",mnt_dic[mnt_dic.keys()[int(TimelineSillon.value)+1]])
			terrain_material.set_shader_parameter("blend_factor",blend_value)
			var button : CheckButton = get_node("Control/CheckButton")
			print("Visual renderer ",int(button.button_pressed)+1)
			#terrain_material.set_shader_parameter("visual_renderer",int(button.button_pressed)+1)
		else:
			print("Current files ",int(TimelineSillon.value)," ",int(round(TimelineSillon.value)))
			print("Les vrais ",next_mesh_sillon)
			terrain_material.set_shader_parameter("CurrentMesh",load(current_files[int(TimelineSillon.value)]))
			if int(TimelineSillon.value)==TimelineSillon.max_value:
				terrain_material.set_shader_parameter("NextMesh",load(current_files[0]))
			else:
				terrain_material.set_shader_parameter("NextMesh",load(current_files[int(TimelineSillon.value)+1]))
			terrain_material.set_shader_parameter("blend_factor",blend_value)
		#print(rangeSlider.handle1_value)
	print("Play button toggled ",toggled_on)

func update_height_diff()->void:
	if is_paused:
		terrain_material.set_shader_parameter("NextMesh",loadMeshHighestHandle())
		terrain_material.set_shader_parameter("CurrentMesh",loadMeshLowestHandle())
	#else:
		#var playButton : TextureButton = get_node("Control/PlayButton")
		#playButton.button_pressed = true


func _on_check_button_toggled(toggled_on: bool) -> void:
	if !is_paused:
		terrain_material.set_shader_parameter("visual_renderer",int(toggled_on)+1)


func _on_ortho_scale_value_changed(value: float) -> void:
	var so :Node3D= get_node("XROrigin3D/SillonOrtho")
	so.scale = Vector3(value/echelle,value/echelle,value/echelle)
	WaterSillon.scale = Vector3(value,value,value)
	#Positionnement du label de la valeur
	var orthoValue :Label = ui_root.get_node("OrthoScaleValue")
	orthoValue.text = str(value)
	var slider : VSlider = ui_root.get_node("OrthoScale")
	var ratio := 0.0
	#var log_val := log(value / slider.min_value) / log(slider.max_value / slider.min_value)
	#ratio = clamp(log_val, 0.0, 1.0)
	ratio = (slider.value - slider.min_value) / (slider.max_value - slider.min_value)
	var handle_y = slider.position.y + (1.0 - ratio) * slider.size.y
	orthoValue.position.y = handle_y - orthoValue.size.y / 2


func _on_ortho_height_scale_value_changed(value: float) -> void:
	print("Old exageration : ",terrain_material.get_shader_parameter("height_exageration"))
	terrain_material.set_shader_parameter("height_exageration",value)
	#Positionnement du label de la valeur
	var orthoHeightValue :Label = ui_root.get_node("OrthoHeightScaleValue")
	orthoHeightValue.text = str(value)
	var slider : VSlider = ui_root.get_node("OrthoHeightScale")
	var ratio := 0.0
	ratio = (slider.value - slider.min_value) / (slider.max_value - slider.min_value)
	var handle_y = slider.position.y + (1.0 - ratio) * slider.size.y
	orthoHeightValue.position.y = handle_y - orthoHeightValue.size.y / 2

func _on_change_view_button_pressed(value:float)->void:
	print("Radio button pressed : ",value)
	visual_renderer = value
	if visual_renderer==0:
		is_paused = true
		ui_root.get_node("RangeSlider").show()
		var playButton : TextureButton = ui_root.get_node("PlayButton")
		playButton.set_pressed_no_signal(true)
		playButton.texture_normal = load("res://texture/playButton.png")
		terrain_material.set_shader_parameter("blend_factor",1.0)
		terrain_material.set_shader_parameter("CurrentMesh",loadMeshLowestHandle())
		terrain_material.set_shader_parameter("NextMesh",loadMeshHighestHandle())
		TimelineSillon.hide()
		#update_height_diff()
	else:
		TimelineSillon.show()
		ui_root.get_node("RangeSlider").hide()
	terrain_material.set_shader_parameter("visual_renderer",visual_renderer)


func _on_water_button_toggled(toggled_on: bool) -> void:
	if WaterSillon.visible:
		WaterSillon.hide()
		ui_root.get_node("WaterButton").texture_normal = load("res://texture/noTides.png")
	else:
		WaterSillon.show()
		ui_root.get_node("WaterButton").texture_normal = load("res://texture/tides.png")
