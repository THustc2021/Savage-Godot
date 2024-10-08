extends CharacterBody2D

@onready var target
@onready var tilemap

var speed = 400
var star_icon = preload("res://assets/UnitTools/star.png")

signal show_info

var tile_position := Vector2i()  # hard-coded starting tile position
var tile_position_tmp := Vector2i()
var tile_path = []  # of tile positions
var world_path = []  # of global coordinates
var path_found = []	
var world_path_found = []
var last_no_collide	# 用于储存移动过程中发生碰撞的坐标

@export var movement_point = 2
@export var supplement = 1
var max_total_soldiers_num := 0

var belonged_faction
var commander
var current_state
var current_movement_point
var current_supplement
var current_total_soldiers_num := 0
var current_unit_list := []
var _current_in_city = null 	# 是否在城市中
var _current_inside_city = false	# 是否是可见的（管理ui）

var attack_non_declare_confirmed_scene = preload("res://scenes/UIs/PopUpwindows/PopupWindow.tscn")
var attack_non_declare_confirmed

func _add_to_portrait(n):
	$"Portrait".add_child(n)

# 供城市端调用的接口，本地不调用（是否可见交给城市管理）
func set_inside_city():
	_current_inside_city = true
	# 禁用碰撞
	collision_layer = 0
	collision_mask = 0
func set_outside_city():
	_current_inside_city = false
	# 禁用碰撞
	collision_layer = 1
	collision_mask = 1
	
func setup(base_units, faction, tilepos=null, in_city=null, general=null, movement_point_cost_ratio=0):
	tilemap = GlobalConfig.tilemap
	# 设置位置属性（未必会有）
	if tilepos != null:	# 只是用作测试，未加入到场景，这种情况下不应该注册
		tile_position = tilepos
		position = tilemap.map_to_local(tilepos)
		faction.register_unit(self)
	if in_city:
		_current_in_city = in_city
	# 设置指挥者
	if general == null:
		self.commander = load("res://Scripts/Units/Generals/base_general.gd").new()
	else:
		self.commander = general
	self.commander.icon.set_anchors_preset(Control.PRESET_CENTER)
	_add_to_portrait(self.commander.icon)
	var st
	var n = self.commander.general_level
	for gi in range(0, n):
		st = TextureRect.new()
		st.texture = star_icon
		st.position = Vector2(30+20*(gi-n/2), -20+(gi-n/2)*(gi-n/2))
		st.scale = Vector2(32, 32) / st.texture.get_size()
		_add_to_portrait(st)
	# 设置初始状态
	self.current_state = GlobalConfig.UNIT_STATE.IDLE
	# 设置当前补给数量（应当从国家仓库中扣除）
	self.current_supplement = supplement
	# 设置初始基础兵种
	self.current_unit_list.append_array(base_units)
	var sw
	var sa
	var sv
	n = len(self.current_unit_list)
	for ui in range(0, n):
		var u = self.current_unit_list[ui]
		self.max_total_soldiers_num += u.max_num
		self.current_total_soldiers_num += u.current_num
		# 设置初始肖像
		if u.weapon_id != null:
			sw = TextureRect.new()
			sw.texture = load(GlobalConfig.weapons[u.weapon_id]["icon"])
			sw.pivot_offset = Vector2(16, 16)
			sw.position = Vector2(30+4*(ui-n/2), 5)
			sw.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			sw.stretch_mode = TextureRect.STRETCH_SCALE
			sw.size = Vector2(32, 32)
			_add_to_portrait(sw)
		if u.armour_id != null:
			sa = TextureRect.new()
			sa.texture = load(GlobalConfig.armours[u.armour_id]["icon"])
			sa.position = Vector2(30+4*(ui-n/2), 30)
			sa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			sa.stretch_mode = TextureRect.STRETCH_SCALE
			sa.size = Vector2(32, 32)
			_add_to_portrait(sa)
		if u.vehicle_id != null:	# 如果存在载具
			sv = TextureRect.new()
			sv.texture = load(GlobalConfig.vehicles[u.vehicle_id]["icon"])
			sv.position = Vector2(30+4*(ui-n/2), 55)
			sv.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			sv.stretch_mode = TextureRect.STRETCH_SCALE
			sv.size = Vector2(32, 32)
			_add_to_portrait(sv)
	# 设置滑动条
	$SupplyBar.value = self.current_supplement
	$NumberBar.max_value = self.max_total_soldiers_num
	$NumberBar.value = self.current_total_soldiers_num
	# 连接
	connect("show_info", GlobalConfig.show_unit_info)
	$"View".connect("area_entered", _record_known)
	$"View".connect("body_entered", _record_known)
	# 开启回合
	self.on_turn_begin(movement_point_cost_ratio)
	
