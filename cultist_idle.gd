extends CharacterBody2D

signal dominateMe
signal letGoPls

@export var minecartOffset = -30.0
@export var friction = 10
@export var speed = 100.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing = true
var playerSeen = false
var collider
var locked = false

func _ready():
	flip()

func am_dom(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
	velocity = velocity.move_toward(Vector2.ZERO,friction)
	
func _physics_process(delta):
	if locked:
		return
	if dominated:
		am_dom(delta)
		return
	playerSeen = false
	if $EyeSight/EyeSight1.is_colliding() and $EyeSight/EyeSight1.get_collider().has_meta("Player"):
		playerSeen = true
	if $EyeSight/EyeSight2.is_colliding() and $EyeSight/EyeSight2.get_collider().has_meta("Player"):
		playerSeen = true
	if $EyeSight/EyeSight3.is_colliding() and $EyeSight/EyeSight3.get_collider().has_meta("Player"):
		playerSeen = true
	if $EyeSight/EyeSightBack.is_colliding() and $EyeSight/EyeSightBack.get_collider().has_meta("Player"):
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

func move_right():
	if locked:
		return
	if not facing:
		flip()
	facing = true
	velocity.x = abs(speed)

func move_left():
	if locked:
		return
	if facing:
		flip()
	facing = false
	velocity.x = -abs(speed)

func _on_hitbox_body_entered(body):
	if body.has_meta("spike"):
		die()

func explode():
	die()

func die():
	if dominated:
		letGoPls.emit()
	queue_free()

func lockMovement():
	locked = true

func releaseMovement():
	locked = false

var dominated = false
func mouse_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dominateMe.emit(self)

func _on_hitbox_input_event(event):
	mouse_input(event)
