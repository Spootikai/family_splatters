extends Control

onready var await_server = false

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
