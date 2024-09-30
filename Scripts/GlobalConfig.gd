extends Node

signal add_event(event_item)
signal update_rightup(faction_)

@export var allow_fog_of_war = true

enum UNIT_STATE{
	IDLE,
	SETTLE,
	COLLECT
}
enum EVENT_TYPE{
	MEET_NEW_FACTION,
	TECH_DEVELOPED,
	CIV_DEVELOPED
}
var base_icon_path = "res://assets/Events/"
var EVENT_INFO = {
	0: {"name": "遇见新势力", "description": "您遇见了新的势力：", "icon": base_icon_path + "meet_faction.png"},
	1: {"name": "科技经济发展", "description": "您发现了新技术：", "icon": base_icon_path + "tech_developed.png"},
	2: {"name": "社会意识发展", "description": "您的社会意识进步：", "icon": base_icon_path + "civ_developed.png"}
}

@onready var tilemap
@onready var factionManager
@onready var fog_of_war

# 科技有关
var tech_file_path = "res://xmls/technology.xml"
var tech_images_root = "res://assets/Technology/"
enum TECHS{
	STOREHOUSE, TOOLS
}
var techs := {}

# 市政有关
var civic_file_path = "res://xmls/civic.xml"
var civic_images_root = "res://assets/Civic/"
enum CIVICS{
	COMMUNAL_SOCIETY, COOPERATION
}
var civs := {}

# 装备有关
var weapon_file_path = "res://xmls/Weapons.xml"
var weapon_images_root = "res://assets/UnitTools/Weapons/"
enum WEAPONS{
	FORK
}
var weapons := {}
var armour_file_path = "res://xmls/Armours.xml"
var armour_images_root = "res://assets/UnitTools/Armours/"
enum ARMOURS{
	ANIMALCLOTHING
}
var armours := {}
var vehicle_file_path = "res://xmls/Vehicles.xml"
var vehicle_images_root = "res://assets/UnitTools/Vehicles/"
enum VEHICLES{
	CHARIOT
}
var vehicles := {}

@onready var tribe_names := []

@onready var selected_unit
@onready var selected_city
@onready var player_turn

var Unit_Down_Panel_scene = preload("res://scenes/UIs/DownPanel.tscn")
var Unit_Analysis_Panel_scene = preload("res://scenes/UIs/UnitAnalysis.tscn")
var Faction_Right_Panel_scene = preload("res://scenes/UIs/FactionPanel.tscn")
var City_Info_Panel_scene = preload("res://scenes/UIs/CityInfoPanel.tscn")
var Technology_Panel_scene = preload("res://scenes/UIs/Technology.tscn")
var Civic_Panel_scene = preload("res://scenes/UIs/Civic.tscn")
var current_main_panel
var Unit_Info_Panel

var turn_num = 0

func _ready():
	
	var file = FileAccess.open("res://assets/Texts/Tribe_Names.txt", FileAccess.READ)
	tribe_names.append_array(file.get_as_text().split("\n"))
	file.close()
	# 所有国家授予科技
	setup_target(tech_file_path, TECHS, tech_images_root, techs)
	setup_target(civic_file_path, CIVICS, civic_images_root, civs)
	setup_target(weapon_file_path, WEAPONS, weapon_images_root, weapons)
	setup_target(armour_file_path, ARMOURS, armour_images_root, armours)
	setup_target(vehicle_file_path, VEHICLES, vehicle_images_root, vehicles)
	
func show_view():
	for vec in factionManager.player_faction.view_manager.view_tile_list:
		fog_of_war.set_cell(0, vec, 1, Vector2(0, 0))
	for vec in GlobalConfig.factionManager.player_faction.view_manager.view_highlight_tile_list:
		fog_of_war.set_cell(0, vec, 2, Vector2(0, 0))

func show_faction_info():
	if current_main_panel != null:
		remove_current_main()
	current_main_panel = Faction_Right_Panel_scene.instantiate()
	$"../Main".add_child(current_main_panel)

func remove_current_main(remove_unit_info=true):
	if not remove_unit_info and Unit_Info_Panel == current_main_panel:
		return
	if Unit_Info_Panel != null:
		if Unit_Info_Panel != current_main_panel:
			$"../Main".remove_child(Unit_Info_Panel)
			Unit_Info_Panel.call_deferred("free")
		Unit_Info_Panel = null
	if current_main_panel != null:
		$"../Main".remove_child(current_main_panel)
		current_main_panel.call_deferred("free")
	current_main_panel = null

