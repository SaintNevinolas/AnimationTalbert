extends Control
@onready var TimelineSliderSillon : HSlider = $TimelineSliderSillon
signal timeline_drag_started()
signal timeline_drag_ended(value_changed)
signal timeline_value_changed(value)
@onready var PlayButton : TextureButton = $PlayButton
signal play_button_toggled(toggled_on)
@onready var ButtonCheck : CheckButton = $CheckButton
signal check_button_toggled(toggled_on)
@onready var OrthoScale : VSlider = $OrthoScale
signal ortho_scale_value_changed(value)
@onready var OrthoHeightScale : VSlider= $OrthoHeightScale
signal ortho_height_scale_value_changed(value)
@onready var WaterButton : TextureButton = $WaterButton
signal water_button_toggled(toggled_on)

func _ready() -> void:
	TimelineSliderSillon.drag_started.connect(_on_timeline_slider_sillon_drag_started)
	TimelineSliderSillon.drag_ended.connect(_on_timeline_slider_sillon_drag_ended)
	TimelineSliderSillon.value_changed.connect(_on_timeline_slider_sillon_value_changed)
	
	PlayButton.toggled.connect(_on_play_button_toggled)
	ButtonCheck.toggled.connect(_on_check_button_toggled)
	OrthoScale.value_changed.connect(_on_ortho_scale_value_changed)
	OrthoHeightScale.value_changed.connect(_on_ortho_height_scale_value_changed)
	WaterButton.toggled.connect(_on_water_button_toggled)

func _on_timeline_slider_sillon_drag_started() -> void:
	emit_signal("timeline_drag_started")
func _on_timeline_slider_sillon_drag_ended(value_changed: bool) -> void:
	emit_signal("timeline_drag_ended",value_changed)
func _on_timeline_slider_sillon_value_changed(value: float) -> void:
	emit_signal("timeline_value_changed",value)
	
func _on_play_button_toggled(toggled_on: bool) -> void:
	emit_signal("play_button_toggled",toggled_on)

func _on_check_button_toggled(toggled_on: bool) -> void:
	emit_signal("check_button_toggled",toggled_on)

func _on_ortho_scale_value_changed(value: float) -> void:
	emit_signal("ortho_scale_value_changed",value)

func _on_ortho_height_scale_value_changed(value: float) -> void:
	emit_signal("ortho_height_scale_value_changed",value)
func _on_water_button_toggled(toggled_on: bool)-> void:
	emit_signal("water_button_toggled",toggled_on)
