extends Node

@export var moth_scene = preload("res://Scenes/Motten/motten.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_add_player_moths(amount: int):
	var count = 0
	while count < amount:
		count += 1
		var new_moth = moth_scene.instantiate()
		add_child(new_moth)
		new_moth.folowing_objekt = get_parent().get_node("Player")
