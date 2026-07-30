extends Node
@export var sounds: Array[AudioStream]

var sound_effects := {
	"jump_sound": "res://Assets/sounds/gtaSounds-SprungLanden.wav",
	"move_sound": "res://Assets/sounds/gtaSounds-schritte1.wav",
	"brief_sound": "res://Assets/sounds/gtaSounds-brief.wav",
	"click_sound": "res://Assets/sounds/gtaSounds-click.wav",
	"death_sound": "res://Assets/sounds/gtaSounds-deathSound.wav",
	"motte_collected": "res://Assets/sounds/gtaSounds-motteVerlieren1.wav",
	"motte_lost": "res://Assets/sounds/gtaSounds-motteFangen.wav",
	"hover_sound": "res://Assets/sounds/gtaSounds-buttonHovered.mp3"
}


@onready var player_background: AudioStreamPlayer = $AudioStreamPlayerBackground
@onready var sound_player: AudioStreamPlayer2D = $SoundPlayer
@onready var player = $AudioStreamPlayer
var rng = RandomNumberGenerator.new()
var volume = 0.0

func _ready():   
	play_random_sound()
	play_random_sound_background()


func play_random_sound():
	while true:   
		await get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout           
		player.stream = sounds[rng.randi_range(0, sounds.size() - 1)]
		player.volume_db = rng.randf_range(-7,0)
		player.play()    
		await player.finished

func play_random_sound_background():
	while true:   
		await get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout           
		player_background.stream = sounds[rng.randi_range(0, sounds.size() - 1)]
		player_background.volume_db = rng.randf_range(-20,-7)
		player_background.play()    
		await player_background.finished

func play_sound_effect(sound_effect_name: String):
	sound_player.stream = load(sound_effects[sound_effect_name])
	sound_player.play()
