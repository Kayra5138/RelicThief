extends Area2D

@export var list_of_doors:Array[StaticBody2D]

func _on_body_entered(_body):
	$AnimatedSprite2D.animation = "pressed"
	$PressAudio.play()
	for door in list_of_doors:
		door.open();

func _on_body_exited(_body):
	$AnimatedSprite2D.animation = "unpressed"
	$UnpressAudio.play()
	for door in list_of_doors:
		door.close();
