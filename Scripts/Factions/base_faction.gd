extends Node

@onready var tilemap
@onready var is_player_faction
@onready var capital
@onready var icon
@onready var astar

@export var tribe_name:String
@export var faction_color = Color(randf(), randf(), randf())
@export var goverment_type = 0	# 0-酋邦
@export var allowed_unit_num = 3
@export var transfer_to_citystate_point = 0	

@export var aggressiveness = 0
@export var exploration = 0
@export var peacelover = 0

@export var unit_list := []
@export var city_list := []
@export var view_manager = ViewManager.new()

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
	icon = $"Icon/Sprite2D"
	icon.self_modulate = faction_color
	return self

func register_unit(unit):
	unit.register_faction(self)
	self.unit_list.append(unit)
	self.view_manager.setup_view(unit)
	self.view_manager.setup_view_highlight()

func register_capital(district):
	district.register_faction(self)
	self.capital = district
	self.city_list.append(district)
	self.view_manager.setup_view(district)
	self.view_manager.setup_view_highlight()
