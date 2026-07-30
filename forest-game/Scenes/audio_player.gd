extends Node
@export var sounds: Array[AudioStream]

@export var sound_effects: Array[AudioEffect, String]


@onready var player = $AudioStreamPlayer
var rng = RandomNumberGenerator.new()
var volume = 0.0

func _ready():   
	play_random_sound()


func play_random_sound():
	while true:   
		await get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout           
		player.stream = sounds[rng.randi_range(0, sounds.size() - 1)]
		player.volume_db = rng.randf_range(-7,0)
		player.play()    
		await player.finished
