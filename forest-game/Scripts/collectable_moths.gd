extends Node


var died = false

func _ready() -> void:
	GameManager.game_ended.connect(death_screen)


func death_screen():
	for moth in get_children():
		moth.die()
	died = true
