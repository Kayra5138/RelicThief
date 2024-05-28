extends Node2D

@onready var player:Player = get_tree().get_first_node_in_group("player")

var no_blood = false

func _ready():
	Engine.max_fps = 60
	for cultist in get_tree().get_nodes_in_group("cultist"):
		cultist.connect("dominateMe",wantsDomination)
		cultist.connect("letGoPls", letGoBuddy)
	for skill_object in get_tree().get_nodes_in_group("skill_object"): #Ice Columns are skill objects
		skill_object.connect("can_i_do",checkIfPlayerCan)
	for ui_skill:Node2D in get_tree().get_nodes_in_group("ui_skill"):
		match ui_skill.name.split(".")[0]:
			"InfSkill":
				player.skill = INF
			"NoBlood":
				no_blood = true
			"NoSpike":
				player.no_spike = true

func checkIfPlayerCan(skill_object):
	if not player.dominating and not player.carrying and player.skill > 0:
		skill_object.do_skill()
		player.skill -= 1

func wantsDomination(cultist):
	if no_blood:
		return
	player.dominate(cultist)

func letGoBuddy():
	player.stopDominate()
		
func _input(event : InputEvent):
	if event.is_action_pressed("restart"):
		reload()
		
func _on_animation_player_animation_finished(anim):
	if anim == "restart":
		get_tree().reload_current_scene()

func reload():
	$AnimationPlayer.play("restart")
