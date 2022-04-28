extends TextureButton

export var color: Color
onready var pale_weight = 0.2

func _ready():
	_enable()

func _disable():
	self.modulate = color.blend(Color(0, 0, 0, pale_weight))
	self.flip_h = true
	self.disabled = true

func _enable():
	self.modulate = color
	self.flip_h = false
	self.disabled = false

func _on_TextureButton_pressed():
	self.find_parent("ColorPicker").button_pressed(color.to_html())
