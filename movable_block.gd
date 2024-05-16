extends CharacterBody2D
@export var speed = 5000
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var friction = 400
var pusher_groups = ["player","cultist"]
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.x = move_toward(velocity.x,0,friction*delta)
	for body in $Left.get_overlapping_bodies():
		for group in pusher_groups:
			if body.is_in_group(group):
				velocity.x = speed * delta
	for body in $Right.get_overlapping_bodies():
		for group in pusher_groups:
			if body.is_in_group(group):
				velocity.x = -speed * delta
	if not is_on_floor():
		velocity.y += gravity * delta
	else :
		velocity.y = 0
	move_and_slide()
