extends SubViewport

@onready var pline = $"TileMap/Line2D"
@onready var tilemap = $"TileMap"

func _unhandled_input(event):
	var u = GlobalConfig.selected_unit
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == 2 and u != null:
				# 显示移动线
				var clicked_tile = tilemap.local_to_map(tilemap.get_global_mouse_position())	# 转为tile坐标
				# 判断是否合法移动
				if clicked_tile in GlobalConfig.factionManager.player_faction.astar.valid_cells \
					and not u.tile_position == clicked_tile \
					and not u.current_movement_point == 0:
					var pf = u.prepare_move(clicked_tile)
					# draw line
					pline.draw_this(pf, u.belonged_faction.faction_color)
				else:
					print("need move OR out of area!")
			# 如果有未处理的点击事件
			if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
				if u != null:
					# 是否点击同一个单位两次
					var clicked_tile = tilemap.local_to_map(tilemap.get_global_mouse_position())
					if clicked_tile == u.tile_position:
						GlobalConfig.clicked_under_unit = true
					else:
						GlobalConfig.clicked_under_unit = false
					u.unselected()
					GlobalConfig.selected_unit = null
				else:
					GlobalConfig.clicked_under_unit = false
				if GlobalConfig.selected_city != null:
					GlobalConfig.selected_city.unselected()
					GlobalConfig.selected_city = null
			# 尝试移除所有的高亮框
			for celli in range(len(tilemap.hlcell_list)):
				var cell = tilemap.hlcell_list.pop_at(0)	# 不断弹出第一个，直至清空
				tilemap.remove_child(cell)
				cell.free()
		else:
			if event.button_index == MOUSE_BUTTON_RIGHT:	# 右键释放
				if u != null:
					# 确定移动则清除移动线
					pline.remove_this()
					var clicked_tile = tilemap.local_to_map(tilemap.get_global_mouse_position())	# 转为tile坐标
					# 判断是否合法移动
					if clicked_tile in GlobalConfig.factionManager.player_faction.astar.valid_cells \
						and not u.tile_position == clicked_tile:
						u.move()
						# 移动完成后取消选中
						u.unselected()
						GlobalConfig.selected_unit = null
					else:
						print("need move OR out of area!")
	elif event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_RIGHT and u != null:
		# 尝试移除现有的路径控件
		pline.remove_this()
		# 显示移动线
		var clicked_tile = tilemap.local_to_map(tilemap.get_global_mouse_position())	# 转为tile坐标
		# 判断是否合法移动
		if clicked_tile in GlobalConfig.factionManager.player_faction.astar.valid_cells and not u.tile_position == clicked_tile:
			var pf = u.prepare_move(clicked_tile)
			# draw line
			pline.draw_this(pf, u.belonged_faction.faction_color)
		else:
			print("need move OR out of area!")
	else:
		# 尝试移除现有的路径控件
		pline.remove_this()

func _unhandled_key_input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		# 隐藏所有框
		GlobalConfig.remove_current_main()
