extends Control

var data = []	# (占比，颜色，标签）
var total_num

var _knots := []

# 用于显示悬停内容的 Label
@onready var tooltip = $TooltipLabel

# 分段的“进度条”
func setup(data_, total_num_):
	data = data_
	total_num = total_num_
	connect("gui_input", _on_mouse_move)
	connect("mouse_exited", _on_Control_mouse_exited)

func _draw():
	
	var s = 0
	var width = size.x
	var height = size.y
	var w
	for d in data:
		w = int(d[0] * width / total_num) 
		draw_rect(Rect2(s, 0, w, height), d[1])
		_knots.append(s)
		s += w

# 鼠标进入事件
func _on_mouse_move(event):
	# 获取鼠标位置
	var mouse_pos = event.position
	# 根据鼠标位置设置提示内容
	for i in range(len(data)):
		if mouse_pos.x > _knots[i]:
			tooltip.text = data[i][2] + ":" + str(data[i][0])
		else:
			break
	
	# 显示提示标签
	tooltip.position = mouse_pos + Vector2(0, 30)  # 在鼠标旁边显示
	tooltip.show()

# 鼠标退出事件
func _on_Control_mouse_exited():
	# 隐藏提示标签
	tooltip.hide()
