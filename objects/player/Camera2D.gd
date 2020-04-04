extends Camera2D

var current_zoom
var min_zoom
var max_zoom
var zoom_delta = 0.95
var transition_time = 0.1

func _ready():
	current_zoom = zoom.x
	max_zoom = 0.40 # temp - normal is 0.60
	min_zoom = zoom.x * 0.40
	
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_UP :
			zoom_in()
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_out()
	elif event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			get_tree().quit()
			
func zoom_in():
	var target_zoom = current_zoom * zoom_delta
	if target_zoom < min_zoom:
		target_zoom = min_zoom
	transition_camera(target_zoom)

func zoom_out():
	var target_zoom = current_zoom / zoom_delta
	if target_zoom > max_zoom:
		target_zoom = max_zoom
	transition_camera(target_zoom)

func transition_camera(new_zoom):
	if new_zoom != current_zoom:
		current_zoom = new_zoom
		$Tween.interpolate_property(self, "zoom", get_zoom(), Vector2(current_zoom, current_zoom), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
