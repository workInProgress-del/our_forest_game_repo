extends Node2D

@export var label_right_new_text:String = "Test text"
@export var label_left_new_text:String = "Test text"
@export var obsticle_texture:Texture2D
@export var book_texture:Texture2D
@export var new_title:String = "test text"

@onready var label_left = %RichTextLabel
@onready var label_right = %RichTextLabel2
@onready var obsticle = %obticleTexture
@onready var book = %TextureRect
@onready var UI = %UI
@onready var title = %Label

var player_in_reach:bool = true
var is_active:bool = false

func _ready() -> void:
	label_left.text = label_left_new_text
	label_right.text = label_right_new_text
	obsticle.texture = obsticle_texture
	book.texture = book_texture
	title.text = new_title
	

func _process(_delta: float) -> void:
	if player_in_reach:
		if Input.is_action_just_pressed("select"):
			if is_active:
				popdown()
			else:
				popup()


func popup():
	if UI.visible == false:
		is_active = true
		UI.position.y = 648
		UI.show()
		$AnimationPlayer.play("Popup")

func popdown():
	if UI.visible == true:
		is_active = false
		UI.position.y = 0
		UI.show()
		$AnimationPlayer.play("popdown")
		await $AnimationPlayer.animation_finished
		UI.hide()


func _on_detecting_area_2d_body_entered(body: Node2D) -> void:
	var body_group
	body_group = body.get_groups()
	if "Player" in body_group:
		player_in_reach = true


func _on_detecting_area_2d_body_exited(body: Node2D) -> void:
	var body_group
	body_group = body.get_groups()
	if "Player" in body_group:
		player_in_reach = false
