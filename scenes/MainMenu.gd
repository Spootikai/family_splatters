extends Control

func _on_Button_pressed():
	Server.connect_to_server($VBoxContainer/Adress.text)

# Update player settings
func _on_ColorPickerButton_color_changed(color):
	PlayerSettings.color = color.to_rgba64()

func _on_Username_text_changed():
	PlayerSettings.title = $VBoxContainer/Username.text
