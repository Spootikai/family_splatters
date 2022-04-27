
extends Node2D

var player_instance = preload("res://scenes/Player.tscn")

func replicatePlayer(s_id):
	var new_player_instance = player_instance.instance()
	self.add_child(new_player_instance)
	new_player_instance.game_id = s_id
