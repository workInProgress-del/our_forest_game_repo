extends Control


@export var main_menu_scene = preload("res://Scenes/MainMenu/main_menu.tscn")

func _ready() -> void:
	hide()
	$AnimationPlayer.play("open")
	visible = true


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/level_1.tscn")


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/main_menu.tscn")
