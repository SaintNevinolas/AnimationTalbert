extends VBoxContainer
signal change_view(value)
@onready var button1 :CheckBox = get_node("CheckBox")
@onready var button2 :CheckBox = get_node("CheckBox2")
@onready var button3 :CheckBox = get_node("CheckBox3")



func _on_check_box_pressed() -> void:
	emit_signal("change_view",0)


func _on_check_box_2_pressed() -> void:
	emit_signal("change_view",1)


func _on_check_box_3_pressed() -> void:
	emit_signal("change_view",2)
