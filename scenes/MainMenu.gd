
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


func _on_TextureButton_toggled(button_pressed):
	pass

func _on_TextureButton_pressed():
	var settings_menu_instance = preload("res://scenes/Settings.tscn")
	var new_menu = settings_menu_instance.instance()
	self.add_child(new_menu)

