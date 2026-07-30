class_name Player extends CharacterBody2D

@export var speed := 500.0
@export var gravity := 4000.0
@export var jump_impulse := 1800.0
@export var air_control := 0.9
@onready var animation_player: AnimatedSprite2D = %AnimatedSprite2D

func _ready() -> void:
	GameManager.add_player_moths(2)
