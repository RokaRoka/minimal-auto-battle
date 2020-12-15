extends TextureRect

var dragging = false

signal started_drag( draggable )
signal dropped( draggable )

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("gui_input", self, "_on_gui_input")

func _on_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			dragging = true
			emit_signal("started_drag", self)
		elif dragging:
			dragging = false
			emit_signal("dropped", self)
	if event is InputEventMouseMotion and dragging:
		rect_position += event.relative
