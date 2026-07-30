class_name ButtonClass
extends Button

func _ready() -> void:
	pressed.connect(_pressed)
	mouse_entered.connect(_hovered)
	
func _pressed() -> void:
	SoundPlayer.play_sound_effect("click_sound")
	
func _hovered() -> void:
	SoundPlayer.play_sound_effect("hover_sound")
