
extends Control

onready var colorpicker_instance = preload("res://scenes/ColorPicker.tscn")
onready var lobby_icon_instance = preload("res://scenes/LobbyIcon.tscn")

func _ready():
	var new_colorpicker = colorpicker_instance.instance()
	$CenterContainer.add_child(new_colorpicker)

func _process(delta):
	$CenterContainer/Button.disabled = !PlayerSettings.is_host

func playerJoinLobby(game_id):
	var new_lobby_icon = lobby_icon_instance.instance()
	$HBoxContainer.add_child(new_lobby_icon)
	Server.fetchPlayerData(game_id, new_lobby_icon.get_instance_id())