func show_technology_info():
	if current_main_panel != null:
		# 移除其他的panel
		remove_current_main()
	# 增加科技info
	current_main_panel = Technology_Panel_scene.instantiate()
	$"../Main".add_child(current_main_panel)

func show_civic_info():
	if current_main_panel != null:
		# 移除其他的panel
		remove_current_main()
	# 增加市政info
	current_main_panel = Civic_Panel_scene.instantiate()
	$"../Main".add_child(current_main_panel)
		
func show_unit_info():
	# 为根目录增加结点
	if current_main_panel != null:
		remove_current_main()
	current_main_panel = Unit_Down_Panel_scene.instantiate()
	Unit_Info_Panel = current_main_panel
	$"../Main".add_child(Unit_Info_Panel)
	
func show_unit_analysis():
	if current_main_panel != null:
		remove_current_main(false)
	current_main_panel = Unit_Analysis_Panel_scene.instantiate()
	$"../Main".add_child(current_main_panel)
	
func show_city_info():
	if current_main_panel != null:
		remove_current_main()
	current_main_panel = City_Info_Panel_scene.instantiate()
	$"../Main".add_child(current_main_panel)
	
func setup_target(xml_file_path, NAME_ENUM, images_root, saved_dict):
	var parser = XMLParser.new()
	parser.open(xml_file_path)
	var id
	var tmp_node_name
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			if node_name == "item":
				id = NAME_ENUM[(parser.get_named_attribute_value("id"))]
				saved_dict[id] = {"icon": images_root + parser.get_named_attribute_value("image")}
			elif node_name == "ability":
				if saved_dict[id].get("ability"):
					saved_dict[id]["ability"].append([])
				else:
					saved_dict[id]["ability"] = [[]]
			tmp_node_name = parser.get_node_name()
		elif parser.get_node_type() == XMLParser.NODE_TEXT and str(parser.get_node_data()).strip_edges():
			if str(tmp_node_name).begins_with("ability"):
				saved_dict[id]["ability"][len(saved_dict[id]["ability"])-1].append(parser.get_node_data())
			else:
				saved_dict[id][tmp_node_name] = parser.get_node_data()
			
func select_unit(unit):
	self.selected_unit = unit

func select_city(city):
	self.selected_city = city

func meet_new_faction(ori_f, new_f):
	ori_f.visible_faction_list.append(new_f)
	if ori_f == factionManager.player_faction:
		emit_signal("update_rightup", new_f)
		emit_signal("add_event", [EVENT_TYPE.MEET_NEW_FACTION, {"target": new_f}])

######### 
func allow_recruit_base_unit_for_faction(faction, base_unit_ids):
	faction.allow_recruit_base_unit(base_unit_ids)
	
func allow_weapon_for_faction(faction, weapon_ids):
	faction.allow_weapon(weapon_ids)
	
func allow_armour_for_faction(faction, armour_ids):
	faction.allow_armour(armour_ids)
	
func allow_vehicle_for_faction(faction, vehicle_ids):
	faction.allow_vehicle(vehicle_ids)

#########

func develop_new_tech(ori_f, tech_id):
	ori_f.tech_researched.append(tech_id)
	if tech_id in ori_f.tech_in_research:
		ori_f.tech_in_research.remove(tech_id)
	# 激活科技能力
	if techs[tech_id].get("ability") != null:
		for ability in techs[tech_id]["ability"]:
			call(ability[0], ori_f, ability[1].split(","))	# 0为名字，1为其他参数
	#
	if ori_f == factionManager.player_faction:
		emit_signal("add_event", [EVENT_TYPE.TECH_DEVELOPED, {"target": techs[tech_id]}])
		
func develop_new_civ(ori_f, civ_id):
	ori_f.civ_researched.append(civ_id)
	if civ_id in ori_f.civ_in_research:
		ori_f.civ_in_research.remove(civ_id)
	# 激活市政能力
	if civs[civ_id].get("ability") != null:
		for ability in civs[civ_id]["ability"]:
			call(ability[0], ori_f, ability[1].split(","))	# 0为名字，1为其他参数
	#
	if ori_f == factionManager.player_faction:
		emit_signal("add_event", [EVENT_TYPE.CIV_DEVELOPED, {"target": civs[civ_id]}])
