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

var attack_non_declare_confirmed_scene = preload("res://scenes/UIs/PopupWindow.tscn")
var attack_non_declare_confirmed

func setup(tilepos, base_units, faction, general=null):
	tilemap = GlobalConfig.tilemap
	# 设置位置属性
	tile_position = tilepos
	position = tilemap.map_to_local(tilepos)
	faction.register_unit(self)
	# 设置指挥者
	if general == null:
		self.commander = load("res://Scripts/Units/Generals/base_general.gd").new()
	else:
		self.commander = general
	# 设置初始状态
	self.current_state = GlobalConfig.UNIT_STATE.IDLE
	# 设置当前补给数量（应当从国家仓库中扣除）
	self.current_supplement = supplement
	# 设置初始基础兵种
	self.current_unit_list.append_array(base_units)
	var sw
	var sa
	var sv
	var n = len(self.current_unit_list)
	for ui in range(0, n):
		var u = self.current_unit_list[ui]
		self.max_total_soldiers_num += u.max_num
		self.current_total_soldiers_num += u.current_num
		# 设置初始肖像
		sw = Sprite2D.new()
		if u.weapon_id != null:
			sw.texture = load(GlobalConfig.weapons[u.weapon_id]["icon"])
			sw.position = Vector2(-50*(ui-n/2)/n, -30)
			sw.scale = Vector2(32, 32) / sw.texture.get_size()
			$"Background".add_child(sw)
		if u.armour_id != null:
			sa = Sprite2D.new()
			sa.texture = load(GlobalConfig.armours[u.armour_id]["icon"])
			sa.position = Vector2(-50*(ui-n/2)/n, 0)
			sa.scale = Vector2(32, 32) / sa.texture.get_size()
			$"Background".add_child(sa)
		if u.vehicle_id != null:	# 如果存在载具
			sv = Sprite2D.new()
			sv.texture = load(GlobalConfig.vehicles[u.vehicle_id]["icon"])
			sv.position = Vector2(-50*(ui-n/2)/n, 30)
			sv.scale = Vector2(32, 32) / sv.texture.get_size()
			$"Background".add_child(sv)
	var st
	n = self.commander.general_level
	for gi in range(0, n):
		st = Sprite2D.new()
		st.texture = star_icon
		st.position = Vector2(-80*(gi-n/2)/n, -60+(gi-n/2)*(gi-n/2))
		st.scale = Vector2(32, 32) / st.texture.get_size()
		$"Background".add_child(st)
	# 设置滑动条
	$SupplyBar.value = self.current_supplement
	$NumberBar.max_value = self.max_total_soldiers_num
	$NumberBar.value = self.current_total_soldiers_num
	# 连接
	connect("show_info", GlobalConfig.show_unit_info)
	$"View".connect("area_entered", _record_known)
	$"View".connect("body_entered", _record_known)
	# 开启回合
	self.on_turn_begin()
	
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
	$"Background".self_modulate = faction.faction_color
	self.belonged_faction = faction
	
func on_turn_begin():
	self.current_movement_point = movement_point

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
	if tile_position in GlobalConfig.factionManager.player_faction.view_manager.view_highlight_tile_list or \
		not GlobalConfig.allow_fog_of_war:
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
				# 目标位置是否有城市中心
				#var hit_city = false
				#for oa in $"View".get_overlapping_areas():
					#if oa.get("belonged_faction") and oa.belonged_faction != self.belonged_faction \
						#and oa.tile_position == tile_position_tmp:
						#hit_city = true
						#break
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
			# 

func _input_event(_viewport, event, _shape_idx):
	if self.belonged_faction.is_player_faction:
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
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
