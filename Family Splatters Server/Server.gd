extends Node

var game_active = false
 
var network = NetworkedMultiplayerENet.new()
var port = ServerData.port
var max_players = ServerData.max_players

func _ready():
	start_server()
	
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started!")

	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(player_id):
	print("Player "+str(player_id)+" Connected")
	fetchPlayerSettings(player_id)

func _peer_disconnected(player_id):
	print("Player "+str(player_id)+" Disconnected")
	ServerData.players.erase(player_id)





remote func startGame(id):
	if game_active == false:
		pass

func fetchPlayerSettings(player_id):
	rpc_id(player_id, "fetchPlayerSettings")
remote func returnPlayerSettings(color, title):
	var player_id = get_tree().get_rpc_sender_id()
	ServerData.players[player_id] = [color, title, "egg"]
	rpc_id(player_id, "returnPlayerSettings", ServerData.players.size())

remote func fetchPlayerData(peer_id, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var s_mode = "egg"
	var s_title = ServerData.players[peer_id][1]
	var s_color = ServerData.players[peer_id][0]
	rpc_id(player_id, "returnPlayerData", s_mode, s_title, s_color, peer_id, requester)
	print("sending playerdata to "+str(player_id))
