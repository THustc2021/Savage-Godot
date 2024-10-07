extends Base_Base_Unit

# 带有自定义行为的单位
func _init():
	portrait_scene = preload("res://scenes/Units/TribesMan.tscn")
	unit_portrait_path = "res://assets/Units/BaseUnit/TribeMan.png"
	unit_base_name = "部落民"
	unit_base_description = "无需维护费的基础单位，士气极低，懂得操作基础的武器"
	recruit_need_time = 0	# 可以取决于数量

	basic_morale = 3 # 基础士气
	basic_close_hitting_strength = 1	# 近战攻击敌人的战斗力
	basic_close_defending_strength = 1	# 近战防御敌人的战斗力
	basic_remote_hitting_strength = 0	# 远程攻击敌人时的战斗力
	basic_remote_defending_strength = 1 # 远程防御敌人时的战斗力
	basic_terrain_bonus = {}	# 地形战斗加成
	
func addon_equiment_basic_strength_(equipment):
	basic_close_hitting_strength += int(equipment["acvalue"]) if equipment.get("acvalue") else 0
	basic_close_defending_strength += int(equipment["dcvalue"]) if equipment.get("dcvalue") else 0
	basic_remote_hitting_strength += int(equipment["arvalue"]) if equipment.get("arvalue") else 0
	basic_remote_defending_strength += int(equipment["drvalue"]) if equipment.get("drvalue") else 0 
  
func setup(max_num_, current_num_, weapon_id_=null, armour_id_=null, vehicle_id_=null):
	super(max_num_, current_num_, weapon_id_, armour_id_, vehicle_id_)
	
	if weapon_id_ != null:
		addon_equiment_basic_strength_(GlobalConfig.weapons[weapon_id_])
	if armour_id_ != null:
		addon_equiment_basic_strength_(GlobalConfig.armours[armour_id_])
	if vehicle_id_ != null:
		addon_equiment_basic_strength_(GlobalConfig.vehicles[vehicle_id_])
	current_morale = basic_morale
