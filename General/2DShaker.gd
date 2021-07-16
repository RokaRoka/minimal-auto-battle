extends Node2D

var originalPosition := Vector2()
export(NodePath) var pathToNode = NodePath("..")

#runtime
var nodeToShake: Node2D
var anima := Anima.begin(self, 'sequence_and_parallel')

signal shakeDone

func _ready():
	nodeToShake = get_node_or_null(pathToNode)
	makeAnimations()

func makeAnimations():
	Anima.register_animation(self, 'shake_animation')

func hShake(strength: float = 4.0):
	anima.clear()
	anima.then({node = nodeToShake, animation = "shake_animation",\
		duration = 0.2, \
	})
	anima.connect("animation_completed", self, "emit_signal", ["shakeDone"], CONNECT_ONESHOT)
	anima.play()

func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	if data.animation == 'shake_animation':
		shake_animation(anima_tween, data)
		return

func shake_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var start = AnimaNodesProperties.get_position(data.node)

	var shake_frames = [
		{ percentage = 0, from = 0 },
		{ percentage = 30, to = 4 },
		{ percentage = 50, to = -4 },
		{ percentage = 70, to = -4 },
		{ percentage = 100, to = 4 },
	]

	anima_tween.add_relative_frames(data, "x", shake_frames)
