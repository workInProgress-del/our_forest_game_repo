extends Node

var player_moths = 0

signal added_player_moths
signal deleted_player_moths
signal game_ended

func _ready() -> void:
	player_moths = 3
	

func add_player_moths(amount: int, new_moth: bool):
	player_moths += amount
	if not new_moth: return
	added_player_moths.emit(amount)
	
func delete_player_moths(amount: int):
	player_moths -= amount
	deleted_player_moths.emit(amount)
	if player_moths <= 0:
		end_game()

func end_game():
	game_ended.emit()
	
func new_game():
	get_tree().reload_current_scene()
