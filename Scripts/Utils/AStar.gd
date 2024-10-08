extends AStar2D

class_name AStar

var valid_dict	#已见的合法字典
var valid_cells	#已见的合法移动位置

const MAX_MOVEMENT_COST = 100	# 设置为一个较大值，应该不会出错，除非有一个路径长度比这个还长
var DefaultMovementCost = [
	MAX_MOVEMENT_COST, 
	1,
	2,
	MAX_MOVEMENT_COST,
	3,
	1,
	2,
	MAX_MOVEMENT_COST,
	3,
	1,
	2,
	MAX_MOVEMENT_COST
]

func _compute_cost(u, v):	# u是起点，v是终点
	# 跟地图的形状有关系
	# 必须注意，整个地图是向左凸起的，也就是有些单元格看起来应该是紧邻的，但实际不紧邻
	# 比如(20， 19)和(21, 20)是直接可达的，但(22, 19)和(21, 20)却不是
	var up = self.get_point_position(u)
	var vp = self.get_point_position(v)
	var uw = self.get_point_weight_scale(u)
	var vw = self.get_point_weight_scale(v)
	# 路径上所有节点的权重应该都纳入考量
	if vp.x > up.x:
		return vp.x - up.x + abs(up.y - vp.y) + vw
	else:
		return max(abs(up.x - vp.x), abs(up.y - vp.y)) + vw

func _estimate_cost(u, v):
	# 跟地图的形状有关系
	# 必须注意，整个地图是向左凸起的，也就是有些单元格看起来应该是紧邻的，但实际不紧邻
	# 比如(20， 19)和(21, 20)是直接可达的，但(22, 19)和(21, 20)却不是
	var up = self.get_point_position(u)
	var vp = self.get_point_position(v)
	var uw = self.get_point_weight_scale(u)
	var vw = self.get_point_weight_scale(v)
	# 路径上所有节点的权重应该都纳入考量
	if vp.x > up.x:
		return vp.x - up.x + abs(up.y - vp.y) + vw
	else:
		return max(abs(up.x - vp.x), abs(up.y - vp.y)) + vw

###################
func update_position(tile_position:Vector2i, new_w=-1, o_id=-1):	# 由于视野改变，此地变得可见
	# 查找在原来地图中的位置
	# 更新权重
	if new_w == -1:
		new_w = DefaultMovementCost[\
								GlobalConfig.tilemap.grid[tile_position[0]][tile_position[1]]]
	var id = valid_dict.find_key(tile_position)
	if id:
		self.set_point_weight_scale(id, new_w)
		if tile_position not in GlobalConfig.tilemap.valid_cells:
			# 删除之
			self.valid_cells.erase(tile_position)
			self.valid_dict.erase(id)
			# 取消所有与其关联的点
			self.remove_point(id)
		# 为城市
		elif new_w == MAX_MOVEMENT_COST:
			self.valid_cells.erase(tile_position)
			self.valid_dict.erase(id)
			self.remove_point(id)
	elif o_id != -1:	# 重新加入
		self.add_point(o_id, tile_position, new_w)	# 初始全为0权重
		self.valid_cells.append(tile_position)
		self.valid_dict[o_id] = tile_position
		var surround_spot_list : Array = GlobalConfig.tilemap.get_surrounding_cells(tile_position)
		for it in surround_spot_list:	# 对于周围的所有元素，查找邻居
			var m = valid_dict.find_key(it)	
			if m:
				self.connect_points(o_id, m)
	return id

func cal_weighted_path(p, flag):	# 计算带权移动路径长度
	var pl = 0
	p.remove_at(0)	# 删除起始点
	if len(p) <= 1 and flag:
		pl = 0
	else:
		for pp in p:
			pl += self.get_point_weight_scale(valid_dict.find_key(Vector2i(pp)))
	return pl

func seg_path(p, current_movement_point, movement_point, invalid_tiles):	# 根据移动力大小拆分路径
	# 注意p为空的情况
	if len(p) == 0:
		return [true, [[]]]
	# 输入应该带起点的路径
	var mov_paths = []
	var l	# 本次权重
	var pl = 0	# 本次长度
	var mov_path = [p.pop_at(0)]	# 本次路径
	# 首先，消耗掉当前的移动力
	var pi = 0
	for pp in p:
		l = self.get_point_weight_scale(valid_dict.find_key(Vector2i(pp)))
		if pl + l > current_movement_point:	# 如果超出了剩余移动力
			# 如果是第一步
			if len(mov_paths) == 0 and len(mov_path) == 1 and current_movement_point == movement_point:	# 单位尚未移动
				if Vector2i(pp) in invalid_tiles:	# 如果是不合法的位置
					return [false, pp, self.update_position(pp, MAX_MOVEMENT_COST)]
				else:
					mov_path.append(pp)
					mov_paths.append(mov_path)
					pl = 0	# 更新本次长度
					mov_path = []
			# 后续步骤
			else:
				if Vector2i(pp) in invalid_tiles:	# 如果是不合法的位置
					return [false, pp, self.update_position(pp, MAX_MOVEMENT_COST)]
				else:
					# 如果上一步是不合法的位置
					if len(mov_path) > 1 and Vector2i(mov_path[-1]) in invalid_tiles:
						return [false, mov_path[-1], self.update_position(mov_path[-1], MAX_MOVEMENT_COST)]
					else:
						mov_paths.append(mov_path)
						mov_path = [pp]
						pl = l
						pi += 1
						break	# 跳出
		else:
			mov_path.append(pp)
			pl += l
		pi += 1	# 更新指针
	if pi == len(p):	# 已经指到末尾，若目的地为不合法，则取消移动；若为空集，也不移动
		if len(mov_path) != 0 and Vector2i(mov_path[-1]) not in invalid_tiles:
			mov_paths.append(mov_path)
		else:
			mov_paths.append([])
	else:
		for pii in range(pi, len(p)):
			var pp = p[pii]
			l = self.get_point_weight_scale(valid_dict.find_key(Vector2i(pp)))
			if pl + l > movement_point:	# 结算
				mov_paths.append(mov_path)
				mov_path = [pp]
				pl = l
			else:
				pl = pl + l
				mov_path.append(pp)
		if len(mov_path) != 0:
			mov_paths.append(mov_path)
	return [true, mov_paths]
	
func find_path(from : Vector2, to : Vector2) -> Array:
	var x = valid_dict.find_key(Vector2i(from))
	var y = valid_dict.find_key(Vector2i(to))
	if y == null:
		return []
	var path_list = self.get_id_path(x, y)
	var path = []
	for i in path_list:
		path.append(self.get_point_position(i))
	return path

