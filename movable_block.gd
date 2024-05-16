extends CharacterBody2D
@export var speed = 100
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var friction = 500
var pusher_groups = ["player","cultist"]

func _process(delta):
	velocity.x = move_toward(velocity.x,0,friction*delta)
	for body in $Left.get_overlapping_bodies():
		for group in pusher_groups:
			if body.is_in_group(group):
				velocity.x = speed
	for body in $Right.get_overlapping_bodies():
		for group in pusher_groups:
			if body.is_in_group(group):
				velocity.x = -speed
	if not is_on_floor():
		velocity.y += gravity * delta
	else :
		velocity.y = 0
	move_and_slide()

func explode():
	queue_free()
