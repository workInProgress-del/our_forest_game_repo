extends Control


func _ready() -> void:
	$VideoStreamPlayer.play()




func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/level_1.tscn")
