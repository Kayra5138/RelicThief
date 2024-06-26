extends Area2D

var current_level
var next_level_number
var next_level_path

signal next_level

func _on_body_entered(body):
	if body.has_meta("Player"):
		next_level.emit()

func go_next_level():
	current_level = get_tree().current_scene.scene_file_path
	next_level_number = current_level.to_int() + 1
	next_level_path = "res://levels/level_" + str(next_level_number) + ".tscn"
	get_tree().change_scene_to_file(next_level_path)
