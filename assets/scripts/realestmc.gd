extends Path2D

enum{waitingA,finishedA,goingB,waitingB,finishedB,goingA}
var curState = waitingA



var riding = null
@onready var ogPos = $PathFollow2D/minecart/RemoteTransform2D.position.y
@onready var myCol:CollisionShape2D = $PathFollow2D/minecart/CollisionShape2D

@export var speed = 1.0
@export var reversed = false

@onready var anime = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	$PathFollow2D/minecart/inside.connect("body_entered",entered)
	$PathFollow2D/minecart/inside.connect("body_exited",exited)
	anime.connect("animation_finished",animeEnded)
	$AnimationPlayer.speed_scale = speed
	if reversed:
		$PathFollow2D.progress_ratio = 1
		curState = waitingB

func entered(body):
	if not body.is_in_group("riding") or riding != null or curState == goingA or curState == goingB:
		return
	$PathFollow2D/minecart/RemoteTransform2D.position.y = ogPos + body.minecartOffset
	$PathFollow2D/minecart/RemoteTransform2D.remote_path = body.get_path()
	match curState:
		waitingA:
			anime.play("goB")
			myCol.set_deferred("disabled",true)
			curState = goingB
			body.lockMovement()
			if body.is_in_group("cultist"):
				if not body.facing:
					body.flip()
				$PathFollow2D/minecart/RemoteTransform2D.scale.x = 1
			else:
				$PathFollow2D/minecart/RemoteTransform2D.scale.x = 1
			riding = body
		waitingB:
			anime.play("goA")
			myCol.set_deferred("disabled",true)
			curState = goingA
			body.lockMovement()
			if body.has_meta("Player"):
				$PathFollow2D/minecart/RemoteTransform2D.scale.x = -1
			elif body.is_in_group("cultist"):
				if body.facing:
					body.facing = false
				$PathFollow2D/minecart/RemoteTransform2D.scale.x = -1
			else:
				$PathFollow2D/minecart/RemoteTransform2D.scale.x = 1
			riding = body

func exited(body):
	if not body.is_in_group("riding") or (riding != null and riding != body):
		return
	match curState:
		finishedA:
			curState = waitingA
		finishedB:
			curState = waitingB

func animeEnded(_ok):
	match curState:
		goingA:
			curState = finishedA
			if riding != null:
				if riding.is_in_group("cultist") and riding.facing:
					riding.flip()
		goingB:
			if riding != null:
				if riding.is_in_group("cultist") and not riding.facing:
					riding.flip()
			curState = finishedB

	if riding != null:
		riding.releaseMovement()
		riding.velocity = Vector2.ZERO
		riding = null
	else:
		match curState:
			finishedA:
				curState = waitingA
			finishedB:
				curState = waitingB
	myCol.set_deferred("disabled",false)
	$PathFollow2D/minecart/RemoteTransform2D.remote_path = ""
	$PathFollow2D/minecart/RemoteTransform2D.position.y = ogPos