func _record_known(obj):
	if not obj.get("belonged_faction"):
		return
	if obj.belonged_faction != belonged_faction:
		if obj.belonged_faction not in belonged_faction.visible_faction_list:
			GlobalConfig.meet_new_faction(belonged_faction, obj.belonged_faction)
		if obj is Area2D and obj not in belonged_faction.known_cities:
			belonged_faction.known_cities.append(obj)
			belonged_faction.astar.update_position(obj.tile_position, AStar.MAX_MOVEMENT_COST)

func register_faction(faction):
	$"Portrait".self_modulate = faction.faction_color
	self.belonged_faction = faction
	
func on_turn_begin(movement_point_cost_ratio=0):
	self.current_movement_point = movement_point - movement_point * movement_point_cost_ratio

func analyse_unit_strength(terrain_type):	# 评估单位战斗力
	var sd_anti = {}	# "普通近战单位", "对抗骑兵单位", "远程攻击单位", "骑兵单位", "攻城单位", "防御设施"
	var sd_defe = {}	# 各项单位自身的战力，上面是对抗这些单位时的战力
	var res
	var sd_anti_b
	var sd_defe_b
	for bu in current_unit_list:
		res = bu.analyse_basic_strength(terrain_type)
		sd_anti_b = res[0]
		for i in sd_anti_b:
			if sd_anti.get(i):
				sd_anti[i] += sd_anti_b[i]
			else:
				sd_anti[i] = sd_anti_b[i]
		sd_defe_b = res[1]
		for i in sd_defe_b:
			if sd_defe.get(i):
				sd_defe[i] += sd_defe_b[i]
			else:
				sd_defe[i] = sd_defe_b[i]
	return [sd_anti, sd_defe]

# 修改坐标后建立寻路列表
func prepare_move(clicked_tile):
	path_found.clear()
	world_path_found.clear()
	path_found = self.belonged_faction.astar.find_path(tile_position, clicked_tile)
	# 设置最终版本
	path_found = self.belonged_faction.astar.seg_path(path_found, self.current_movement_point,
													 self.movement_point)
	for node in path_found:
		var tmp = []
		for nodee in node:
			var path_position = tilemap.map_to_local(nodee)
			tmp.append(path_position)
		world_path_found.append(tmp)
	return world_path_found

func move():
	# 新任务清空
	tile_path.clear()	# 终止移动
	world_path.clear()	
	# keep both world and map position arrays in memory
	tile_path = path_found[0]
	world_path = world_path_found[0]
	if len(tile_path) > 1 and len(world_path) > 1:
		# remove first (current) position 移除当前坐标点
		tile_path.remove_at(0)
		world_path.remove_at(0)
		# get next position to move to 提出下一个位置的坐标点
		tile_position_tmp = tile_path.pop_front()
		target = world_path.pop_front()
		# 设置碰撞初始值
		last_no_collide = tile_position	# 如果发生了耗尽的碰撞，回溯到这个位置

