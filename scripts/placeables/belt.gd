extends AnimatedSprite2D
class_name Belt

var belt_type: Types.Belt_Type = Types.Belt_Type.STRAIGHT
var input: Array[Types.Direction] = [Types.Direction.DOWN]
var output: Array[Types.Direction] = [Types.Direction.UP]
var is_flipped = false
var animation_set = false
var ref_belt: AnimatedSprite2D


func set_type(type: Types.Belt_Type, rotation: int, flipped: bool, ref: AnimatedSprite2D):
	belt_type = type
	is_flipped = flipped
	rotate_belt(rotation)
	animation_set = false
	ref_belt = ref
	
func _process(delta):
	if !animation_set and ref_belt != null:
		update_animation()
		animation_set = check_animation()
		update_frame()
	
func rotate_belt(value: int):
	if value < 0:
		return
	var rotation_value = value % 360
	if rotation_value % 90 != 0:
		return
		
	rotation_degrees = value
	
	match belt_type:
		Types.Belt_Type.START:
			match rotation_value:
				0:
					input = []
					output = [Types.Direction.UP]
				90:
					input = []
					output = [Types.Direction.RIGHT]
				180:
					input = []
					output = [Types.Direction.DOWN]
				270:
					input = []
					output = [Types.Direction.LEFT]
		Types.Belt_Type.END:
			match rotation_value:
				0:
					input = [Types.Direction.DOWN]
					output = []
				90:
					input = [Types.Direction.LEFT]
					output = []
				180:
					input = [Types.Direction.UP]
					output = []
				270:
					input = [Types.Direction.RIGHT]
					output = []
		Types.Belt_Type.STRAIGHT:
			match rotation_value:
				0:
					input = [Types.Direction.DOWN]
					output = [Types.Direction.UP]
				90:
					input = [Types.Direction.LEFT]
					output = [Types.Direction.RIGHT]
				180:
					input = [Types.Direction.UP]
					output = [Types.Direction.DOWN]
				270:
					input = [Types.Direction.RIGHT]
					output = [Types.Direction.LEFT]
		Types.Belt_Type.CORNER:
			match rotation_value:
				0:
					input = [Types.Direction.DOWN]
					if !is_flipped:
						output = [Types.Direction.RIGHT]
					else:
						output = [Types.Direction.LEFT]
				90:
					input = [Types.Direction.LEFT]
					if !is_flipped:
						output = [Types.Direction.DOWN]
					else:
						output = [Types.Direction.UP]
				180:
					input = [Types.Direction.UP]
					if !is_flipped:
						output = [Types.Direction.LEFT]
					else:
						output = [Types.Direction.RIGHT]
				270:
					input = [Types.Direction.RIGHT]
					if !is_flipped:
						output = [Types.Direction.UP]
					else:
						output = [Types.Direction.DOWN]

func update_animation():
	match belt_type:
		Types.Belt_Type.STRAIGHT:
			animation = "straight"
		Types.Belt_Type.CORNER:
			animation = "corner"
		Types.Belt_Type.START:
			animation = "start"
		Types.Belt_Type.END:
			animation = "end"

func check_animation():
	match belt_type:
		Types.Belt_Type.STRAIGHT:
			return animation == "straight"
		Types.Belt_Type.CORNER:
			return animation == "corner"
		Types.Belt_Type.START:
			return animation == "start"
		Types.Belt_Type.END:
			return animation == "end"
	return false

func update_frame():
	set_frame_and_progress(ref_belt.get_frame(), ref_belt.get_frame_progress())
