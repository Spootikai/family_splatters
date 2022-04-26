extends Control

onready var await_server = false

func _ready():
	pass 

func button_pressed(color):
	await_server = true
	PlayerSettings.color = color
	Server.requestPlayerSettings(color, PlayerSettings.title, self.get_instance_id())

func acceptPlayerSettings():
	queue_free()

func denyPlayerSettings(type):
	if type == "title":
		PlayerSettings.title = str(Server.self_id)
	if type == "color":
		await_server = false
