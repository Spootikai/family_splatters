
extends Control

func _on_Button_pressed():
	Server.connect_to_server($VBoxContainer/Adress.text)

func _ready():
	_on_Username_text_changed()

# Update player settings
func _on_Username_text_changed():
	PlayerSettings.title = $VBoxContainer/Username.text
