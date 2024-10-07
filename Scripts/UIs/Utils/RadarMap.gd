extends Container

# 数据值，表示每个维度上的数值，范围为0到1
var data

# 标签数组，表示每个顶点的名称
var labels = ["普通近战单位", "对抗骑兵单位", "远程攻击单位", "骑兵单位", "攻城单位", "防御设施"]
# 雷达图的维度（正六边形，顶点数固定为6）
var dimensions = 6
# 雷达图的半径
var radius = 100
# 中心位置
var center

# 字体
var font

func _ready():
	# 加载字体资源
	font = ThemeDB.fallback_font
	center = size / 2
	
func setup(data_):
	self.data = data_

func _draw():
	if data != null:
		# 生成六边形顶点
		var points = []
		var dmax = data.max() 
		var dmin = data.min()
		for i in range(dimensions):
			var angle = (PI * 2 * i) / dimensions  # 每个顶点的角度
			var value = (data[i] - dmin) / (dmax - dmin) + 0.25 # 获取当前维度的数值
			var point = center + Vector2(cos(angle), sin(angle)) * radius * value
			points.append(point)
		
		# 设置多边形的颜色
		var color = Color(0.0, 0.5, 1.0, 0.8)
		
		# 绘制雷达图的多边形
		draw_polygon(points, [color])
		
		# 可选：绘制网格线和轴线
		_draw_grid()

		# 绘制顶点的标签
		_draw_labels()

func _draw_grid():
	# 绘制网格线和轴线，增强视觉效果
	for i in range(dimensions):
		var r = radius * (i / 4.0)
		var points = []
		for j in range(dimensions+1):
			var angle = (PI * 2 * j) / dimensions
			var point = center + Vector2(cos(angle), sin(angle)) * r
			points.append(point)
		draw_polyline(points, Color(0.5, 0.5, 0.5), 2, true)
	
	# 绘制从中心辐射出去的轴线
	for i in range(dimensions):
		var angle = (PI * 2 * i) / dimensions
		var point = center + Vector2(cos(angle), sin(angle)) * radius * 1.25
		draw_line(center, point, Color(0.7, 0.7, 0.7), 2)

func _draw_labels():
	# 在每个顶点绘制标签
	var point_distance = [1.4, 1.5, 1.55, 2, 1.65, 1.5]
	for i in range(dimensions):
		var angle = (PI * 2 * i) / dimensions
		var point = center + Vector2(cos(angle), sin(angle)) * radius * point_distance[i]  # 使标签在顶点外部显示
		var label = labels[i]  # 获取当前维度的标签
		
		# 通过 draw_string 绘制标签，偏移量用于调整标签的显示位置
		draw_string(font, point, label)
		draw_string(font, point + Vector2(0, 30), str(data[i]))
