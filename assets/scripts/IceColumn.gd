extends StaticBody2D

var ice_texture = preload("res://assets/skills/ice_texture.tscn")
@onready var onTop:Area2D = $onTop
var nudge_speed = 300

signal can_i_do

var rising_time = 0
@export var speed = 2

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
		scale.y += speed * delta
		if top.global_position.distance_to(curPoint.global_position) < 5:
			rise = false
			$Area2D.scale.y /= scale.y/last_y_scale
			last_y_scale = scale.y
			state += 1

func do_skill():
	rise = true
	if first:
		ice_text = ice_texture.instantiate()
		ice_text.position = position
		get_parent().add_child(ice_text)
		first = false

func mouse_input(event):
	if state == len(lst):
		return
	if event is InputEventMouseButton and not rise:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			can_i_do.emit(self)

func explode():
	if ice_text != null:
		ice_text.queue_free()
	first = true
	state = 0
	scale.y = 1
	$Area2D.scale.y = 1
	last_y_scale = 1

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	mouse_input(event)


func _on_input_event(_viewport, event, _shape_idx):
	mouse_input(event)
