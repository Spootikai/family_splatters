extends Control

onready var colorpicker_instance = preload("res://scenes/ColorPicker.tscn")


func _ready():
	var new_colorpicker = colorpicker_instance.instance()
	$CenterContainer.add_child(new_colorpicker)

func _process(delta):
	# Every tick the button will be enabled if the player is host, and disabled otherwise
	$CenterContainer/Button.disabled = !PlayerSettings.is_host

	# Recreate the colorpicker
	if get_node_or_null("CenterContainer/ColorPicker") == null:
		if Input.is_action_just_pressed("escape"):
			var new_colorpicker = colorpicker_instance.instance()
			$CenterContainer.add_child(new_colorpicker)

func _on_Button_pressed():
	Server.startGameRequest()

var lobby_icon_instance = preload("res://scenes/LobbyIcon.tscn")
func updateLobbyIcons():
	if $IconHolder.get_child_count() == Server.players.keys().size():
		for i in Server.players.keys().size():
			var child = $IconHolder.get_child(i)
			var key = Server.players.keys()[i]
			
			child.get_node("Sprite").modulate = Server.players[key][0]
			child.get_node("Label").text = Server.players[key][1]
	else:
		if $IconHolder.get_child_count() < Server.players.keys().size():
			var new_lobby_icon = lobby_icon_instance.instance()
			$IconHolder.add_child(new_lobby_icon)
		if $IconHolder.get_child_count() > Server.players.keys().size():
			for child in $IconHolder.get_children():
				if Server.players.keys().find(child.player_id):
					pass
				else:
					child.queue_free()
