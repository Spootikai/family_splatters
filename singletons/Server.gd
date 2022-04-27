extends Node


var self_id

var players = {}
var network = NetworkedMultiplayerENet.new()

# Automatically started once the server connection is established
var pinging = false
var ping_time_current = 0
var ping_time = 0
var ping_wait = false
var ping_interval = 3
var ping_interval_timer = 0

func connect_to_server(ip = "127.0.0.1", port = 18181):
	# Close pre existing connections just in case
	network.close_connection() 
	
	# Create the client on the network and attach it to the tree
	network.create_client(ip, port)
	get_tree().set_network_peer(network)

	# Connect reaction functions for connect/fail
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")

func _on_connection_failed():
	print("Failed to connect")
	pinging = false

func _on_connection_succeeded():
	print("Successfully connected")

	pinging = true
	
	requestPlayerSettings(PlayerSettings.color, PlayerSettings.title, self.get_instance_id())
	
	get_tree().change_scene("res://scenes/Lobby.tscn")
	self_id = get_tree().get_network_unique_id()

func _on_server_timeout():
	print("Server timed out")
	get_tree().change_scene("res://scenes/MainMenu.tscn")
	pinging = false

# Ping the server, also acts as a timeout indicator
func _ping_server():
	rpc_id(1, "_return_ping")
	if ping_wait:
		_on_server_timeout()
	ping_wait = true
remote func _return_ping():
	ping_wait = false
	ping_time_current = ping_time
	#print("Ping: "+str(ping_time_current))

func _process(delta):
	if pinging:
		if ping_wait:
			ping_time += delta
		else:
			ping_time_current = ping_time
			ping_time = 0

		if ping_interval_timer >= ping_interval:
			ping_interval_timer = 0
			_ping_server()
		else:
			ping_interval_timer += delta

# Player settings
func requestPlayerSettings(color, title, requester):
	rpc_id(1, "requestPlayerSettings", color, title, requester)

remote func acceptPlayerSettings(s_is_host, requester):
	print("Player settings accepted.")
	if instance_from_id(requester) != self:
		instance_from_id(requester).acceptPlayerSettings()

remote func denyPlayerSettings(type, requester):
	print("Player settings denied.")
	if instance_from_id(requester) != self:
		instance_from_id(requester).denyPlayerSettings(type)

# Get the player list
func fetchPlayerData():
	rpc_id(1, "fetchPlayerData")
remote func returnPlayerData(s_json):
	players = parse_json(s_json)
	updateLobbyIcons()

# Update player icons in the lobby
remote func updateLobbyIcons():
	if get_tree().get_current_scene().get_name() == "Lobby":
		print("did it work?")
		get_tree().get_current_scene().updateLobbyIcons()

# Request to start game
func startGameRequest():
	rpc_id(1, "startGameRequest")
remote func startGame():
	get_tree().change_scene("res://scenes/Game.tscn")
