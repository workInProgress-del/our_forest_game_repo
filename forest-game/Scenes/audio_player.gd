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
	"hover_sound": "res://Assets/sounds/gtaSounds-buttonHovered.mp3",
	"respawn_sound": "res://Assets/sounds/gtaSounds-respawnSound.wav"
}

@onready var main_menu_music: AudioStreamPlayer = $MainMenuMusic

@onready var walking_sound: AudioStreamPlayer = $WalkingSound
@onready var player_background: AudioStreamPlayer = $AudioStreamPlayerBackground
@onready var sound_player: AudioStreamPlayer = $SoundPlayer
@onready var player = $AudioStreamPlayer
var rng = RandomNumberGenerator.new()
var volume = 0.0
var step_timer := 0.0
var step_interval := 0.4
var player_is_walking = false
var main_menu_active = true
var main_menu_music_timer = 0
var main_menu_length:= 52.0

func _ready():
	play_random_sound()
	play_random_sound_background()
	var wav_stream := walking_sound.stream as AudioStreamWAV
	wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	start_main_menu_music_loop()



func _process(delta):
	if player_is_walking:
		step_timer -= delta
		if step_timer <= 0:
			play_step()
			step_timer = step_interval
	else:
		step_timer = 0.0
	if not main_menu_active:
		stop_music()

	
func start_main_menu_music_loop() -> void:
	await get_tree().create_timer(0.1).timeout  # kleiner Delay beim Start
	while true:
		if main_menu_active:
			play_music()
		await get_tree().create_timer(main_menu_length).timeout

func play_music():
	main_menu_music.play()
	
func stop_music():
	main_menu_music.stop()
	

func play_step():
	walking_sound.pitch_scale = randf_range(0.95, 1.05)
	walking_sound.volume_db = randf_range(-2, 0)
	walking_sound.play()

func play_random_sound():
	while true:
		await get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout
		player.stream = sounds[rng.randi_range(0, sounds.size() - 1)]
		player.volume_db = rng.randf_range(-20,-10)
		player.play()
		await player.finished

func play_random_sound_background():
	while true:
		await get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout
		player_background.stream = sounds[rng.randi_range(0, sounds.size() - 1)]
		player_background.volume_db = rng.randf_range(-30,-15)
		player_background.play()
		await player_background.finished

func play_sound_effect(sound_effect_name: String):
	sound_player.volume_db = rng.randf_range(-5,5)
	sound_player.stream = load(sound_effects[sound_effect_name])
	sound_player.play()
	
