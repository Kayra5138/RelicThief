extends Node2D

func _ready():
	for child in get_children():
		if child is Button:
			child.connect("got_pressed",level_pressed)

func level_pressed(level):
	get_tree().change_scene_to_file("res://levels/level_%s.tscn"%[level])
