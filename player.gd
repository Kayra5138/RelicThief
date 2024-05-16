extends CharacterBody2D

@export var can_dominate = true
@export var can_spike = true
@export var speed = 140
@export var jump_speed = -500
@export_range(0.0, 1.0) var friction = 0.25
@export_range(0.0 , 1.0) var acceleration = 0.25
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing = 1 #right: 1 - left: 0
var skill = 5
@onready var playerSprite = $PlayerSprite 
const ice_spike_path = preload("res://icespike.tscn")
var coyoteJumpTimer = 15
var lockControls = false
var minecartOffset = -32
const CLIMB_SPEED = 100
enum {sMOVE, sCLIMB}
var curState = sMOVE
var throwing = false

func climbing_state():
	playerSprite.animation = "jump"
	var input = Vector2.ZERO
	input.x = Input.get_axis("left","right")
	input.y = Input.get_axis("up","down")
	velocity = input*CLIMB_SPEED
	move_and_slide()

func domination(delta):
	if Input.is_action_pressed("left"):
		dominating.move_left()
	elif Input.is_action_pressed("right"):
		dominating.move_right()
	velocity.y += gravity * delta
	velocity.x = lerp(velocity.x, 0.0, friction)
	move_and_slide()

func _physics_process(delta):
	match skill:
		5: 
			$TankSprite.animation = "5"
			$TankLight.energy = 0.7
		4: 
			$TankSprite.animation = "4"
			$TankLight.energy = 0.6
		3: 
			$TankSprite.animation = "3"
			$TankLight.energy = 0.5
		2: 
			$TankSprite.animation = "2"
			$TankLight.energy = 0.4
		1: 
			$TankSprite.animation = "1"
			$TankLight.energy = 0.3
		0: 
			$TankSprite.animation = "0"
			$TankLight.energy = 0.2
	if dominating != null:
		domination(delta)
		return
		
	ladder_check()
	if curState == sCLIMB:
		climbing_state()
		return
	if lockControls:
		playerSprite.animation = "idle"
		if facing == 0:
			transform.x.x = -1
		if facing == 1:
			transform.x.x = 1
		return
	velocity.y += gravity * delta
	var dir = Input.get_axis("left", "right")
	if throwing == false:
		if dir != 0:
			velocity.x = lerp(velocity.x, dir * speed, acceleration)
		else:
			velocity.x = lerp(velocity.x, 0.0, friction)
	else:
		velocity.x = 0
	move_and_slide()
	
	if (velocity.x > 0 and velocity.x < 10) or (velocity.x > -10 and velocity.x < 0):
		velocity.x = 0
	
	if Input.is_action_just_pressed("restart"):
		restart()
	
	if throwing == false:
		if Input.is_action_pressed("left"):
			if is_on_floor(): 
				playerSprite.animation = "walk"
				playerSprite.play("walk")
			facing = 0
		if Input.is_action_pressed("right"):
			if is_on_floor(): 
				playerSprite.animation = "walk"
				playerSprite.play("walk")
			facing = 1

			
	if (Input.is_action_just_released("right") or Input.is_action_just_released("left")):
		playerSprite.animation = "idle"
	
	if !is_on_floor():
		playerSprite.animation = "jump"
		if coyoteJumpTimer > 0:
			coyoteJumpTimer += -1
		
	
	if is_on_floor():
		coyoteJumpTimer = 15
		if velocity.x == 0:
			if throwing == true:
				playerSprite.animation = "throw"
			else:
				playerSprite.animation = "idle"
				playerSprite.play("idle")

	if (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("up")) and (is_on_floor() or coyoteJumpTimer>0):
		velocity.y = jump_speed
		coyoteJumpTimer = 0


	if Input.is_action_pressed("shoot") and $IceSpikeCooldown.is_stopped() and skill > 0 and !$IceSpikeCollideCheck.is_colliding() and is_on_floor():
		skill -= 1
		shoot_ice_spike()
		
	
	if Input.is_action_just_pressed("down"):
		position.y += 1
		skill = 5 #DEBUG

	if facing == 0:
		transform.x.x = -1
	if facing == 1:
		transform.x.x = 1
		
	
func shoot_ice_spike():
	throwing = true
	var ice_spike = ice_spike_path.instantiate()
	$IceSpikeCooldown.start(1)
	get_parent().add_child(ice_spike)
	ice_spike.position = $IceSpikePosition.global_position
	if !facing:
		ice_spike.icespikevelocity.x = -1
		ice_spike.scale.x = -1

var dominating = null
func dominate(cultist):
	if dominating != null:
		return
	if not can_dominate or skill == 0:
		return
	skill -= 1
	dominating = cultist
	cultist.dominated = true
	lockMovement()
	
func stopDominate():
	dominating = null
	releaseMovement()

func explode():
	restart()

func restart():
	get_tree().reload_current_scene()

func _on_hitbox_body_entered(body):
	if body.has_meta("enemy") and body != dominating:
		restart()

func lockMovement():
	playerSprite.animation = "idle"
	lockControls = true

func releaseMovement():
	lockControls = false

func ladder_check():
	if $LadderCheck.get_collider() is Ladder:
		curState = sCLIMB
	else:
		curState = sMOVE


func mouse_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if dominating != null:
				dominating.dominated = false
				dominating = null
				releaseMovement()

func _on_hitbox_input_event(_a,event,_b):
	mouse_input(event)

func _on_animated_sprite_2d_animation_finished():
	if playerSprite.animation == "throw":
		throwing = false

func _on_animated_sprite_2d_animation_changed():
	if playerSprite == null:
		return
	if playerSprite.animation != "throw":
		throwing = false

