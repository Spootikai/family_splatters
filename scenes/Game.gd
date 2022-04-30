extends Node2D

func _ready():
	Server.finishLoading()


var projectile_instance = preload("res://scenes/Projectile.tscn")
func projectileSpawn(spawn_position, velocity, timeout, size):
	var new_projectile = projectile_instance.instance()
	new_projectile.global_position = spawn_position
	new_projectile.velocity = velocity
	new_projectile.timeout = timeout
	new_projectile.splash_size = size

	$Projectiles.add_child(new_projectile)

var player_instance = preload("res://scenes/Player.tscn")
func playerSpawn(player_id, spawn_position: Vector2 = Vector2(0, 0)):
	var new_player = player_instance.instance()
	new_player.target_position = spawn_position
	new_player.global_position = spawn_position
	new_player.name = str(player_id)

	$Players.add_child(new_player)
	
var last_world_state = 0 
func updateWorldState(world_state):
	# Buffer
	# Interpolate
	# Extrapolate
	# Rubber Banding
	if world_state["T"] > last_world_state:
		# Use newest world state
		last_world_state = world_state["T"]
		world_state.erase("T")
		
		# Create/update players
		for player in Server.players.keys():
			if $Players.has_node(str(player)):
				var player_node = $Players.get_node(str(player))
				player_node._world_update(world_state[player])
			else:
				print("Spawning player...")
				playerSpawn(int(player), world_state[player]["P"])
	# Delete irrelevant players
	for player in $Players.get_children():
		if Server.players.keys().find(player.name) == -1:
			player.queue_free()

var shake_amount = 10.0
func _process(delta):
	var rand_x = rand_range(-shake_amount, shake_amount)
	var rand_y = rand_range(-shake_amount, shake_amount)
	# FIGURE THIS OUT NERD
	$Camera2D.set_offset(Vector2(rand_x, rand_y))
	#$Sprite.set_offset(Vector2(rand_x, rand_y))
