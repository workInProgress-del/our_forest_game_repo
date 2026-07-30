extends Node

var player_moths = 0

signal added_player_moths
signal deleted_player_moths






	
func add_player_moths(amount: int):
	player_moths += amount
	added_player_moths.emit(amount)
	
func delete_player_moths(amount: int):
	player_moths -= amount
	deleted_player_moths.emit(amount)
