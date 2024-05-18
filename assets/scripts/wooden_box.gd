extends RigidBody2D

const SPEED = 300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var being_carried = false

func _physics_process(delta):
	if being_carried:
		linear_velocity = Vector2.ZERO

func explode():
	queue_free()
