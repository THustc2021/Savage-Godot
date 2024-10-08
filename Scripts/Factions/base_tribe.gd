var tilemap
var is_player_faction
var capital
var icon_scene = preload("res://scenes/Icons/tribe_icon.tscn")
var icon
var astar

@export var tribe_name:String
@export var faction_color = Color(randf(), randf(), randf())
@export var goverment_type = 0	# 0-酋邦
@export var allowed_unit_num = 3
var transfer_to_citystate_point = 0	

var aggressiveness = 0
var exploration = 0
var peacelover = 0

var id_in_game	# 在游戏中的id，跟初始生成顺序有关
var visible_faction_list := []	# 目前已经接触到的文明
var unit_list := []
var city_list := []
var view_manager = ViewManager.new()
var current_declare_at_war_factions = []	# 当前已经对其声明战争的国家
var known_cities := []	# 目前已知的城市，当城市消失后要更新这个列表
var can_recruit_unit_faction := []
var avail_weapon_faction := []
var avail_armour_faction := []
var avail_vehicle_faction := []
var max_base_unit_number = 120

var tech_researched := []	# 已经完成研究的科技
var tech_in_research := []	# 正在进行研究的科技
var civ_researched := []	# 已经完成研究的市政
var civ_in_research := []	# 正在进行研究的市政

func modify_exploration(value):
	# 揭示新地块+0.25
	# 利用新资源+1
	var tmp = exploration + value
	if tmp < 0:
		tmp = 0
	exploration = tmp
	
func modify_aggressiveness(value):
	# 下限
	var tmp = aggressiveness + value
	if tmp < 0:
		tmp = 0
	aggressiveness = tmp

func setup(tribe_name_, astar_, set_faction_color=null, is_player_faction_=false):
	#
	self.is_player_faction = is_player_faction_
	if is_player_faction:
		GlobalConfig.factionManager.player_faction = self
	self.tilemap = GlobalConfig.tilemap
	self.tribe_name = tribe_name_
	#
	self.astar = astar_
	# 设置视图管理器
	self.view_manager.belonged_faction = self
	# 设置颜色
	if set_faction_color != null:
		faction_color = set_faction_color
	icon = icon_scene.instantiate()
	icon.self_modulate = faction_color
	return self

func register_unit(unit):
	unit.register_faction(self)
	self.unit_list.append(unit)
	self.view_manager.setup_view(unit)
	self.view_manager.setup_view_highlight()

func register_city(city):
	city.register_faction(self)
	if len(self.city_list) == 0:
		self.capital = city
	self.city_list.append(city)
	self.view_manager.setup_view(city)
	self.view_manager.setup_view_highlight()

func get_tiles_unreachable(unit):
	var unreachable_tiles := []
	for u in self.view_manager.current_see_units:
		if u != unit:
			unreachable_tiles.append(u.tile_position)
	for c in self.view_manager.current_see_cities:
		if c.belonged_faction != self:
			unreachable_tiles.append(c.tile_position)
	return unreachable_tiles
	
func turn_begin_technology():
	# 更改科技进度
	pass

func on_turn_begin():
	for unit in self.unit_list:
		unit.on_turn_begin()
	turn_begin_technology()

#########

func allow_recruit_base_unit(base_unit_ids):
	for base_unit_id in base_unit_ids:
		base_unit_id = UnitManager.BASE_UNIT_TYPE[base_unit_id]
		if base_unit_id not in can_recruit_unit_faction:
			can_recruit_unit_faction.append(base_unit_id)
		for city in city_list:
			if base_unit_id not in city.can_recruit_unit_type:
				city.can_recruit_unit_type.append(base_unit_id)
				
func allow_weapon(weapon_ids):
	for weapon_id in weapon_ids:
		weapon_id = GlobalConfig.WEAPONS[weapon_id]
		if weapon_id not in avail_weapon_faction:
			avail_weapon_faction.append(weapon_id)
		for city in city_list:
			if weapon_id not in city.avail_weapon:
				city.avail_weapon.append(weapon_id)
	
func allow_armour(armour_ids):
	for armour_id in armour_ids:
		armour_id = GlobalConfig.ARMOURS[armour_id]
		if armour_id not in avail_armour_faction:
			avail_armour_faction.append(armour_id)
		for city in city_list:
			if armour_id not in city.avail_armour:
				city.avail_armour.append(armour_id)
	
func allow_vehicle(vehicle_ids):
	for vehicle_id in vehicle_ids:
		vehicle_id = GlobalConfig.VEHICLES[vehicle_id]
		if vehicle_id not in avail_vehicle_faction:
			avail_vehicle_faction.append(vehicle_id)
		for city in city_list:
			if vehicle_id not in city.avail_vehicle:
				city.avail_vehicle.append(vehicle_id)
