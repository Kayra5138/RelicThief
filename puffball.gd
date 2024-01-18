extends CharacterBody2D

const explosionScene = preload("res://explosion.tscn")

var lockMove = false
var minecartOffset = -8

const SPEED = 400.0
const JUMP_VELOCITY = -500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")/2

enum {SLEEP,SEARCH, PURSUE}
var state = SLEEP
var agitation = 0
var agitationLimit = 50
var charge = 0
var chargeLimit = 50

var speed = 150

var exploding = false
var explosionCharge = 0
var explosionLimit:float = 45

var sleep = "eepy"
var pursue = "pursue"
var search = "search"
var purJump = "pursue_jump"
var explodeAnim = "explode"

var cur_target = null

func targetHere(bodies):
	if len(bodies) == 0:
		return null
	var found = null
	var dist = INF
	for i in bodies:
		if i.is_in_group("puffTarget"):
			if i == self:
				continue
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(global_position, i.position,
				collision_mask, [self])
			var result = space_state.intersect_ray(query)
			if(result.has("collider") and (not result.collider.is_in_group("puffTarget")) ):
				continue
			if position.distance_to(i.position) < dist:
				found = i
				dist = position.distance_to(i.position)
	return found

var resultx = false
func turnToPlayer(bodies):
	var target = targetHere(bodies)
	if target != null:
		if target.position.x > position.x:
			resultx = true
		else:
			resultx = false
	return resultx

func _physics_process(delta):
	var reddening_factor = 1/explosionLimit
	if is_on_floor():
		velocity = Vector2.ZERO
	else:
		velocity.y += delta* gravity
	if exploding:
		$AnimatedSprite2D.animation = explodeAnim
		explosionCharge += 1
		$AnimatedSprite2D.modulate -= Color(0,reddening_factor,reddening_factor,0)
		if explosionCharge > explosionLimit:
			var explosion = explosionScene.instantiate()
			explosion.position = position
			get_parent().add_child(explosion)
			self.queue_free()
		if not lockMove:
			move_and_slide()
		return
	var bodies = $Vision.get_overlapping_bodies()
	match state:
		SLEEP:
			$AnimatedSprite2D.animation = sleep
			$AnimatedSprite2D.flip_h = turnToPlayer(bodies)
			if targetHere(bodies) != null:
				state = SEARCH
		SEARCH:
			$AnimatedSprite2D.animation = search
			$AnimatedSprite2D.flip_h = turnToPlayer(bodies)
			if agitation > agitationLimit:
				state = PURSUE
			else:
				if targetHere(bodies) != null:
					agitation += 1
				else:
					agitation -= 1
				if agitation <= 0:
					agitation = 0
					state = SLEEP
		PURSUE:
			if is_on_floor():
				$AnimatedSprite2D.animation = pursue
			else:
				$AnimatedSprite2D.animation = purJump
			$AnimatedSprite2D.flip_h = not turnToPlayer(bodies)
			if targetHere(bodies) != null:
				agitation = agitationLimit
				if charge > chargeLimit:
					var target = targetHere(bodies)
					var vec:Vector2 = target.position - position
					velocity = Vector2(speed,-speed) if vec.x > 0 else Vector2(-speed,-speed)
					charge = 0
				else:
					charge += 1
			else:
				if charge > 0:
					charge -= 1
				else:
					agitation -= 1
				if agitation < agitationLimit/2.0:
					state = SEARCH
					agitation = agitationLimit
	if not lockMove:
		move_and_slide()

func _on_danger_zone_body_entered(body):
	if body.is_in_group("puffTarget"):
		exploding = true

func lockMovement():
	lockMove = true

func releaseMovement():
	lockMove = false		

func explode():
	queue_free()
