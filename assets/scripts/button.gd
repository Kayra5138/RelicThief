extends Area2D

@export var list_of_doors:Array[Door]

var pressed = false
var pressedrn = false

func _process(_delta):
	if len(get_overlapping_bodies()) == 0:
		pressedrn = false
	else:
		pressedrn = true
	if pressed != pressedrn:
		if pressedrn:
			$Top.animation = "pressed"
			$PressAudio.play()
			for door in list_of_doors:
				door.open()
		else:
			$Top.animation = "unpressed"
			$UnpressAudio.play()
			for door in list_of_doors:
				door.close()
	pressed = pressedrn
		
		
