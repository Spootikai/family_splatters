extends Node2D

# Player variables
onready var player_id := -1
onready var player_color: Color
onready var player_title: String = "???"

export var pale_weight = 0.25

# System variables
onready var mode : String = "egg"
onready var state : String = "idle"
onready var debug := true

export var click_deadzone : float = 0.1 # Time in seconds
onready var click_timer : float = 0

# Computational variables
onready var start_moving = false # Used to smooth out the feel of movement
onready var target_position: Vector2
onready var target_direction: Vector2 
onready var direction_facing: Vector2 = Vector2(0, -1)

# Egg exclusive variables
export var move_speed_egg = 1
export var knockback_force: float = 5
export var knockback_duration: float = 0.2 # Time in seconds
onready var knockback_timer: float = 0
onready var knocked_back = false
onready var knockback_direction: Vector2

# Bird exclusive variables
export var move_speed_bird = 2.5
export var turn_speed = 2

# Attack charging
export var attack_charge_time: float = 3 # Time in seconds
export var attack_deadzone: float = 0.25 # Time in seconds 
export var attack_charge: float = 0


# CREATION CODE
func _ready():
	#Server.fetchPlayerData(game_id, self.get_instance_id())
	pass

# TICK PROCESSES
func _process(delta):
	# SERVER SHIT
	if local_owned:
		#updatePlayerPosition(game_id)
		pass
	
	# DETECT INPUTS (IF OWNED BY CLIENT)
	if local_owned: 	
		if mode == "bird":
			# Update the target position
			target_position = get_viewport().get_mouse_position()
		
			# Have a deadzone for clicking; clicking quickly makes fast shits
			# Charge up attack
			if Input.is_action_just_pressed("bird_fire"):
				attack_charge = 0
			if Input.is_action_pressed("bird_fire"):
				if attack_charge < attack_charge_time:
					attack_charge += delta
			if Input.is_action_just_released("bird_fire"):
				# If the click was briefer than the deadzone, pretend it wasnt charged
				if attack_charge < (attack_deadzone):
					attack_charge = 0
	
				# Create a shit scene now
				#
				# here
				#
		
		if mode == "egg":
			# Have a deadzone for clicking, wont start following the cursor while holding immediately
			# Update the target position
			
			if Input.is_action_just_pressed("egg_move"):
				target_position = get_viewport().get_mouse_position()
				start_moving = true
			if Input.is_action_pressed("egg_move"):
				if click_timer < click_deadzone:
					click_timer += delta
				else:
					target_position = get_viewport().get_mouse_position()
			if Input.is_action_just_released("egg_move"):
				click_timer = 0

		# All debugging shenanigans
		if debug:
			# Toggle between modes for testing
			if Input.is_action_just_pressed("ui_accept"):
				switch_mode()

			# Pretend that the mouse is another egg knocking you back
			if mode == "egg":
				if Input.is_action_just_released("click"):
					knockback(get_viewport().get_mouse_position().direction_to(self.position).normalized())
	if !local_owned:
		#Server.fetchPlayerPosition(self.get_instance_id(), game_id)
		# Get position of this player instance
		pass
		
	# EGG MODE BEHAVIOR
	if mode == "egg":
		if state == "knocked_back":
			self.position += knockback_direction*(knockback_force)
			
			if knockback_timer >= knockback_duration:
				knockback_timer = 0
				state = "idle"
			else:
				knockback_timer += delta
		if state == "idle":
			if start_moving:
				state = "moving"
		if state == "moving":
			if start_moving and self.position.distance_to(target_position) > move_speed_egg:
				var normal = self.position.direction_to(target_position)
				self.position += normal*move_speed_egg*(1-delta)
			else:
				state = "idle"
	
	# BIRD MODE BEHAVIOR
	if mode == "bird":
		# Get the normal direction towards the target position
		target_direction = self.position.direction_to(target_position)

		# Find the shortest point from the direction facing to the target direction (given a weight; turn_speed)
		var dir_from = direction_facing.angle()
		var dir_to = target_direction.angle()

		var difference = fmod(dir_to - dir_from, PI * 2)
		var turn_angle = dir_from + (fmod(2*difference, PI*2) - difference) * (turn_speed*delta)
		
		# Add the turning increment to the direction facing
		direction_facing = Vector2.RIGHT.rotated(turn_angle)

		# Rotate the bird sprite in radians based on the direction facing variable
		$SpriteBird.rotation = direction_facing.angle()-Vector2.UP.angle() # Account for the rotation of the original sprite
		
		# Constantly move the bird forward like it's soaring
		self.position += direction_facing*move_speed_bird*(1-delta)

# BECOME KNOCKED BACK
func knockback(direction: Vector2):
	knockback_direction = direction
	state = "knocked_back"
	start_moving = false

# SWITCH MODES, OR TOGGLE MODES IF NO ARGUMENT GIVEN
func switch_mode(newmode = "none"):
	# Clear target when switching modes 
	target_position = self.position 
	
	# Actually toggle between modes/set mode
	if newmode == "none":
		if mode == "egg":
			mode = "bird"
		elif mode == "bird":
			mode = "egg"
	else:
		mode = newmode
	
	# Update to make sure everything is correct
	update()

# UPDATE VISIBLIITY
func update():
	var new_color = Color(player_color).blend(Color(1, 1, 1, pale_weight))
	$SpriteBird.modulate = new_color
	$SpriteEgg.modulate = new_color
	
	if mode == "bird":
		$SpriteBird.visible = true
		$SpriteEgg.visible = false
	elif mode == "egg":
		$SpriteBird.visible = false
		$SpriteEgg.visible = true
	
	if game_id == PlayerSettings.game_id:
		local_owned = true
		
	else:
		local_owned = false

# SERVER FUNCTIONALITY FUNCTIONS
# SET PLAYER DATA
func setPlayerData(s_mode, s_title, s_color):
	mode = "egg"
	player_title = str(s_title)
	player_color = Color(s_color)
	update()

func setPlayerPosition(s_position):
	self.position = s_position

func updatePlayerPosition(game_id):
	Server.updatePlayerPosition(game_id, self.position)
