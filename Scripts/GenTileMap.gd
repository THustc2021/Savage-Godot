extends TileMap

# 地图大小属性
var map_width_tiles_num = 30
var map_height_tiles_num = 30

# 这里我们使用的是水平偏移堆叠
var map_width = tile_set.tile_size[0] * map_width_tiles_num
##!! 注意这里，由于六边形堆叠作用，这里的高度实际上不能像宽度一样计算
#var map_height = tile_set.tile_size[1] * (107/140) * map_height_tiles_num
var height_const = 105	# 高度控制项
var map_height = map_height_tiles_num * height_const + (tile_set.tile_size[1] - height_const)

# valid cells list 所有合法网格集合
@export var valid_cells = []
@export var all_cells := []
var grid = []	# 保存移动力相关权重矩阵 0-水域，1-平原，2-丘陵，3，树林，4-树林丘陵，5-高山

@export var hlcell = preload("res://scenes/Utils/HLCell.tscn")
@export var hlcell_list = []

enum TerrainCellType{
	WATER,
	DIRT,
	GRASS,
	DESERT
}
enum DirtCellType{
	PLAIN,
	F1,
	F2,
	F3,
	F4,
	H1,
	H2,
	H3,
	FH
}
enum GrassCellType{
	PLAIN,
	F1,
	F2,
	F3,
	F4,
	H1,
	H2,
	FH
}
enum DesertsCellType{
	P1,
	P2,
	P3,
	P4,
	P5,
	SH1,
	SH2,
	SH3
}
enum GridType{
	WATER,
	DPLAIN,
	DFOREST,
	DHILL,
	DFHILL,
	GPLAIN,
	GFOREST,
	GHILL,
	GFHILL,
	SPLAIN,
	SSHILL,
	STONE
}

# 生成地图网格
func _get_surrounding_values(x, y):
	var values = []
	var surrounding_idx = self.get_surrounding_cells(Vector2i(x, y))
	for ij in surrounding_idx:
		var i = ij[0]
		var j = ij[1]
		values.append(grid[i][j])
	return values
