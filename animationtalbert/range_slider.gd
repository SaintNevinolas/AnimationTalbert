extends Control

@export var min_value: float = 0.0
@export var max_value: float = 21.0
@export var handle1_value: float = 0.0
@export var handle2_value: float = 21.0

@onready var handle1 = $Handle1
@onready var handle2 = $Handle2
@onready var range_bar = $Bar

#@onready var root : Node3D = get_node("../../")
var root : Node3D
var dragging_handle1 = false
var dragging_handle2 = false

func _ready():
	#print("NODE ",get_node("../../").name," ",get_node("../../"))
	#print("NODE ",get_node("../").name," ",get_node("../"))
	#print("Owner ",self.owner)
	if self.owner is Control:
		print(get_node("../../../").name)
		print(self.owner.get_parent().get_parent().owner)
		root = self.owner.get_parent().get_parent().owner
	else:
		root = self.owner
	update_handles()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_global = get_global_mouse_position()
				if handle1.get_global_rect().has_point(mouse_global):
					dragging_handle1 = true
				elif handle2.get_global_rect().has_point(mouse_global):
					dragging_handle2 = true
			else:
				dragging_handle1 = false
				dragging_handle2 = false

	elif event is InputEventMouseMotion:
		if dragging_handle1 or dragging_handle2:
			var mouse_x = get_local_mouse_position().x
			var total_width = size.x
			var raw_value = (mouse_x / total_width) * (max_value - min_value) + min_value
			var rounded_value = int(round(raw_value))
			#Empecher de déplacer en dehors des bordures
			if rounded_value>=min_value and rounded_value<= max_value:
				#Empecher de déplacer les deux curseurs sur la même position
				if dragging_handle1 and rounded_value!=handle2_value:
					handle1_value = clamp(rounded_value, min_value, max_value)
					root.update_height_diff()
				elif dragging_handle2 and rounded_value!=handle1_value:
					handle2_value = clamp(rounded_value, min_value, max_value)
					root.update_height_diff()

			update_handles()

func update_handles():
	var range_length = max_value - min_value
	var width = size.x

	var min_pos = ((handle1_value - min_value) / range_length) * width
	var max_pos = ((handle2_value - min_value) / range_length) * width

	# Mise à jour de la position des handles
	handle1.position.x = min_pos - handle1.size.x / 2
	handle2.position.x = max_pos - handle2.size.x / 2

	# Mise à jour de la barre entre les deux handles
	var bar_x = min(min_pos, max_pos)
	var bar_width = abs(max_pos - min_pos)
	range_bar.position.x = bar_x
	range_bar.position.y = 0  
	range_bar.size = Vector2(bar_width, size.y)
