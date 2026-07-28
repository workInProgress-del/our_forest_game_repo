extends PlayerState

var jump_started =false

func enter(previous_state_path: String, data := {}) -> void:
	jump_started = false
	player.animation_player.play("prime_jump")
	player.animation_player.animation_finished.connect(_on_prime_jump_finished)

func physics_update(delta: float) -> void:
	if not jump_started: return
	
	var input_direction_x := Input.get_axis("move_left", "move_right")
	player.velocity.x = player.speed * input_direction_x * player.air_control
	player.velocity.y += player.gravity * delta
	player.move_and_slide()

	if player.velocity.y >= 0:
		finished.emit(FALLING)

func _on_prime_jump_finished():
	player.velocity.y = -player.jump_impulse
	jump_started = true
	player.animation_player.animation_finished.disconnect(_on_prime_jump_finished)
