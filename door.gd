extends StaticBody2D

func open():
	$CollisionShape2D.set_deferred("disabled", true);
	$AnimatedSprite2D.animation = "open";
	
func close():
	$CollisionShape2D.set_deferred("disabled", false);
	$AnimatedSprite2D.animation = "default";
