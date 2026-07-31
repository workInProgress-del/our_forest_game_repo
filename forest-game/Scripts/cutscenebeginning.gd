extends VideoStreamPlayer


func _ready() -> void:
	play()


func _on_finished() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/level_1.tscn")
