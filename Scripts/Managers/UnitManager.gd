class_name UnitManager

static var unit_scene = preload("res://scenes/Units/base_unit.tscn")
static var battle_ui_scene = preload("res://scenes/UIs/MainUI/Battle.tscn")

static var BASE_UNITS = {
	0: preload("res://Scripts/Units/Units/tribesman.gd")
}	# 加载脚本
enum BASE_UNIT_TYPE{
	TRIBESMAN
}
enum BASE_UNIT_LAND_CLASS{
	MELEE,
	ANTIC,
	REMOTE,
	CAVAL,
	RANGE,
	DEFENCE
}

# Sigmoid function
static func sigmoid(z: float) -> float:
	return 1.0 / (1.0 + exp(-z))
	
static func fight_battle(attacker:unit, defender:unit, terrain_type):
	var attacker_res = attacker.analyse_unit_strength(terrain_type)
	var defender_res = defender.analyse_unit_strength(terrain_type)
	var attacker_strength = 1
	var defender_strength = 1
	var attacker_att = attacker_res[0]
	var attacker_def = attacker_res[1]
	var attacker_com = attacker_res[2]
	var defender_att = defender_res[0]
	var defender_def = defender_res[1]
	var defender_com = defender_res[2]
	for k in BASE_UNIT_LAND_CLASS:
		var type = BASE_UNIT_LAND_CLASS[k]
		var att_com_k = attacker_com[type] if attacker_com.get(type) else 0
		var def_com_k = defender_com[type] if defender_com.get(type) else 0
		attacker_strength += (attacker_att[type] / defender_def[type]) * def_com_k
		defender_strength += (defender_att[type] / attacker_def[type]) * att_com_k
	#var att_win_prob = attacker_strength / ((attacker_strength / defender_strength) + defender_strength)
	#var def_wim_prob = defender_strength / ((defender_strength / attacker_strength) + attacker_strength)
	var x = attacker_strength
	var y = defender_strength
	var attacker_w1_prob = sigmoid(x - 2 * y)
	var attacker_w2_prob = sigmoid(x - 1.5 * y) - sigmoid(x - 2 * y)
	var attacker_w3_prob = sigmoid(x - 0.5 * y) - sigmoid(x - 1.5 * y)
	var attacker_m_prob = sigmoid(0.5 * y - x) - sigmoid(0.5 * y - 0.5 * x)
	var attacker_l1_prob = sigmoid(0.5 * x - y) - sigmoid(x - 0.5 * y)
	var attacker_l2_prob = sigmoid(2 * x - y) - sigmoid(0.5 * x - y)
	var attacker_l3_prob = sigmoid(2 * x - y) - sigmoid(x - 2 * y)
	
	if attacker.belonged_faction == GlobalConfig.factionManager.player_faction or \
		defender.belonged_faction == GlobalConfig.factionManager.player_faction:
		var bui = battle_ui_scene.instantiate()
		GlobalConfig.tilemap.add_child(bui)
		bui.setup(attacker, defender, attacker_strength, defender_strength,
				 [attacker_w1_prob, attacker_w2_prob, attacker_w3_prob, attacker_m_prob,
				  attacker_l1_prob, attacker_l2_prob, attacker_l3_prob])

static func create_base_unit(base_unit_id, max_num=30, current_num=30, weapon_id_=0, armour_id_=0, vehicle_id_=null):
	var base_unit = BASE_UNITS[base_unit_id].new()
	base_unit.setup(max_num, current_num, weapon_id_, armour_id_, vehicle_id_)
	return base_unit

static func create_unit(base_units, faction, tile_pos=null, garrison_city=null, general=null, raise_unit_movement_cost=0):
	var unit = unit_scene.instantiate()
	unit.setup(base_units, faction, tile_pos, garrison_city, general, raise_unit_movement_cost)
	if tile_pos != null:
		GlobalConfig.tilemap.add_child(unit)	# 添加到场景中
	return unit
