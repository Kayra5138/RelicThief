extends CharacterBody2D

var direction = 1
var icespikevelocity = Vector2(direction,0)
var speed = 500
var disappearing = 0
var lifetime = 50
func _physics_process(delta):
	if disappearing:
		$GPUParticles2D.emitting = false
		speed = 0
		lifetime += -1
	if lifetime == 48:
		$ShatterAudio.play()
	if lifetime < 0:
		queue_free()
	move_and_collide(icespikevelocity.normalized()*delta*speed)



func _on_hitbox_body_entered(body):
	if body.has_meta("puffball") and !disappearing:
		disappearing = 1
		lifetime = 50
		$AnimatedSprite2D.animation = "impact"
	elif !disappearing and !body.has_meta("spike"):
		disappearing = 1
		$AnimatedSprite2D.animation = "impact"
