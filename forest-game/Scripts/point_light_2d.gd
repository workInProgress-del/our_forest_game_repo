extends PointLight2D

var died = false

func _ready() -> void:
	GameManager.game_ended.connect(death_screen)

func _physics_process(delta: float) -> void:
	if not died: return
	if energy > 0:
		energy -= 0.03
	else:
		time_out()

func time_out():
		GameManager.new_game()
		
func death_screen():
	died = true
