extends CharacterBody2D


var speed = 100.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing = true


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.x = speed
	if !$GroundCheck.is_colliding() or $WallCheck.is_colliding():
		flip()
	move_and_slide()

func flip():
	facing = !facing
	scale.x = -abs(scale.x)
	if facing:
		speed = abs(speed)
	else:
		speed = -abs(speed)


func _on_hitbox_body_entered(body):
	if body.has_meta("spike"):
		die()

func explode():
	die()

func die():
	queue_free()