func _physics_process(delta):	
	if not _current_inside_city and (tile_position in GlobalConfig.factionManager.player_faction.view_manager.view_highlight_tile_list or \
		not GlobalConfig.allow_fog_of_war):
		visible = true
	else:
		visible = false
	if target:
		velocity = position.direction_to(target) * speed
		if position.distance_to(target) > 5:
			if move_and_slide():
				# 发生碰撞后，强制到位
				position = target
		else:	
			tile_position = tile_position_tmp
			# 上一步的移动结束了，更新视野
			self.belonged_faction.view_manager.setup_view(self)
			self.belonged_faction.view_manager.setup_view_highlight()
			if self.belonged_faction == GlobalConfig.factionManager.player_faction:
				GlobalConfig.show_view()
			# 
			var id = self.belonged_faction.astar.valid_dict.find_key(tile_position)
			if id:
				var need_movement_point = self.belonged_faction.astar.get_point_weight_scale(id)
				# 消耗掉移动力
				if self.current_movement_point > need_movement_point:
					self.current_movement_point -= need_movement_point
				else:
					self.current_movement_point = 0
			# 检查是否仍在发生碰撞
			var collide_flag = move_and_collide(velocity*delta, true)	# 仅作检测	
			if collide_flag == null:
				last_no_collide = tile_position
			# we've reached current destination, get the next one (if any left)
			if tile_path.size() > 0:
				# 接下来的移动是合法的吗？
				tile_position_tmp = Vector2i(tile_path.pop_front())
				id = self.belonged_faction.astar.valid_dict.find_key(tile_position_tmp)
				if id:
					var need_movement_point = self.belonged_faction.astar.get_point_weight_scale(id)
					if need_movement_point > self.current_movement_point:	# 移动点不足
						tile_path.clear()	# 终止移动
						world_path.clear()	
						target = null
						tile_position_tmp = Vector2i()
						# 如果此时为强行穿过状态，回归！
						if collide_flag:
							tile_position = last_no_collide
							position = tilemap.map_to_local(tile_position)
					else:
						target = world_path.pop_front()
				else:	# 目标位置不可达
					tile_path.clear()	# 终止移动
					world_path.clear()	
					target = null
					tile_position_tmp = Vector2i()
					# 如果此时为强行穿过状态，回归！
					if collide_flag:
						tile_position = last_no_collide
						position = tilemap.map_to_local(tile_position)
			else:
				target = null
				tile_position_tmp = Vector2i()
				if collide_flag:	# 回退到最近一次没发生碰撞的地方
					tile_position = last_no_collide
					position = tilemap.map_to_local(tile_position)
			# 最后更新一遍，防止意外情况，更新视野
			self.belonged_faction.view_manager.setup_view(self)
			self.belonged_faction.view_manager.setup_view_highlight()
			if self.belonged_faction == GlobalConfig.factionManager.player_faction:
				GlobalConfig.show_view()
			# 移动完全结束时，判断是否仍在城市内
			check_in_city()

func _input_event(viewport, event, shape_idx):
	if self.belonged_faction.is_player_faction:
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT and not GlobalConfig.clicked_under_unit:
				GlobalConfig.select_unit(self)
				self.modulate.a = 0.5
				# 高亮可移动区域
				tilemap.show_reachable_cells(self.belonged_faction.astar, 
											 self.tile_position, 
											 self.current_movement_point,
											 self.belonged_faction.astar.valid_cells,
											self.current_movement_point == self.movement_point)
				# 弹出信息
				emit_signal("show_info")
	elif event is InputEventMouse and event.button_mask == MOUSE_BUTTON_RIGHT:
		if GlobalConfig.selected_unit != null:
			# 进攻了非敌对单位
			if self.belonged_faction not in GlobalConfig.selected_unit.belonged_faction.current_declare_at_war_factions:
				if attack_non_declare_confirmed == null:
					attack_non_declare_confirmed = attack_non_declare_confirmed_scene.instantiate()
					attack_non_declare_confirmed.dialog_text = "您正在尝试攻击一个未正式向其宣战的势力。"
					add_child(attack_non_declare_confirmed)
					attack_non_declare_confirmed.connect("confirmed", _confirm_unit_attack)
					attack_non_declare_confirmed.connect("canceled", _cancel_unit_attack)
			else:
				GlobalConfig.selected_unit.command_attack_unit(self)

func unselected():
	self.modulate.a = 1
	GlobalConfig.remove_current_main()

# check
func check_in_city():
	for oa in $"View".get_overlapping_areas():
		if oa.get("belonged_faction") and oa.belonged_faction == self.belonged_faction \
			and oa.tile_position == tile_position and oa != _current_in_city:
			if _current_in_city:
				_current_in_city.unit_leave_city(self)
			oa.set_unit_garrison(self)
			return
	# 上面循环未返回，说明已经离开了城市
	if _current_in_city:
		_current_in_city.unit_leave_city(self)

### UI
func _confirm_unit_attack():
	remove_child(attack_non_declare_confirmed)
	attack_non_declare_confirmed.call_deferred("free")
	attack_non_declare_confirmed = null
	GlobalConfig.selected_unit.command_attack_unit(self)
	
func _cancel_unit_attack():
	remove_child(attack_non_declare_confirmed)
	attack_non_declare_confirmed.call_deferred("free")
	attack_non_declare_confirmed = null

##################### command
func command_attack_unit(u):
	print("进攻单位")
