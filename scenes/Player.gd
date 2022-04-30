extends Node2D

var tween_speed = 0.15

# New netcode
var player_state
var puppet_position: Vector2 = Vector2(0, 0)
var puppet_target_position: Vector2 = Vector2(0, 0)

# Player variables
export var pale_weight = 0.3
export var bird_opacity = 0.35

# System variables
onready var mode_previous : String
onready var mode : String
onready var state : String = "idle"

export var click_deadzone : float = 0.1 # Time in seconds
onready var click_timer : float = 0

# Computational variables
onready var target_position: Vector2
onready var target_direction: Vector2 
onready var direction_facing: Vector2 = Vector2(0, -1)

onready var cooldown_delay = 0.5
onready var cooldown_time = 0

onready var charge_time = 0

# Server authoritative settings
onready var move_speed_egg
onready var move_speed_bird
onready var turn_speed

var is_local_owned 
func _ready():
	Server.connect("server_update", self, "_on_server_update")
	if self.name == str(Server.self_id):
		is_local_owned = true
	else:
		is_local_owned = false
	
	move_speed_egg = Server.game_settings["E"]
	move_speed_bird = Server.game_settings["B"]
	turn_speed = Server.game_settings["T"]
	
	update()

# Server stuff
func _on_server_update():
	print("Update!")
	update()

func definePlayerState():
	player_state = {"T": Server.client_clock, "X": self.target_position}
	Server.sendPlayerState(player_state)

# Tick 60 times per second
func _physics_process(delta):
	if is_local_owned:
		
		definePlayerState()

		match mode:
			"bird":
				target_position = get_global_mouse_position()
				if Input.is_action_just_released("bird_fire"):
					if Server.client_clock > cooldown_time:
						charge_time = clamp(charge_time, 0.25, 3)
						var aim_dir = self.global_position.direction_to(get_global_mouse_position())
						Server.sendProjectile(charge_time, aim_dir.angle())
						cooldown_time = Server.client_clock+(cooldown_delay*1000)
					else:
						charge_time = 0
				if Input.is_action_pressed("bird_fire"):
					charge_time += delta
			"egg":
				if Input.is_action_just_pressed("egg_move"):
					target_position = get_viewport().get_mouse_position()
				if Input.is_action_pressed("egg_move"):
					if click_timer < click_deadzone:
						click_timer += delta
					else:
						target_position = get_viewport().get_mouse_position()
					if Input.is_action_just_released("egg_move"):
						click_timer = 0

# Puppet behavior
func _world_update(my_state):
	puppet_target_position = my_state["X"]
	puppet_position = my_state["P"]
	mode = my_state["M"]
	
	# Make sure that mode changes are detected
	if mode != mode_previous:
		direction_facing = my_state["F"]
		update()
	
	mode_previous = mode
	
	var tween_position = self.get_node("TweenPosition")
	tween_position.interpolate_property(self, "global_position", self.global_position, puppet_position, tween_speed)
	tween_position.start()

func _process(delta):
	if mode == "bird":
		var dir_from = direction_facing.angle()
		var dir_to = self.global_position.direction_to(puppet_target_position).angle()

		var difference = fmod(dir_to - dir_from, PI * 2)
		var turn_angle = dir_from + (fmod(2*difference, PI*2) - difference) * (turn_speed*delta)

		direction_facing = Vector2.RIGHT.rotated(turn_angle)

		# Rotate the bird sprite in radians based on the direction facing variable
		$SpriteBird.rotation = direction_facing.angle()-Vector2.UP.angle()

# Visual updates
func update():
	var new_color = Color(Server.players[self.name].color).blend(Color(1, 1, 1, pale_weight))
	$SpriteBird.modulate = new_color
	$SpriteEgg.modulate = new_color
	
	$SpriteBird.modulate.a = 1.0
	
	if mode == "bird":
		if !is_local_owned:
			$SpriteBird.modulate.a = bird_opacity
		$SpriteBird.visible = true
		$SpriteEgg.visible = false
	elif mode == "egg":
		$SpriteBird.visible = false
		$SpriteEgg.visible = true
