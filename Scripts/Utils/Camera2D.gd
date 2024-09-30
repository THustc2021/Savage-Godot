extends Camera2D

@onready var move_left_limit
@onready var move_up_limit
@onready var move_right_limit
@onready var move_down_limit

# Called when the node enters the scene tree for the first time.
func setup(init_point):
	var p = get_parent()
	var rect = p.get_viewport_rect()
	var rect_center_x = rect.size[0] / 2
	var rect_center_y = rect.size[1] / 2
	# 摄像头初始位置
	position = init_point
	# 摄像头position可改变范围设置
	move_left_limit = rect_center_x + p.tile_set.tile_size[0] / 2
	move_up_limit = rect_center_y + p.tile_set.tile_size[1] / 2
	move_right_limit = p.map_width - rect_center_x
	move_down_limit = p.map_height - rect_center_y - p.tile_set.tile_size[1] / 2
	if move_left_limit > move_right_limit or move_up_limit > move_down_limit:
		push_error("Over small map size, exit.")
		get_tree().quit(-1)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var input_direction = Input.get_vector("Camera_left", "Camera_right", "Camera_up", "Camera_down")
	var position_ = position + input_direction * 20
	if position_[0] < move_left_limit:
		position_[0] = move_left_limit
	elif position_[0] > move_right_limit:
		position_[0] = move_right_limit
	if position_[1] < move_up_limit:
		position_[1] = move_up_limit
	elif position_[1] > move_down_limit:
		position_[1] = move_down_limit
	position = position_
