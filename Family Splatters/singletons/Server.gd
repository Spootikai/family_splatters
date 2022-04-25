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
	# Upon sucessfully connecting to the server, assign your self_id as your network peer_id
	# Move scenes to the lobby and wait for the game to start
	self_id = get_tree().get_network_unique_id()
	get_tree().change_scene("res://scenes/Lobby.tscn")

# Send over player settings
remote func fetchPlayerSettings():
	rpc_id(1, "returnPlayerSettings", PlayerSettings.color, PlayerSettings.title)

# Become "host" if the server deems you worthy uwu
remote func playerIsHost():
	PlayerSettings.is_host = true

# Fetch player data (username, color, mode)
func fetchPlayerData(peer_id, requester):
	rpc_id(1, "fetchPlayerData", peer_id, requester)
remote func returnPlayerData(s_mode, s_title, s_color, requester):
	instance_from_id(requester).setPlayerData(s_mode, s_title, Color(s_color))

# Request to start game
func startGame(id):
	rpc_id(1, "startGame", id)
