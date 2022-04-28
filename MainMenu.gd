
extends Control

func _on_Button_pressed():
	if $VBoxContainer/Adress.text == "Server":
		$VBoxContainer/Adress.text = "35.160.170.69"
	Server.connect_to_server($VBoxContainer/Adress.text)
	_update()

func _update():
	PlayerSettings.title = $VBoxContainer/Username.text

# Update player settings
func _on_Username_text_changed():
	_update()
