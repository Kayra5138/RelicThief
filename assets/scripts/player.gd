extends CharacterBody2D
class_name Player

@onready var shadow:Sprite2D = $BoxShadow
@onready var default_shadow_pos = shadow.position
@onready var shadow_casts:Node2D = $shadow_casts

@export var can_dominate = true
@export var can_spike = true
@export var speed = 140
@export var jump_speed = -500
@export_range(0.0, 1.0) var friction = 0.25
@export_range(0.0 , 1.0) var acceleration = 0.25
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing = 0 #right: 1 - left: 0
@export var skill = 5
var FLOOR_NORMAL = Vector2.UP
@onready var playerSprite = $PlayerSprite 
const ice_spike_path = preload("res://assets/skills/icespike.tscn")
var coyoteJumpTimer = 15
var lockControls = false
var minecartOffset = -35
const CLIMB_SPEED = 100
enum {sMOVE, sCLIMB}
var curState = sMOVE
var throwing = false
var is_dead = false
var dominating = null

@onready var Hitbox:Area2D = $Hitbox
@onready var Remote:RemoteTransform2D = $RemoteTransform2D
@onready var putDownLoc:Node2D = $putDownLoc
var carrying:CharacterBody2D = null

@onready var topCol:CollisionShape2D = $TopCollision/CollisionShape2D
@onready var pick_center:Node2D = $Box_Picking_Center

var no_spike = false

func _ready():
	playerSprite.material.set_shader_parameter("tint_factor", 0)
	$TankSprite.material.set_shader_parameter("tint_factor", 0)
	$ChainsSprite.material.set_shader_parameter("tint_factor", 0)

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
	if not is_on_floor():
		velocity.y += gravity * delta
	#Setting max speed
	velocity.y = min(velocity.y, 700)
	velocity.x = lerp(velocity.x, 0.0, friction)
	move_and_slide()

func putDownColliding() -> bool:
	var putdown_colliding = false
	for raycast in $boxPutdownChecks.get_children():
		if raycast.is_colliding():
			putdown_colliding = true
			break
	return putdown_colliding

