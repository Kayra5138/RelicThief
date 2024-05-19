extends CharacterBody2D

const explosionScene = preload("res://assets/characters/explosion.tscn")

var lockMove = false
var minecartOffset = -24

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") / 2.5

enum {SLEEP,SEARCH, PURSUE}
var state = SLEEP
var agitation = 0
var agitationLimit = 8
var charge = 0
var chargeLimit = 5
var agitation_delta_multiplier = 10

var speed = -300
var nudge = 300

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
		velocity.x = 0
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
	var tmp_delta = agitation_delta_multiplier * delta
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
					agitation += tmp_delta
				else:
					agitation -= tmp_delta
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
				var target = targetHere(bodies)
				var vec:Vector2 = target.position - position
				if charge > chargeLimit and is_on_floor():
					velocity = Vector2.from_angle(PI*110/180)*speed if vec.x > 0 else Vector2.from_angle(PI*70/180)*speed
					charge = 0
				elif is_on_floor():
					charge += tmp_delta
				elif velocity.x == 0:
					velocity.x = -nudge*delta if vec.x > 0 else nudge*delta
			else:
				if charge > 0:
					charge -= tmp_delta
				else:
					agitation -= tmp_delta
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

func _on_area_2d_body_entered(body):
	if body != self:
		exploding = true
