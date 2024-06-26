extends CharacterBody2D

signal dominateMe
signal letGoPls

@export var minecartOffset = -33.0
@export var speed = 100.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var flipped = false
var facing = true
var locked = false
var dominated = false
@export var turn_counter_limit = 5
var turn_counter = 0

@export var friction = 10

func _ready():
	if flipped:
		flip()

func lockMovement():
	locked = true

func releaseMovement():
	locked = false
	turn_counter = 0

func am_dom(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
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
		turn_counter = 0
		am_dom(delta)
		return
		
	if !$GroundCheck.is_colliding() or ($WallCheck.get_collider() != null and !$WallCheck.get_collider() is Player):
		flip(false)
		turn_counter += 10 * delta
		velocity.x = 0
	elif is_on_floor():
		velocity.x = speed
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func flip(bypass=true):
	if not bypass and turn_counter < turn_counter_limit:
		return
	turn_counter = 0
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
		flip(true)
	facing = true
	velocity.x = abs(speed)

func move_left():
	if locked:
		return
	if facing:
		flip(true)
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
	
func mouse_input(event):
	if dominated:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dominateMe.emit(self)

func _on_hitbox_input_event(_viewport, event, _shape_idx):
	mouse_input(event)
