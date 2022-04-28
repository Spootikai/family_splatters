extends Control

onready var await_server = false

func _ready():
	Server.connect("server_update", self, "_on_server_update")

	# Update the buttons if the color picker has been made after lobby creation/
	# Jank
	if Server.players != null:
		button_update()

func _on_server_update():
	button_update()

func button_update():
	for button in $Panel/GridContainer.get_children():
		for p_id in Server.players.size():
			var player = Server.players[Server.players.keys()[p_id]]
			
			# Disable buttons that are being used by other players
			if button.color.to_html() == player.color:
				button._disable()
				break
			else:
				# If the button isnt being used by other players enable it
				button._enable()

func button_pressed(color):
	Server.fetchColorAvailable(color, self.get_instance_id())

func returnColorAvailable(color, s_value):
	match s_value:
		true:
			Server.fetchLobbyJoin(color, PlayerSettings.title)
			queue_free()
		false:
			for button in $Panel/GridContainer.get_children():
				if button.color.to_html() == color:
					button._disable()
