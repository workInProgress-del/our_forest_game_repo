extends Node

var player_moths = 0

signal added_player_moths
signal deleted_player_moths

func _ready() -> void:
	add_player_moths(2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_player_moths(amount: int):
	player_moths += amount
	added_player_moths.emit(amount)
	
func delete_player_moths(amount: int):
	player_moths -= amount
	deleted_player_moths.emit(amount)
