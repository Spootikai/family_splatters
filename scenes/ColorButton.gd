extends TextureButton

export var color: Color

func _ready():
	self.modulate = color

func _on_TextureButton_pressed():
	self.find_parent("ColorPicker").button_pressed(color)
