extends PanelContainer

var anima := Anima.begin(self, 'sequence_and_parallel')

signal animDone

func _ready():
	makeAnimations()

func blink():
	show()
	anima.clear()
	anima.then({node = self, animation = "blink",\
		duration = 0.75, \
	})
	anima.connect("animation_completed", self, "animDone", [], CONNECT_ONESHOT)
	anima.play()

func animDone():
	#yield(get_tree().create_timer(0.5), "timeout")
	hide()
	emit_signal("animDone")

func makeAnimations():
	Anima.register_animation(self, 'blink')

func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var frames = [
		{ percentage = 0, from = 1 },
		{ percentage = 33, to = 0 },
		{ percentage = 66, to = 1 },
		{ percentage = 100, to = 0 },
	]

	anima_tween.add_frames(data, "opacity", frames)
