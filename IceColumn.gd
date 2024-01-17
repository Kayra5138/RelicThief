extends CharacterBody2D

var ice_texture = preload("res://ice_texture.tscn")

var rising_time = 0
@export var speed = 0.05

@export var lst:Array[Node2D]
var state = 0
var rise = false

@onready var top = $Top

var ice_text:Line2D

var first = true

@export var col:CollisionShape2D

var last_y_scale = 1

func _ready():
	col.get_parent().remove_child(col)
	$Area2D.add_child(col)

func _physics_process(delta):
	if rise:
		ice_text.add_point(top.global_position - global_position)
		var curPoint = lst[state]
		scale.y += speed
		if top.global_position.distance_to(curPoint.global_position) < 0.7:
			rise = false
			$Area2D.scale.y /= scale.y/last_y_scale
			last_y_scale = scale.y
			state += 1
	move_and_slide()

func mouse_input(event):
	if state == len(lst):
		return
	if event is InputEventMouseButton and not rise:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			rise = true
			if first:
				ice_text = ice_texture.instantiate()
				ice_text.position = position
				get_parent().add_child(ice_text)
				first = false

func _on_area_2d_input_event(viewport, event, shape_idx):
	mouse_input(event)


func _on_input_event(viewport, event, shape_idx):
	mouse_input(event)
