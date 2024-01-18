extends CharacterBody2D

@export var speed = 140
@export var jump_speed = -500
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.25
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing = 1 #right: 1 - left: 0
var skill = 5
@onready var animatedSprite = $AnimatedSprite2D 
const ice_spike_path = preload("res://icespike.tscn")
var coyoteJumpTimer = 15
var lockControls = false
var minecartOffset = -32
const CLIMB_SPEED = 100
enum {sMOVE, sCLIMB}
var curState = sMOVE

func climbing_state():
	$AnimatedSprite2D.animation = "jump"
	var input = Vector2.ZERO
	input.x = Input.get_axis("left","right")
	input.y = Input.get_axis("up","down")
	velocity = input*CLIMB_SPEED
	move_and_slide()

func _physics_process(delta):
	ladder_check()
	if curState == sCLIMB:
		climbing_state()
		return
	if lockControls:
		$AnimatedSprite2D.animation = "idle"
		if facing == 0:
			transform.x.x = -1
		if facing == 1:
			transform.x.x = 1
		return
	velocity.y += gravity * delta
	var dir = Input.get_axis("left", "right")
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
	move_and_slide()
	
	if (velocity.x > 0 and velocity.x < 10) or (velocity.x > -10 and velocity.x < 0):
		velocity.x = 0
	
	if Input.is_action_just_pressed("restart"):
		restart()
	
	if Input.is_action_pressed("left"):
		if is_on_floor(): 
			animatedSprite.animation = "walk"
		facing = 0

	if Input.is_action_pressed("right"):
		if is_on_floor(): 
			animatedSprite.animation = "walk"
		facing = 1

			
	if (Input.is_action_just_released("right") or Input.is_action_just_released("left")):
		animatedSprite.animation = "idle"
	
	if !is_on_floor():
		animatedSprite.animation = "jump"
		if coyoteJumpTimer > 0:
			coyoteJumpTimer += -1
		
	
	if is_on_floor():
		coyoteJumpTimer = 15
		if velocity.x == 0:
			animatedSprite.animation = "idle"

	if Input.is_action_just_pressed("up") and (is_on_floor() or coyoteJumpTimer>0):
		velocity.y = jump_speed
		coyoteJumpTimer = 0

	if Input.is_action_pressed("shoot") and $IceSpikeCooldown.is_stopped() and skill > 0 and !$IceSpikeCollideCheck.is_colliding():
		skill += -1
		shoot_ice_spike()
		
	#DEBUG
	if Input.is_action_just_pressed("down"):
		skill = 5
		
	if facing == 0:
		transform.x.x = -1
	if facing == 1:
		transform.x.x = 1
		
	
func shoot_ice_spike():
	var ice_spike = ice_spike_path.instantiate()
	$IceSpikeCooldown.start(1)
	get_parent().add_child(ice_spike)
	ice_spike.position = $IceSpikePosition.global_position
	if !facing:
		ice_spike.icespikevelocity.x = -1
		ice_spike.scale.x = -1


func explode():
	restart()

func restart():
	get_tree().reload_current_scene()

func _on_hitbox_body_entered(body):
	if body.has_meta("enemy"):
		restart()

func lockMovement():
	lockControls = true

func releaseMovement():
	lockControls = false

func ladder_check():
	if $LadderCheck.get_collider() is Ladder:
		curState = sCLIMB
	else:
		curState = sMOVE
