extends CharacterBody2D

signal dominateMe
signal letGoPls

@export var minecartOffset = -30.0
@export var friction = 10
@export var speed = 40 * 100
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing = true
var playerSeen = false
var collider
var locked = false

@export var flipped = true

func _ready():
	if flipped:
		flip()

func am_dom(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x *= delta
	move_and_slide()
	velocity = velocity.move_toward(Vector2.ZERO,friction)
	
func _physics_process(delta):
	$GPUParticles2D.emitting = dominated
	if locked:
		return
	if facing:
		speed = abs(speed)
	else:
		speed = -abs(speed)
	if dominated:
		am_dom(delta)
		return

	playerSeen = false
	var seen1col = $EyeSight/EyeSight1.get_collider()
	if seen1col != null and seen1col.has_meta("Player"):
		playerSeen = true
	var seen2col = $EyeSight/EyeSight2.get_collider()
	if seen2col != null and seen2col.has_meta("Player"):
		playerSeen = true
	var seen3col = $EyeSight/EyeSight3.get_collider()
	if seen3col != null and seen3col.has_meta("Player"):
		playerSeen = true
	var seenbackcol = $EyeSight/EyeSightBack.get_collider()
	if seenbackcol != null and seenbackcol.has_meta("Player"):
		flip()
	if not is_on_floor():
		velocity.y += gravity * delta
	elif playerSeen:
		velocity.x = speed * delta
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
	if dominated or locked:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dominateMe.emit(self)


func _on_hitbox_input_event(_a, event, _b):
	mouse_input(event)
