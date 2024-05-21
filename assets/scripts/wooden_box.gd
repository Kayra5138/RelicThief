extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") /2

var being_carried = false

var lockMove = false
var minecartOffset = -20

func _physics_process(delta):
	transform.x = Vector2(1,0)
	transform.y = Vector2(0,1)
	if lockMove:
		return
	if being_carried:
		$CollisionShape2D.disabled = true
		$BoxTopCol/CollisionShape2D.disabled = true
		velocity = Vector2.ZERO
	else:
		$CollisionShape2D.disabled = false
		$BoxTopCol/CollisionShape2D.disabled = false
		velocity.y += delta*gravity
	move_and_slide()

func lockMovement():
	lockMove = true

func releaseMovement():
	lockMove = false

func explode():
	queue_free()
