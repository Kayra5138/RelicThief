extends CharacterBody2D

var direction = 1
var icespikevelocity = Vector2(direction,0)
var speed = 500
var disappearing = 0
var lifetime = 50
func _physics_process(delta):
	if disappearing:
		speed = 0
		lifetime += -1
	if lifetime == 45:
		$ShatterAudio.play()
	if lifetime < 0:
		queue_free()
	move_and_collide(icespikevelocity.normalized()*delta*speed)



func _on_hitbox_body_entered(body):
	if body.has_meta("puffball"):
		disappearing = 1
		lifetime = 1
	if !disappearing and !body.has_meta("spike"):
		disappearing = 1
		$AnimatedSprite2D.animation = "impact"
