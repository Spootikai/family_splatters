
extends Control

var playerName
var screenSizes = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	if(screenSizes < 2):
		get_node("Panel/Window_Mode").add_item("Windowed")
		get_node("Panel/Window_Mode").add_item("Fullscreen")
		screenSizes+=2

func _on_TextureButton_pressed():
	# Change Functionality to pass player name somewhere when closing settings
	# Possibly check for name availability
	print(playerName)
	print(get_node("Panel/OptionButton").selected)
	queue_free()

# Checks for changes in volume
func _on_VolumeSlider_value_changed(value):
	$Panel/Volume_Level.text = str(value)
	

func _on_MenuMusic_value_changed(value1):
	$Panel/Menu_Level.text = str(value1)


func _on_GameMusic_value_changed(value2):
	$Panel/Game_Level.text = str(value2)

# Get name from the name textbox
func _on_LineEdit_text_changed(new_text):
	playerName = new_text




func _on_Window_Mode_item_selected(index):
	if(index == 0):
		print("Windowed Mode")
	if(index == 1):
		print("Fullscreen")
