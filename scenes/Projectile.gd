extends Node2D

var velocity = Vector2(0, 0)
var timeout = 0
var splash_size = 0

func _physics_process(delta):
	$Sprite.visible = true
	$Sprite.rotation = velocity.angle()-Vector2.UP.angle()
	self.position += velocity*delta
	
	if Server.client_clock >= timeout:
		queue_free()
