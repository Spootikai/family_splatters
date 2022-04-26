extends Node2D

var player_instance = preload("res://scenes/Player.tscn")

func _input(event):
	if Input.is_action_just_released("ui_up"):
		Server.startGame(PlayerSettings.game_id)

func replicatePlayer(s_id):
	var new_player_instance = player_instance.instance()
	self.add_child(new_player_instance)
	new_player_instance.game_id = s_id
