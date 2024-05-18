extends Area2D

var danger = true

func _on_animated_sprite_2d_animation_finished():
	self.queue_free()


func _on_body_entered(body):
	if danger and not body.is_in_group("strong"):
		body.explode()

var frameCount = 0
func _on_animated_sprite_2d_frame_changed():
	frameCount += 1
	if frameCount > 4:
		danger = false