func _physics_process(delta):
	if is_dead: return
	match skill:
		5: 
			$TankSprite.animation = "5"
			$TankLight.energy = 0.45
		4: 
			$TankSprite.animation = "4"
			$TankLight.energy = 0.4
		3: 
			$TankSprite.animation = "3"
			$TankLight.energy = 0.35
		2:
			$TankSprite.animation = "2"
			$TankLight.energy = 0.3
		1: 
			$TankSprite.animation = "1"
			$TankLight.energy = 0.25
		0: 
			$TankSprite.animation = "0"
			$TankLight.energy = 0.2
	if dominating:
		domination(delta)
		return
		
	ladder_check()
	if curState == sCLIMB:
		climbing_state()
		return
	if lockControls:
		playerSprite.animation = "idle" if not carrying else "carrying idle"
		if facing == 0:
			transform.x.x = -1
		if facing == 1:
			transform.x.x = 1
		if carrying: #This is what keeps the box straight inside minecart ¯\_(ツ)_/¯
			carrying.transform.x = Vector2(1,0)
			carrying.transform.y = Vector2(0,-1) if facing==0 else Vector2(0,1)
		return
	
	#Box Shadow Calculation
	if carrying and is_on_floor() and not putDownColliding():
		shadow.visible = true
		var highest = default_shadow_pos.y
		for ray:RayCast2D in shadow_casts.get_children():
			if ray.is_colliding():
				var relative_coord = (ray.get_collision_point() - position).y - 16
				if relative_coord < highest:
					highest = relative_coord
		shadow.position.y = highest
	else:
		shadow.visible = false
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
	
	#if Input.is_action_just_pressed("restart"): restart()
	
	if throwing == false:
		if Input.is_action_pressed("left"):
			if is_on_floor():
				var tmp = "walk" if not carrying else "carrying walk"
				playerSprite.animation = tmp
				playerSprite.play(tmp)
			facing = 0
		if Input.is_action_pressed("right"):
			if is_on_floor(): 
				var tmp = "walk" if not carrying else "carrying walk"
				playerSprite.animation = tmp
				playerSprite.play(tmp)
			facing = 1
		if Input.is_action_just_pressed("interact") and is_on_floor():
			if carrying == null:
				var pickup_colliding = false
				for raycast in $boxPickupChecks.get_children():
					if raycast.is_colliding():
						pickup_colliding = true
						break
				if not pickup_colliding:
					var min_box_dist = INF
					var tmp_box = null
					for tmp in Hitbox.get_overlapping_areas():
						if tmp.is_in_group("pickup"):
							var vec = -pick_center.global_position + tmp.global_position
							vec.x *= -1 if facing == 0 else 1
							if vec.x < 0 or vec.length() >= min_box_dist:
								continue
							min_box_dist = vec.length()
							tmp_box = tmp.get_parent()
					if tmp_box:
						#Carrylemeye karr verdim
						carrying = tmp_box
						carrying.being_carried = true
						carrying.transform.x.x = 1
						$CarriedBoxCollision.disabled = false
						$PlayerCollision.disabled = true
						$TopCollision/CollisionShape2D.disabled = true
						Remote.remote_path = carrying.get_path()
			else:
				var putdown_colliding = false
				for raycast in $boxPutdownChecks.get_children():
					if raycast.is_colliding():
						putdown_colliding = true
						break
				if not putdown_colliding:
					#Carry bitirmeye karar verdm
					Remote.remote_path = ""
					$CarriedBoxCollision.disabled = true
					$PlayerCollision.disabled = false
					$TopCollision/CollisionShape2D.disabled = false
					carrying.position = putDownLoc.global_position
					carrying.being_carried = false
					carrying = null
			
	if (Input.is_action_just_released("right") or Input.is_action_just_released("left")):
		playerSprite.animation = "idle" if not carrying else "carrying idle"
	
	if !is_on_floor():
		playerSprite.animation = "jump" if not carrying else "carrying jump"
		if coyoteJumpTimer > 0:
			coyoteJumpTimer += -1
	
	if is_on_floor():
		coyoteJumpTimer = 15
		if velocity.x == 0:
			if throwing == true:
				playerSprite.animation = "throw"
			else:
				var tmp = "idle" if not carrying else "carrying idle"
				playerSprite.animation = tmp
				playerSprite.play(tmp)

	if (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("up")) and (is_on_floor() or coyoteJumpTimer>0):
		velocity.y = jump_speed
		coyoteJumpTimer = 0

	if Input.is_action_pressed("shoot") and $IceSpikeCooldown.is_stopped() and skill > 0 \
	and !$IceSpikeCollideCheck.is_colliding() and is_on_floor() and not carrying and not no_spike:
		skill -= 1
		shoot_ice_spike()
		
	if Input.is_action_just_pressed("down"):
		position.y += 1
		skill = 5 #DEBUG
	if facing == 0:
		transform.x.x = -1 # This makes the box rotate indefinitely... why tho
	if facing == 1:
		transform.x.x = 1
	if carrying: # This corrects the rotation ¯\_(ツ)_/¯
		carrying.transform.x = Vector2(1,0)
		carrying.transform.y = Vector2(0,1)

func shoot_ice_spike():
	throwing = true
	var ice_spike = ice_spike_path.instantiate()
	$IceSpikeCooldown.start(1)
	get_parent().add_child(ice_spike)
	ice_spike.position = $IceSpikePosition.global_position
	if !facing:
		ice_spike.icespikevelocity.x = -1
		ice_spike.scale.x = -1

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

func _on_hitbox_body_entered(body):
	if body.has_meta("enemy"):
		restart()

func lockMovement():
	playerSprite.animation = "idle" if not carrying else "carrying idle"
	lockControls = true

func releaseMovement():
	lockControls = false
	if carrying:
		carrying.transform.x = Vector2(1,0)
		carrying.transform.y = Vector2(0,1)

func ladder_check():
	if $LadderCheck.get_collider() is Ladder and not carrying:
		curState = sCLIMB
		topCol.set_deferred("disabled",true)
	else:
		curState = sMOVE
		topCol.set_deferred("disabled",false)

func mouse_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if dominating != null:
				dominating.dominated = false
				dominating = null
				releaseMovement()

func _on_hitbox_input_event(_a, event, _b):
	mouse_input(event)

func _on_animated_sprite_2d_animation_finished():
	if playerSprite.animation == "throw":
		throwing = false

func _on_animated_sprite_2d_animation_changed():
	if playerSprite == null:
		return
	if playerSprite.animation != "throw":
		throwing = false

func restart():
	is_dead = true
	var tmp = carrying
	if tmp:
		tmp.explode()
	playerSprite.animation = "jump"
	$AnimationPlayer.play("Death")
	

func _on_animation_player_animation_finished(anim):
	if anim == "Death":
		get_parent().reload()
