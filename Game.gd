extends Node2D

var player_instance = preload("res://scenes/Player.tscn")

func _ready():
	Server.loadGame()