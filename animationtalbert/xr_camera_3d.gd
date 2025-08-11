extends XRCamera3D
@onready var node : OpenXRCompositionLayerQuad = get_node("../XRDateLabel")
@onready var Sillon : Node3D = get_node("../SillonInterpole")
@export var normal_fov: float = 75.0   # Champ de vision normal
@export var zoom_fov: float = 30.0     # Champ de vision zoomé
@export var zoom_speed: float = 5.0    # Vitesse de transition du zoom
var target_fov :float = 75.0
var is_zooming: bool = false
func _physics_process(_delta: float) -> void:
	if node:
		#if get_node("/root/Node3D").get_meta("select_click"):
			#is_zooming = true
			#target_fov = zoom_fov
		#else:
			#if is_zooming:
				#is_zooming=false
				#target_fov = normal_fov
		#fov = lerp(fov,target_fov,zoom_speed*delta)
		# Positionner le panneau devant la caméra
		var offset_distance = 3.5  # Distance entre la caméra et le texte
		var forward_dir = -global_transform.basis.z  # Calculer la direction vers l'avant de la caméra
		var new_position = global_transform.origin + forward_dir * offset_distance
		new_position.y += 0.25
		# Appliquer la position calculée
		node.global_transform.origin = new_position

		# Appliquer la même rotation que la caméra pour que le texte soit orienté vers le regard
		node.global_transform.basis = global_transform.basis

		# Optionnel : afficher la position et la rotation de la caméra dans la console pour le debug
		#print("XRCamera3D Position:", global_transform.origin, " Rotation:", global_transform.basis.get_euler())
	#if Sillon && self.current:
		#var angle = rad_to_deg(get_angle_to_object(get_viewport().get_camera_3d(),get_node("../XRUI")))
		#print("Angle au sillon : ",angle)
		#var viewport_2d :XRToolsViewport2DIn3D= get_node("../XRUI")
		#if angle>70.0:
			#viewport_2d.rotation+=Vector3(0.0,90.0,0.0)
		#elif angle<-70.0:
			#viewport_2d.rotation+=Vector3(0.0,-90.0,0.0)

func get_angle_to_object(camera: Camera3D, target: Node3D) -> float:
	var cam_pos = camera.global_transform.origin
	var target_pos = target.global_transform.origin

	# Direction que regarde la caméra (vers l’avant)
	var camera_forward = -camera.global_transform.basis.z

	# Direction de la cible depuis la caméra
	var to_target = (target_pos - cam_pos).normalized()

	# On ne garde que la composante horizontale (X, Z)
	var forward_2d = Vector2(camera_forward.x, camera_forward.z).normalized()
	var to_target_2d = Vector2(to_target.x, to_target.z).normalized()

	# Angle entre les deux directions (en radians)
	var angle = forward_2d.angle_to(to_target_2d)

	return angle  # tu peux le convertir en degrés si besoin : rad2deg(angle)
