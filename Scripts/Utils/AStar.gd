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

func _compute_cost(u, v):
	var up = self.get_point_position(u)
	var vp = self.get_point_position(v)
	var uw = self.get_point_weight_scale(u)
	var uv = self.get_point_weight_scale(v)
	return  max(abs(up.x - vp.x), abs(up.y - vp.y)) + min(uw, uv)

func _estimate_cost(u, v):
	var up = self.get_point_position(u)
	var vp = self.get_point_position(v)
	var uw = self.get_point_weight_scale(u)
	var uv = self.get_point_weight_scale(v)
	return  max(abs(up.x - vp.x), abs(up.y - vp.y)) + min(uw, uv)

###################
func update_position(tile_position, new_w=-1):	# 由于视野改变，此地变得可见
	# 查找在原来地图中的位置
	# 更新权重
	if new_w == -1:
		new_w = DefaultMovementCost[\
								GlobalConfig.tilemap.grid[tile_position[0]][tile_position[1]]]
	var id = valid_dict.find_key(Vector2i(tile_position))
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

func cal_weighted_path(p, flag):	# 计算带权移动路径长度
	var pl = 0
	p.remove_at(0)	# 删除起始点
	if len(p) <= 1 and flag:
		pl = 0
	else:
		for pp in p:
			pl += self.get_point_weight_scale(valid_dict.find_key(Vector2i(pp)))
	return pl

func seg_path(p, current_movement_point, movement_point):	# 根据移动力大小拆分路径
	# 注意p为空的情况
	if len(p) == 0:
		return [[]]
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
			if len(mov_paths) == 0 and len(mov_path) == 1 and current_movement_point == movement_point:	# 单位尚未移动
				mov_path.append(pp)
				mov_paths.append(mov_path)
				pl = 0	# 更新本次长度
				mov_path = []
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
	if pi == len(p):	# 已经指到末尾
		if len(mov_path) != 0:
			mov_paths.append(mov_path)
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
	return mov_paths
	
func find_path(from : Vector2, to : Vector2) -> Array:
	var x = valid_dict.find_key(Vector2i(from))
	var y = valid_dict.find_key(Vector2i(to))
	var path_list = self.get_id_path(x, y)
	var path = []
	for i in path_list:
		path.append(self.get_point_position(i))
	return path

