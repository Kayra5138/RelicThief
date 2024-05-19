extends RigidBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var being_carried = false

func _physics_process(_delta):
	if being_carried:
		$CollisionShape2D.disabled = true
		linear_velocity = Vector2.ZERO
	else:
		$CollisionShape2D.disabled = false


func _integrate_forces(state):
	var vel = state.get_linear_velocity ()
	if vel.y < 0:
		vel.y = 0
	state.set_linear_velocity (Vector2 (0, vel.y))

func explode():
	queue_free()
