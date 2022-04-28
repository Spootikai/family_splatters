extends Node

export var lobby_scene := "res://scenes/Lobby.tscn"
export var game_scene := "res://scenes/Game.tscn"

enum {
	LOBBY,
	GAME
}

sync var game_state

var self_id

signal server_update

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

func _on_server_disconnected():
	print("Server disconnected")
	
# Actual server stuff
remote func getError(err):
	print("SERVER ERR: "+err)

remote func serverUpdate():
	# Parse player data sent from the server if it hasnt been parsed yet
	if typeof(players) == TYPE_STRING:
		players = parse_json(players)

	# Check if this client is the host of the lobby
	if players.size() > 0:
		var client_player = players[str(self_id)]
		if client_player.order == 0:
			PlayerSettings.is_host = true
		else:
			PlayerSettings.is_host = false

	# Make sure to emit this signal at the end of the server update method
	emit_signal("server_update")

func finishLoading():
	rpc_id(1, "finishLoading")

# Fetch/catch color availability
func fetchColorAvailable(requester, color):
	rpc_id(1, "fetchColorAvailable", requester, color)
remote func returnColorAvailable(requester, color, s_value):
	instance_from_id(requester).returnColorAvailable(color, s_value)

# Fetch/catch lobby join6
func fetchLobbyJoin(color, title):
	rpc_id(1, "fetchLobbyJoin", color, title)
remote func returnLobbyJoin(color, title):
	print("Successfully joined the lobby!")
	PlayerSettings.color = color
	PlayerSettings.title = title
	emit_signal("server_update")

# Game start
func requestStartGame():
	rpc_id(1, "requestStartGame")
remote func returnStartGame(s_launch, s_timer):
	if !s_launch:
		if get_tree().get_current_scene().get_name() == "Lobby":
			var start_label = get_tree().get_root().get_node("Lobby/CenterContainer/StartLabel")
			
			var show_text: String
			if s_timer <= 0:
				show_text = "Trevor is fat"
				start_label.visible = false
			else:
				show_text = str(ceil(s_timer))
				start_label.visible = true

			start_label.text = show_text
	else:
		pass
		#actually start the damn game

# Process
func _process(delta):
	match game_state:
		LOBBY:
			if get_tree().get_current_scene().get_name() != "Lobby":
				get_tree().change_scene(lobby_scene)
			pass
		GAME:
			if get_tree().get_current_scene().get_name() !=  "Game":
				get_tree().change_scene(game_scene)
			pass
