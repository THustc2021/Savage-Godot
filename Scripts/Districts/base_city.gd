extends Area2D

@onready var tilemap

var tile_position := Vector2i()
var belonged_faction

var city_name = "蛮族哨所"
var population = 200
var can_fight_population = 120	# 能够作战的总人口
var can_useto_fight_ratio = 0.1	# 当城市受到攻击时，能将可用作战人口用于防御的比例
var population_composition := {}

var can_recruit_unit_type := []	# 此城能够招募的部队类型
var avail_weapon := []
var avail_armour := []
var avail_vehicle := []

var city_panel_scene = preload("res://scenes/UIs/City/CityPanel.tscn")
var city_panel
var city_recruit_scene = preload("res://scenes/UIS/Unit/RaiseUnit.tscn")
var city_recruit_window

var garrison_unit := []	# 该城市的驻军
var _current_outside_unit = null

func setup(tilepos, faction):
	self.tilemap = GlobalConfig.tilemap
	# 设置位置属性
	self.tile_position = tilepos
	self.position = tilemap.map_to_local(tilepos)
	faction.register_city(self)
	# 设置碰撞体检测大小
	var srect = $"Portrait".get_rect().size
	$"CollisionShape2D".shape.size = Vector2i(srect)
	# 循环播放
	$"AnimationPlayer".play("rotate_sprite")
	$"View".connect("area_entered", _record_known)
	$"View".connect("body_entered", _record_known)
	$"View".connect("area_exited", _target_out)
	$"View".connect("body_exited", _target_out)
	
func _record_known(obj):
	if not obj.get("belonged_faction"):
		return
	if obj.belonged_faction != belonged_faction:
		if obj.belonged_faction not in belonged_faction.visible_faction_list:
			GlobalConfig.meet_new_faction(belonged_faction, obj.belonged_faction)
		if obj is Area2D and obj not in belonged_faction.known_cities:
			belonged_faction.known_cities.append(obj)
			belonged_faction.astar.update_position(obj.tile_position, AStar.MAX_MOVEMENT_COST)
	# 放入到节点中去
	if obj is CharacterBody2D and obj not in belonged_faction.view_manager.current_see_units:
		belonged_faction.view_manager.current_see_units.append(obj)
	if obj is Area2D and obj not in belonged_faction.view_manager.current_see_cities:
		belonged_faction.view_manager.current_see_cities.append(obj)

func _target_out(obj):
	if obj in belonged_faction.view_manager.current_see_cities:
		belonged_faction.view_manager.current_see_cities.erase(obj)
	elif obj in belonged_faction.view_manager.current_see_units:
		belonged_faction.view_manager.current_see_units.erase(obj)

func register_faction(faction):
	self.modulate = faction.faction_color
	self.belonged_faction = faction
	self.population_composition[faction] = population

func recruit_unit():	# 在此城征集单位
	if city_recruit_scene != null:
		city_recruit_window = city_recruit_scene.instantiate()
		add_child(city_recruit_window)
		city_recruit_window.setup(self, self.belonged_faction.max_base_unit_number)

func _input_event(_viewport, event, _shape_idx):
	if self.belonged_faction.is_player_faction:	# 仅有玩家支持以下动画
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if not has_overlapping_bodies() or GlobalConfig.clicked_under_unit:
				GlobalConfig.select_city(self)
				if city_panel == null:
					city_panel = city_panel_scene.instantiate()
					add_child(city_panel)
				if len(garrison_unit) > 0:
					# 展示驻扎于城市的军队
					GlobalConfig.show_city_garrisoned(self)
func unselected():
	if city_panel != null:
		remove_child(city_panel)
		city_panel.free()
	city_panel = null

func _ready():
	$"ProgressBar".position = \
					Vector2(-($"ProgressBar".size[0])/2, 
							GlobalConfig.tilemap.tile_set.tile_size[1]*0.425)
	
func _process(_delta):
	$"ProgressBar".value = self.belonged_faction.transfer_to_citystate_point


## 
func set_unit_garrison(unit):
	if unit not in garrison_unit:
		garrison_unit.append(unit)
	# 如果当前仅有1个驻军单位，直接展示
	if len(garrison_unit) <= 1:
		unit.set_outside_city()
		_current_outside_unit = unit
	else:
		unit.set_inside_city()
func unit_leave_city(unit):
	garrison_unit.erase(unit)
	if unit == _current_outside_unit:
		if len(garrison_unit):
			garrison_unit[0].set_outside_city()
			_current_outside_unit = garrison_unit[0]
		else:
			_current_outside_unit = null
	else:
		unit.set_outside_city()
##
func command_raise_unit(proposed_unit_list, general=null):
	var recruit_need_time = []
	var recruit_need_number = 0
	for bu in proposed_unit_list:
		recruit_need_time.append(bu.recruit_need_time)
		recruit_need_number += bu.current_num
	recruit_need_time = recruit_need_time.max()
	if int(recruit_need_time) == 0:
		if recruit_need_number > can_fight_population:
			print("城市人口不足！")
		else:
			var u = UnitManager.create_unit(proposed_unit_list, belonged_faction, tile_position, self, general, recruit_need_time - int(recruit_need_time))
			set_unit_garrison(u)
			can_fight_population -= recruit_need_number
			return u
