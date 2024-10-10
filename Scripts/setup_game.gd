extends Control

@export var AIFactionNum = 20
var factionManager

@onready var tilemap = $"MapViewportContainer/MapViewport/TileMap"
@onready var camera = $MapViewportContainer/MapViewport/TileMap/Camera2D

var main_ai = preload("res://Scripts/Managers/AIManager.gd")
var ai_manager
var thread
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# 设置全局参数
	factionManager = FactionManager.new()
	GlobalConfig.factionManager = factionManager
	# 生成资源
	for xy in tilemap.valid_cells:
		if tilemap.grid[xy.x][xy.y] in [tilemap.GridType.GPLAIN, tilemap.GridType.DPLAIN]:
			if tilemap.grid[xy.x][xy.y] == tilemap.GridType.GPLAIN and randf() > 0.9:
				ResourceManager.create_resource(2, xy)
			elif tilemap.grid[xy.x][xy.y] == tilemap.GridType.DPLAIN and randf() > 0.9:
				ResourceManager.create_resource(3, xy)
			else:
				var tmp = randf()
				if tmp > 0.9:
					ResourceManager.create_resource(0, xy)
				elif tmp > 0.8:
					ResourceManager.create_resource(1, xy)
	# 创建玩家部落
	var player_tribe = factionManager.create_tribe(0, "颜颜部落", tilemap.create_init_path_map(), null, true)											
	var stps := []
	var warehouse_p
	var barbarian_p
	while warehouse_p == null or barbarian_p == null:
		print("错误的出生点，重新设置")
		var stp = Vector2i(randi() % tilemap.map_width_tiles_num, randi() % tilemap.map_height_tiles_num)
		if stp in tilemap.valid_cells:	# 检查坐标合法性，不合法返回空
			warehouse_p = DistrictManager.create_district(0, stp, player_tribe)
			barbarian_p = UnitManager.create_unit([UnitManager.create_base_unit(0)], player_tribe, stp, warehouse_p)
			warehouse_p.set_unit_garrison(barbarian_p)
			stps.append(stp)

	# 设置相机位置
	camera.setup(player_tribe.capital.position)
	for i in range(1, AIFactionNum+1):
		var tribe_name = GlobalConfig.tribe_names.pop_at(randi() % len(GlobalConfig.tribe_names))
		var tribe = factionManager.create_tribe(i, tribe_name, tilemap.create_init_path_map())	
		var warehouse_pp
		var barbarian_pp
		while warehouse_pp == null or barbarian_pp == null:
			print("错误的出生点，重新设置")
			var stp = Vector2i(randi() % tilemap.map_width_tiles_num, randi() % tilemap.map_height_tiles_num)
			if stp in tilemap.valid_cells:	# 检查坐标合法性，不合法返回空
				# 判断是否与已有部落过于靠近
				var flag = true
				for stpp in stps:
					if stp in tilemap.get_surrounding_cells(stpp) or stp == stpp:
						flag = false
						print("过于靠近已有部落！")
						break
				if flag:
					warehouse_pp = DistrictManager.create_district(0, stp, tribe)
					barbarian_pp = UnitManager.create_unit([UnitManager.create_base_unit(0)], tribe, stp, warehouse_pp)
					warehouse_pp.set_unit_garrison(barbarian_pp)
					stps.append(stp)
	
	$"MainInfoPanel/MainInfo/FactionButton".connect("pressed", GlobalConfig.show_faction_info)
	$"MainInfoPanel/MainInfo/TechnologyButton".connect("pressed", GlobalConfig.show_technology_info)
	$"MainInfoPanel/MainInfo/CivicButton".connect("pressed", GlobalConfig.show_civic_info)
	GlobalConfig.connect("add_event", $"RightEvent".add_event)
	GlobalConfig.connect("update_rightup", $"RightUp".update_f_on_list)

	on_game_start()

func _on_next_turn_pressed():	# 玩家结束回合
	if ai_manager == null:
		on_turn_end()
		thread = Thread.new()
		ai_manager = main_ai.new()
		thread.start( 
					ai_manager.main.bind(
						$"RightUp", self, 
						factionManager.factions_ingame, 
						tilemap
					)
				)
	
func on_turn_start():
	if thread != null:
		thread.wait_to_finish()
		thread = null
		ai_manager = null
	# 玩家开启回合
	GlobalConfig.turn_num += 1
	GlobalConfig.player_turn = true
	GlobalConfig.factionManager.player_faction.on_turn_begin()
	$"RightDown/NextTurn".disabled = false
	# 开启所有城市和单位的选择
	for u in factionManager.player_faction.unit_list:
		u.input_pickable = true
	for c in factionManager.player_faction.city_list:
		c.input_pickable = true
	$"RightDown/TurnNum".text = str(GlobalConfig.turn_num)
	$"RightUp".setup_this_turn()
	$"RightEvent".on_turn_begin()
	
func on_turn_end():
	GlobalConfig.player_turn = false
	$"RightDown/NextTurn".disabled = true
	# 禁止所有城市和单位的选择
	for u in factionManager.player_faction.unit_list:
		u.input_pickable = false
	for c in factionManager.player_faction.city_list:
		c.input_pickable = false
	$"RightEvent".on_player_turn_end()
	
func on_game_start():
	GlobalConfig.show_view()
	if not GlobalConfig.allow_fog_of_war:
		GlobalConfig.fog_of_war.visible = false
	for f in factionManager.factions_ingame:
		GlobalConfig.develop_new_tech(f, GlobalConfig.TECHS.STOREHOUSE)
		GlobalConfig.develop_new_tech(f, GlobalConfig.TECHS.TOOLS)
	for f in factionManager.factions_ingame:
		GlobalConfig.develop_new_civ(f, GlobalConfig.CIVICS.COMMUNAL_SOCIETY)
	on_turn_start()
