extends CharacterBody2D

@export var max_speed := 100.0
@export var acceleration:float = 10
@export var max_player_distance = 100
@export var min_target_distance: float = 140.0
# Radius des Bewegungsbereichs
@export var radius := 150.0

# Abstand zum Ziel, bevor ein neues gewählt wird
@export var target_distance := 10.0

var center: Vector2
var target_position: Vector2
var folows_player:bool = false
var folowing_objekt
var angle_diff = 0.0
var collected = false

func _ready():
	randomize()
	center = global_position
	choose_new_target()

func _physics_process(delta):
	rand_move(delta)


func rand_move(delta):
	#eventuele acceleration
	var direction = target_position - global_position
	velocity = max_speed * direction
	velocity = velocity.lerp(target_position, acceleration * get_process_delta_time())
	if direction.length() < target_distance:
		choose_new_target()
		
	var target_angle = global_position.angle_to_point(target_position)
	var base_turn_speed = 3.0
	var rotation_speed = base_turn_speed / max(0.5, angle_diff) # Dreht langsamer bei großen Winkeln
	
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

#	if cur_velocity > speed:
#		cur_velocity = speed

	move_and_slide()

func choose_new_target():
	var angle = randf_range(0.0, TAU)
	var distance = 0.0
	
	if folowing_objekt:
		if global_position.distance_to(folowing_objekt.position) < max_player_distance:
			while distance < min_target_distance:
				distance = sqrt(randf()) * radius
			get_target(distance, angle)
		else:
			target_position = folowing_objekt.position
			center = folowing_objekt.position
	else:
		while distance < min_target_distance:
			distance = sqrt(randf()) * radius
		get_target(distance, angle)


func get_target(distance,angle):
	target_position = center + Vector2(
			cos(angle),
			sin(angle)
		) * distance

func die():
	SoundPlayer.play_sound_effect("motte_lost")
	$PointLight2D.died = true

	
func now_dead():
	queue_free()
	


func _on_einsammel_area_2d_body_entered(body: Node2D) -> void:
	if collected: return
	
	var body_group = body.get_groups()

	if "Player" in body_group:
		GameManager.add_player_moths(1, false)
		collected = true
		folowing_objekt = body
		var new_parent = get_tree().current_scene.get_node("PlayerMoths")
		get_parent().remove_child(self)
		new_parent.add_child(self)
		SoundPlayer.play_sound_effect("motte_collected")
