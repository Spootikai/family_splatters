extends Control

onready var lobby_icon_instance = preload("res://scenes/LobbyIcon.tscn")

func _ready():
	get_tree().get_node("/root/ColorPicker").queue_free()
	if PlayerSettings.is_host:
		$Button.disabled = false

func playerJoinLobby(peer_id):
	var new_lobby_icon = lobby_icon_instance.instance()
	$HBoxContainer.add_child(new_lobby_icon)
	Server.fetchPlayerData(peer_id, new_lobby_icon.get_instance_id())
