extends Camera2D

var min_zoom = 1.5
var max_zoom = 5
var zoom_delta = 0.7
var transition_time = 0.15
var tween

var is_transitioning = false
var target_zoom
var zoom_start_time
var initial_zoom

func _ready():
	make_current()
	tween = get_tree().create_tween()
	
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP :
			zoom_in()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()
	elif event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			get_tree().quit()
			
func zoom_out():
	target_zoom = get_zoom().x * zoom_delta
	if target_zoom < min_zoom:
		target_zoom = min_zoom
	transition_camera()

func zoom_in():
	target_zoom = get_zoom().x / zoom_delta
	if target_zoom > max_zoom:
		target_zoom = max_zoom
	transition_camera()
	
func transition_camera():
	zoom_start_time = Time.get_ticks_msec()
	initial_zoom = get_zoom().x
	is_transitioning = true
		
func _process(delta):
	if is_transitioning:
		var elapsed = (Time.get_ticks_msec() - zoom_start_time) / 1000.0
		if get_zoom().x == target_zoom or elapsed >= transition_time:
			is_transitioning = false
		else:
			var new_zoom = tween.interpolate_value(initial_zoom, target_zoom - initial_zoom, elapsed, transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			zoom = Vector2(new_zoom, new_zoom)


