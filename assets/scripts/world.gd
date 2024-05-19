extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	for cultist in get_tree().get_nodes_in_group("cultist"):
		cultist.connect("dominateMe",wantsDomination)
		cultist.connect("letGoPls", letGoBuddy)
	for skill_object in get_tree().get_nodes_in_group("skill_object"): #Ice Columns are skill objects
		skill_object.connect("can_i_do",checkIfPlayerCan)

func checkIfPlayerCan(skill_object):
	if not player.dominating and not player.carrying and player.skill > 0:
		skill_object.do_skill()
		player.skill -= 1

func wantsDomination(cultist):
	player.dominate(cultist)

func letGoBuddy():
	player.stopDominate()
		
func _input(event : InputEvent):
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
