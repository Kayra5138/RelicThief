extends Button

var level = "1"
signal got_pressed

func _ready():
	level = text.strip_edges()

func _on_pressed():
	got_pressed.emit(level)
