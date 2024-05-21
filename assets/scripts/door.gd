extends StaticBody2D

@onready var area: Area2D = $Area2D

var tmp = []

func open():
	tmp.append(1)
	fln()
	
func close():
	tmp.pop_back()
	fln()

func fln():
	if len(tmp) == 0 and len(area.get_overlapping_bodies()) == 0:
		$CollisionShape2D.set_deferred("disabled", false);
		$AnimatedSprite2D.animation = "default";
	else:
		$CollisionShape2D.set_deferred("disabled", true);
		$AnimatedSprite2D.animation = "open";

func _on_area_2d_body_exited(body):
	fln()
