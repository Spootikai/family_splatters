extends Control

onready var lobby_icon_instance = preload("res://scenes/LobbyIcon.tscn")

func _ready():
	if PlayerSettings.is_host:
		$Button.disabled = false

func playerJoinLobby(game_id):
	var new_lobby_icon = lobby_icon_instance.instance()
	$HBoxContainer.add_child(new_lobby_icon)
	Server.fetchPlayerData(game_id, new_lobby_icon.get_instance_id())
