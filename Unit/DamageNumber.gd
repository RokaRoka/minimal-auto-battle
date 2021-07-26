extends Label

var anima := Anima.begin(self, 'sequence_and_parallel')

signal animDone

func playHit(num = null):
	if num != null:
		text = str(num)
	show()
	anima.clear()
	anima.then({node = self, animation = "bounce",\
		duration = 0.25, \
	})
	anima.connect("animation_completed", self, "animDone", [], CONNECT_ONESHOT)
	anima.play()

func animDone():
	yield(get_tree().create_timer(0.5), "timeout")
	hide()
	emit_signal("animDone")
