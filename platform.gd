extends StaticBody2D

enum PlatformType {
	Left,
	Right,
	Middle,
	Double
}
@export var type: PlatformType = PlatformType.Double

func _ready():
	match type:
		0: $AnimatedSprite2D.animation = "left"
		1: $AnimatedSprite2D.animation = "right"
		2: $AnimatedSprite2D.animation = "middle"
		3: $AnimatedSprite2D.animation = "double"
