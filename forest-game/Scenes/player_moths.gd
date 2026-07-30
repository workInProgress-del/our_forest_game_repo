extends Node

@export var moth_scene = preload("res://Scenes/Motten/motten.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.added_player_moths.connect(on_add_player_moths)
	GameManager.deleted_player_moths.connect(on_delete_player_moths)
	on_add_player_moths(3)
	GameManager.player_moths = 3

func on_add_player_moths(amount: int):
	var count = 0
	while count < amount:
		count += 1
		var new_moth = moth_scene.instantiate()
		add_child(new_moth)
		new_moth.folowing_objekt = get_parent().get_node("Player")
		new_moth.collected = true
	
		
func on_delete_player_moths(amount: int):
	var count = amount
	for moth in get_children():
		if count == 0:
			break
		count -= 1
		moth.die()
