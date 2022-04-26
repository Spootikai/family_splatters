extends Control

func setPlayerData(s_mode, s_title, s_color):
	$VBoxContainer/TextureRect.modulate = s_color
	$VBoxContainer/Label.text = s_title
