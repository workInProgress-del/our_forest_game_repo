extends PointLight2D

@export var speed: float = 1.0

var died = false
var dead = false


func _process(_delta):
	var time = Time.get_ticks_msec() / 1000.0 * speed

	color = Color(
		sin(time) * 0.5 + 0.5,
		sin(time + TAU / 3.0) * 0.5 + 0.5,
		sin(time + TAU * 2.0 / 3.0) * 0.5 + 0.5,
		1.0
	)
	if not died: return
	if energy < 0: 
		get_parent().now_dead()
	die()

func die():
	energy -= 0.01
