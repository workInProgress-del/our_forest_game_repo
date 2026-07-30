extends Node2D

@export var label_right_new_text:String = "Test text"
@export var label_left_new_text:String = "Test text"
@export var obsticle_texture:Texture2D
@export var book_texture:Texture2D

@onready var label_left = %LabelLeft
@onready var label_right = %LabelRight
@onready var obsticle = %obticleTexture
@onready var book = %TextureRect

var player_in_reach:bool
var is_active:bool = false

func _ready() -> void:
	label_left.text = label_left_new_text
	label_right.text = label_right_new_text
	obsticle.texture = obsticle_texture
	book.texture = book_texture