func _generate_grid():
	var p = [0.1, 0.35, 0.3, 0.25]	# 基础地形的概率
	# 初始化网格
	for i in range(map_width_tiles_num+1):
		grid.append([])
		for j in range(map_height_tiles_num):
			grid[i].append(-1)
	# 设置基础地形（受周围地形影响）
	for y in range(1, map_height_tiles_num-1):
		for x in range(map_width_tiles_num):
			# 每个网格，考虑周围元素
			var surrounding_values = _get_surrounding_values(x, y)
			var ptmp = p.duplicate()
			for ct in TerrainCellType:
				# 提升该位置概率
				ptmp[TerrainCellType.get(ct)] += surrounding_values.count(TerrainCellType.get(ct)) * 2
			var v = utils.choice(TerrainCellType.values(), ptmp) 
			grid[x][y] = v	# 这里设置基础地形
	# 设置细分地形（独立于周围地形）
	var dp = [0.6, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]
	assert(tile_set.get_source(2).get_tiles_count() == len(dp))
	assert(len(DirtCellType) == len(dp))
	var gp = [0.65, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]
	assert(tile_set.get_source(3).get_tiles_count() == len(gp))
	assert(len(GrassCellType) == len(gp))
	var sp = [0.5, 0.05, 0.05, 0.05, 0.05, 0.1, 0.1, 0.1]
	assert(tile_set.get_source(4).get_tiles_count() == len(sp))
	assert(len(DesertsCellType) == len(sp))
	for y in range(map_height_tiles_num):
		for x in range(map_width_tiles_num):
			if grid[x][y] == TerrainCellType.WATER: # 检查网格，设置浅水区域
				# 判断周围有没有水单元格
				var surrounding_values = _get_surrounding_values(x, y)
				var water_count = surrounding_values.count(TerrainCellType.WATER)
				# 只要不全是water，就是浅水
				if water_count != len(surrounding_values):
					set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
				else:
					set_cell(0, Vector2i(x, y), 1, Vector2i(0, 0))
			else:
				# 随机
				var v = grid[x][y]
				if v == TerrainCellType.DIRT:
					var vv = utils.choice(DirtCellType.values(), dp)
					if vv == DirtCellType.PLAIN:
						v = GridType.DPLAIN
					elif vv in [DirtCellType.F1, DirtCellType.F2, DirtCellType.F3, DirtCellType.F4]:
						v = GridType.DFOREST
					elif vv in [DirtCellType.H1, DirtCellType.H2, DirtCellType.H3]:
						v = GridType.DHILL
					elif vv == DirtCellType.FH:
						v = GridType.DFHILL
					set_cell(0, Vector2i(x, y), 2, Vector2i(vv, 0))
				elif v == TerrainCellType.GRASS:
					var vv = utils.choice(GrassCellType.values(), gp)
					if vv == GrassCellType.PLAIN:
						v = GridType.GPLAIN
					elif vv in [GrassCellType.F1, GrassCellType.F2, GrassCellType.F3, GrassCellType.F4]:
						v = GridType.GFOREST
					elif vv in [GrassCellType.H1, GrassCellType.H2]:
						v = GridType.GHILL
					elif vv == GrassCellType.FH:
						v = GridType.GFHILL
					set_cell(0, Vector2i(x, y), 3, Vector2i(vv, 0))
				elif v == TerrainCellType.DESERT:
					var vv = utils.choice(DesertsCellType.values(), sp)
					if vv in [DesertsCellType.P1, DesertsCellType.P2, DesertsCellType.P3, DesertsCellType.P4, DesertsCellType.P5]:
						v = GridType.SPLAIN
					elif vv in [DesertsCellType.SH1, DesertsCellType.SH2, DesertsCellType.SH3]:
						v = GridType.SSHILL
					set_cell(0, Vector2i(x, y), 4, Vector2i(vv, 0))
				else:
					v = GridType.STONE
					set_cell(0, Vector2i(x, y), 5, Vector2i(0, 0))
				# 设置
				grid[x][y] = v
				if v not in [GridType.WATER, GridType.DHILL, GridType.GHILL, GridType.STONE]:
					valid_cells.append(Vector2i(x, y))
			all_cells.append(Vector2i(x, y))	# 存储
	
# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_grid()		
	# 设置全局变量
	GlobalConfig.tilemap = self
	
func create_init_path_map():
	# cells为2维地图坐标
	var astar = AStar.new()
	var valid_dict = {}
	for id in all_cells.size():
		valid_dict[id] = all_cells[id]
	# 将所有点加入到记录中
	for i in valid_dict:	
		astar.add_point(i, valid_dict[i])	# 初始全为0权重
	var idx = 0
	for n in valid_dict:
		var surround_spot_list : Array = get_surrounding_cells(valid_dict[n])
		for it in surround_spot_list:	# 对于周围的所有元素，查找邻居
			var m = valid_dict.find_key(it)	
			if m:
				astar.connect_points(n, m)
		idx += 1
	astar.valid_dict = valid_dict
	astar.valid_cells = all_cells.duplicate()
	return astar
	
func show_reachable_cells(astar, from: Vector2i, movement_point:int, this_valid_cells, flag:bool):	
	# flag检测是否是满移动力行动
	var ava_cells = Set.new()
	var p
	var m = 0
	var current_list = Set.new([from])
	while m < movement_point:
		# 将相邻点加入到set中
		var ncurrent_list = Set.new()
		for c in current_list.iter():
			var l = self.get_surrounding_cells(c)
			ncurrent_list.extend(l)
			# 检查是否是可通行的
			for to in l:
				if to.x < 0 or to.x >= self.map_width_tiles_num or \
					to.y < 0 or to.y >= self.map_height_tiles_num or \
					to not in this_valid_cells or to == from:
					continue
				p = astar.find_path(from, to)
				var pl = astar.cal_weighted_path(p, flag)	# 这里会弹出第一个起点元素
				if pl <= movement_point:
					ava_cells.add(to)
		current_list = ncurrent_list
		m += 1
	# 高亮可移动位置
	for cell in ava_cells.iter():
		var h = hlcell.instantiate()
		h.position = self.map_to_local(cell)
		add_child(h)  # 添加到场景中
		self.hlcell_list.append(h)
