extends Node2D

const MOVE_SPEED = 60

func _ready():
	pass

func _physics_process(delta):
	move(delta)
	
	var look_vec = get_global_mouse_position() - global_position
	global_rotation = atan2(look_vec.y, look_vec.x)
	
func move(delta):
	var speed = MOVE_SPEED
	if Input.is_action_pressed("sprint"):
		speed = MOVE_SPEED * 1.8
	var move_vec = Vector2()
	if Input.is_action_pressed("move_up"):
		move_vec.y -= 1
	if Input.is_action_pressed("move_down"):
		move_vec.y += 1
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1
	move_vec = move_vec.normalized()
	translate(move_vec * speed * delta)
