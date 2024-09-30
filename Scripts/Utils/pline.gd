extends Line2D

func _init():
	self.begin_cap_mode = LINE_CAP_ROUND
	self.end_cap_mode = LINE_CAP_ROUND
	self.width = 5
	self.round_precision = 50

func draw_this(pf, set_color=null):
	if len(pf) < 1 or (len(pf) == 1 and len(pf[0]) <= 1):
		return
	default_color = set_color
	var tn = 0
	var tpoints = []
	for pi in pf:
		tpoints.append_array(pi) 
		tn += 1
		if tn == 1 and len(pi) <= 1:
			continue
		# 在点绘制数字
		var label = Label.new()
		label.text = str(tn)
		label.position = pi[-1]	# 终点坐标
		label.scale = Vector2(2, 2)
		# 将 label 添加到当前节点
		add_child(label)
	points = PackedVector2Array(tpoints)

func remove_this():
	clear_points()
	for c in self.get_children():
		remove_child(c)
		c.free()
