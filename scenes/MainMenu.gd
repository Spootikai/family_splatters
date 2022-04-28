
extends Control

func _on_Button_pressed():
	Server.connect_to_server($VBoxContainer/Adress.text)
	_update()

func _update():
	PlayerSettings.title = $VBoxContainer/Username.text

# Update player settings
func _on_Username_text_changed():
	_update()