extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") /2

var being_carried = false

func _physics_process(delta):
	if being_carried:
		$CollisionShape2D.disabled = true
		velocity = Vector2.ZERO
	else:
		$CollisionShape2D.disabled = false
		velocity.y += delta*gravity
	move_and_slide()


func explode():
	queue_free()
