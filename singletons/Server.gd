extends Node


var self_id
var network = NetworkedMultiplayerENet.new()

func connect_to_server(ip = "127.0.0.1", port = 18181):
	network.create_client(ip, port)
	get_tree().set_network_peer(network)

	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")

func _on_connection_failed():
	print("Failed to connect")

func _on_connection_succeeded():
	print("Successfully connected")

	get_tree().change_scene("res://scenes/Lobby.tscn")
	self_id = get_tree().get_network_unique_id()

# Player settings
# Make sure to set colors to ARGB64 and revert back after sending
func requestPlayerSettings(color, title, requester):
	rpc_id(1, "requestPlayerSettings", color.to_argb64(), title, requester)

remote func acceptPlayerSettings(requester):
	instance_from_id(requester).acceptPlayerSettings()

remote func denyPlayerSettings(type, requester):
	instance_from_id(requester).denyPlayerSettings(type)

# Request to start game
func startGame(id):
	rpc_id(1, "startGame", id)
