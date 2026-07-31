extends Control

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton



func _ready() -> void:
	$AnimationPlayer.play("open")
	SoundPlayer.main_menu_active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/cutscenebeginning.tscn")


func _on_settings_button_pressed() -> void:
	print("nothing there yet.")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
