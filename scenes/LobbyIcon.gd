extends Control

var player_id = -1

func _ready():
	Server.fetchPlayerData()
