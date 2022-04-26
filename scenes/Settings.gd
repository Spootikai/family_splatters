
extends Control


# Declare member variables here. Examples:



# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	




func _on_TextureButton_pressed():
	queue_free()


func _on_VolumeSlider_value_changed(value):
	$Panel/VolumeLabel.text = str(value)

