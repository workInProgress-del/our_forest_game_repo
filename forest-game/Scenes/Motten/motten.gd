extends CharacterBody2D

@export var max_speed := 100.0
@export var acceleration:float = 10
@export var max_player_distance = 100

# Radius des Bewegungsbereichs
@export var radius := 150.0

# Abstand zum Ziel, bevor ein neues gewählt wird
@export var target_distance := 10.0

var center: Vector2
var target_position: Vector2
var folows_player:bool = false
var folowing_objekt

func _ready():
	randomize()
	center = global_position
	choose_new_target()

func _physics_process(delta):
	rand_move()


func rand_move():
	#eventuele acceleration
	var direction = target_position - global_position
	velocity = max_speed * direction
	velocity = velocity.lerp(target_position,acceleration * get_process_delta_time())

	if direction.length() < target_distance:
		choose_new_target()

#	if cur_velocity > speed:
#		cur_velocity = speed

	move_and_slide()

func choose_new_target():
	var angle = randf_range(0.0, TAU)
	var distance = sqrt(randf()) * radius
	if global_position.distance_to(folowing_objekt) < max_player_distance:
		target_position = center + Vector2(
			cos(angle),
			sin(angle)
		) * distance
	else:
		target_position = folowing_objekt.position


func _on_einsammel_area_2d_body_entered(body: CharacterBody2D) -> void:
	var body_group = body.get_groups()

	if "Player" in body_group:
		folows_player = true
		folowing_objekt = body
		print("eingesammelt")
