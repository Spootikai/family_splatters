extends Node

export var lobby_scene := "res://scenes/Lobby.tscn"
export var game_scene := "res://scenes/Game.tscn"

enum {
	LOBBY,
	GAME
}

sync var game_state
var game_launch_time = 0

var self_id

signal server_update
signal player_update

var game_settings = {}
sync var players
var network = NetworkedMultiplayerENet.new()

var attempted = false
func connect_to_server(ip = "35.160.170.69", port = 18181):
	# Close pre existing connections just in case
	network.close_connection() 
	
	# Create the client on the network and attach it to the tree
	network.create_client(ip, port)
	get_tree().set_network_peer(network)

	# Connect signals
	if !attempted:
		network.connect("connection_failed", self, "_on_connection_failed")
		network.connect("connection_succeeded", self, "_on_connection_succeeded")
		network.connect("server_disconnected", self, "_on_server_disconnected")
		attempted = true

func _on_connection_failed():
	print("Failed to connect")

func _on_connection_succeeded():
	print("Successfully connected")
	self_id = get_tree().get_network_unique_id()
	
	# Server time synchronization
	rpc_id(1, "fetchServerTime", OS.get_system_time_msecs())
	var sync_timer = Timer.new()
	sync_timer.wait_time = 0.5
	sync_timer.autostart = true
	sync_timer.connect("timeout", self, "determineLatency")
	self.add_child(sync_timer)

func _on_server_disconnected():
	print("Server disconnected")
	
# Server time synchronization
var client_clock = 0 
var decimal_collector: float = 0
var latency_array = []
var latency = 0
var delta_latency = 0
remote func returnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time)/2
	client_clock = server_time + latency

func determineLatency():
	rpc_id(1, "determineLatency", OS.get_system_time_msecs())

remote func returnLatency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1, -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		
		delta_latency = (total_latency/latency_array.size()) - latency
		latency = total_latency/latency_array.size()
		print("New latency: ", latency)
		print("Delta latency: ", delta_latency)
		latency_array.clear()

# Server stuff
remote func getError(err):
	print("SERVER ERR: "+err)

remote func serverUpdate():
	# Parse player data sent from the server if it hasnt been parsed yet
	if typeof(players) == TYPE_STRING:
		players = parse_json(players)

	# Check if this client is the host of the lobby
	if players.size() > 0:
		if players.keys().find(str(self_id)) != -1:
			var client_player = players[str(self_id)]
			if client_player.order == 0:
				PlayerSettings.is_host = true
			else:
				PlayerSettings.is_host = false

	# Make sure to emit this signal at the end of the server update method
	emit_signal("server_update")

# Fetch/catch color availability
func fetchColorAvailable(requester, color):
	rpc_id(1, "fetchColorAvailable", requester, color)
remote func returnColorAvailable(requester, color, s_value):
	instance_from_id(requester).returnColorAvailable(color, s_value)

# Fetch/catch lobby join
func fetchLobbyJoin(color, title):
	rpc_id(1, "fetchLobbyJoin", color, title)
remote func returnLobbyJoin(color, title):
	print("Successfully joined the lobby!")
	PlayerSettings.color = color
	PlayerSettings.title = title
	emit_signal("server_update")


### New Netcode ###
# Game start
func requestStartGame():
	rpc_id(1, "requestStartGame")
remote func returnStartGame(s_launch_time):
	game_launch_time = s_launch_time

func finishLoading():
	rpc_id(1, "finishLoading")

remote func recieveServerSettings(s_dict):
	game_settings = s_dict

# Syncing world and player
func sendProjectile(charge_time, aim_dir):
	rpc_id(1, "recieveProjectile", charge_time, aim_dir)

remote func recieveProjectile(spawn_position, velocity, timeout, size):
	get_node("/root/Game").projectileSpawn(spawn_position, velocity, timeout, size)

func sendPlayerState(player_state):
	rpc_unreliable_id(1, "recievePlayerState", player_state)

remote func recieveWorldState(world_state):
	get_node("/root/Game").updateWorldState(world_state)

remote func gameWinner(player_id):
	if get_tree().get_current_scene().get_name() == "Game":
		get_node("/root/Game").get_node("CenterContainer/Winner").text = "Winner: "+str(players[str(player_id)].title)

# Process
func _process(delta):
	# Server time synchronization
	var delta_ms = delta*1000
	
	client_clock += int(delta_ms) + delta_latency
	delta_latency = 0
	decimal_collector += (delta_ms) - int(delta_ms)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00
	
	# Game state behavior
	match game_state:
		LOBBY:
			if get_tree().get_current_scene().get_name() != "Lobby":
				get_tree().change_scene(lobby_scene)
			else:
				if game_launch_time > 0:
					if client_clock >= game_launch_time:
						print("Game state changing to: GAME")
						game_state = GAME
		GAME:
			game_launch_time = 0
			if get_tree().get_current_scene().get_name() !=  "Game":
				get_tree().change_scene(game_scene)
