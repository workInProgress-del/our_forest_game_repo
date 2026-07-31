extends Control


func _ready() -> void:
	$VideoStreamPlayer.play()
	SoundPlayer.main_menu_active = true



func _on_video_stream_player_finished() -> void:
	GameManager.respawn_after_victory()
