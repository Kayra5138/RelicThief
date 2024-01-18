extends CharacterBody2D


@export var speed = 70.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing = true
var playerSeen = false
var collider

func _physics_process(delta):
	playerSeen = false
	if $EyeSight1.is_colliding() and $EyeSight1.get_collider().has_meta("Player"):
		playerSeen = true
	if $EyeSight2.is_colliding() and $EyeSight2.get_collider().has_meta("Player"):
		playerSeen = true
	if $EyeSight3.is_colliding() and $EyeSight3.get_collider().has_meta("Player"):
		playerSeen = true
	if $EyeSightBack.is_colliding() and $EyeSightBack.get_collider().has_meta("Player"):
		flip()
		playerSeen = true
	if not is_on_floor():
		velocity.y += gravity * delta
	elif playerSeen:
		velocity.x = speed
	else:
		velocity.x = 0
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



