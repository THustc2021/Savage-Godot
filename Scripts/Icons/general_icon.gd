extends TextureRect

# 定义形状的数量和大小
var shape_count = 5
var position_range = Vector2(-20, 20)
var shape_size_range = Vector2(10, 30) # 最小和最大形状大小

@export var data := []

func setup():
	# 储存顶点信息
	for i in range(shape_count):
		#var draw_color = Color(randf(), randf(), randf()) # 随机颜色
		var draw_color = Color(1, 1, 1, 1) # 随机颜色
		# 随机选择形状类型
		var shape_type = randi() % 10 # 0 或 1
		var shape_size = randf_range(shape_size_range.x, shape_size_range.y)		
		var shape_position = Vector2(randf_range(position_range.x, position_range.y), randf_range(position_range.x, position_range.y))
		var shape_points = _generate_random_polygon()
		while Geometry2D.triangulate_polygon(shape_points).is_empty():
			shape_points = _generate_random_polygon()
	
		data.append([draw_color, shape_type, shape_size, shape_position, shape_points])
	
func _generate_random_polygon():
	var points = []
	var point_count = randi() % 7 + 3
	for i in range(point_count):
		# 随机生成角度和半径
		var angle = randf() * 2 * PI
		var radius = randf_range(shape_size_range.x, shape_size_range.y)  # 半径范围
		var point = Vector2(cos(angle), sin(angle)) * radius
		points.append(point)
	# 将点按顺序排序以形成多边形
	points.sort_custom(_sort_by_angle)
	return PackedVector2Array(points)

func _sort_by_angle(a: Vector2, b: Vector2):
	return false if a.angle() > b.angle() else true

func _draw():
	for d in data:
		var draw_color = d[0]
		# 随机选择形状类型
		var shape_type = d[1]
		var shape_size = d[2]	
		var shape_position = d[3]
		var shape_points = d[4]
		
		# 根据形状类型绘制
		if shape_type == 0:
			draw_circle(shape_position, shape_size / 2, draw_color)
		else:
			draw_colored_polygon(shape_points, draw_color)
