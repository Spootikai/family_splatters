extends Control

onready var await_server = false

func _ready():
	Server.fetchPlayerData()

func button_pressed(color):
	PlayerSettings.color = color
	Server.requestPlayerSettings(color.to_html(), PlayerSettings.title, self.get_instance_id())

func acceptPlayerSettings():
	queue_free()
	Server.fetchPlayerData()


func denyPlayerSettings(type):
	if type == "title":
		PlayerSettings.title = str(Server.self_id)
	if type == "color":
		PlayerSettings.color = Color(250, 250, 250).to_html()

