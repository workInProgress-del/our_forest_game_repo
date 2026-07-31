extends Control


func _ready() -> void:
	$VideoStreamPlayer.play()
	SoundPlayer.main_menu_active = true



func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/main_menu.tscn")
