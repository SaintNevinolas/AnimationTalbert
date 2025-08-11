extends TextureButton
@onready var menu_container : VBoxContainer = get_node("../Menu")

func _on_pressed() -> void:
	menu_container.visible = !menu_container.visible
