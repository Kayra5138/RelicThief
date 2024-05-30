extends Node2D

func _ready():
	for child in get_children():
		if child is Button:
			child.connect("got_pressed",level_pressed)

func _process(_delta):
	if Input.is_action_just_pressed("returnToMenu"):
		get_tree().change_scene_to_file("res://main.tscn")

func level_pressed(level):
	get_tree().change_scene_to_file("res://levels/level_%s.tscn"%[level])
