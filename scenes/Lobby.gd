extends Control



onready var colorpicker_instance = preload("res://scenes/ColorPicker.tscn")
func _ready():
	Server.connect("server_update", self, "_on_server_update")
	Server.finishLoading()
	
	# Create an instance of the color picker menu as soon as the lobby is loaded
	var new_colorpicker = colorpicker_instance.instance()
	$CenterContainer.add_child(new_colorpicker)

func _process(delta):
	# Recreate the colorpicker if it has been closed
	if get_node_or_null("CenterContainer/ColorPicker") == null:
		if Input.is_action_just_pressed("color_picker"):
			var new_colorpicker = colorpicker_instance.instance()
			$CenterContainer.add_child(new_colorpicker)
	else:
		if Input.is_action_just_pressed("color_picker"):
			$CenterContainer.get_node("ColorPicker").queue_free()

onready var lobby_icon_instance = preload("res://scenes/LobbyIcon.tscn")
func _on_server_update():
	# Every update the button will be enabled if the player is host, and disabled otherwise
	$CenterContainer/Button.disabled = !PlayerSettings.is_host
	
	for icon in $IconHolder.get_children():
		icon.queue_free()
	
	for icon_number in Server.players.size():
		var new_lobby_icon = lobby_icon_instance.instance()
		$IconHolder.add_child(new_lobby_icon)

		for player_id in Server.players:
			var player = Server.players[player_id]
			print(player)
			if player.order == icon_number:
				new_lobby_icon.get_node("Sprite").modulate = player.color
				new_lobby_icon.get_node("Label").text = player.title

func _on_Button_pressed():
	Server.requestStartGame()
