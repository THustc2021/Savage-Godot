class_name Base_Base_Unit

var movement_point
var recruit_need_time

var portrait_scene
var unit_portrait_path
var unit_base_name
var unit_base_description

var weapon_id
var armour_id
var vehicle_id
var current_type = UnitManager.BASE_UNIT_LAND_CLASS.MELEE	# 属于六类（实际是五类）中的哪一个 
						# "普通近战单位", "对抗骑兵单位", "远程攻击单位", "骑兵单位", "攻城单位", "防御设施"
						
var max_num
var current_num	# 当前人数

var current_morale	# 当前士气，最大10
var current_mastery_dict := {}	# 当前熟练度，0.5-2之间, 0.5代表该单位尚不掌握该武器使用方法
						
var basic_morale = 0 # 基础士气
var basic_close_hitting_strength = 0	# 近战攻击敌人的战斗力
var basic_close_defending_strength = 0	# 近战防御敌人的战斗力
var basic_remote_hitting_strength = 0	# 远程攻击敌人时的战斗力
var basic_remote_defending_strength = 0 # 远程防御敌人时的战斗力
var basic_terrain_bonus := {}	# 地形战斗加成

# 最基本的单位
func setup(max_num_, current_num_, weapon_id_=null, armour_id_=null, vehicle_id_=null):
	self.max_num = max_num_
	self.current_num = current_num_
	self.weapon_id = weapon_id_
	self.armour_id = armour_id_
	self.vehicle_id = vehicle_id_
	if vehicle_id != null:
		if GlobalConfig.vehicles[vehicle_id].get("type"):
			current_type = GlobalConfig.vehicles[vehicle_id]["type"]
	if weapon_id != null:
		if current_type == null and GlobalConfig.weapons[weapon_id].get("type"):
			current_type = GlobalConfig.weapons[weapon_id]["type"]
	
func analyse_basic_strength(terrain_type):	# 获取此单位的基础战斗力
	var sd_anti = {}	# "普通近战单位", "对抗骑兵单位", "远程攻击单位", "骑兵单位", "攻城单位", "防御设施"
	var sd_defe = {}	# 各项单位自身的战力，上面是对抗这些单位时的战力
	# 自身是普通近战单位
	var current_mastery = current_mastery_dict[weapon_id] if current_mastery_dict.get(weapon_id) else 0.5
	var astc = basic_close_hitting_strength * current_num * (current_morale / 10) * current_mastery
	var dstc = basic_close_defending_strength * current_num * (current_morale / 10)
	var astr = basic_remote_hitting_strength * current_num * ((current_morale / 10) ** (1/2)) * current_mastery
	var dstr = basic_remote_defending_strength
	if current_type == UnitManager.BASE_UNIT_LAND_CLASS.MELEE:
		# 对抗近战单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.MELEE] = max(astc + dstc ** (1/2), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.MELEE] = astc ** (1/2) + dstc
		# 对抗抗骑兵单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.ANTIC] = max(astc + dstc ** (1/2) * 1.25, astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.ANTIC] = (astc ** (1/2) + dstc) * 1.25
		# 对抗远程攻击单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.REMOTE] = max((astc + dstc ** (1/3)) * 1.75, astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.REMOTE] = dstr
		# 对抗骑兵单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.CAVAL] = max((astc + dstc ** (2/3))*0.5, astr * 0.8)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.CAVAL] = (astc ** (1/2) + dstc) * 0.75
		# 对抗攻城单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.RANGE] = max((astc + dstc ** (1/3)) * 2, astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.RANGE] = dstr * 0.5
		# 对抗防御设施
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.DEFENCE] = max(astc + dstc ** (1/3), astr) * 0.5
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.DEFENCE] = dstr * 0.6
	elif current_type == UnitManager.BASE_UNIT_LAND_CLASS.ANTIC:
		# 对抗近战单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.MELEE] = max((astc + dstc ** (1/2)) * 0.75, astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.MELEE] = (astc ** (1/2) + dstc) * 0.75
		# 对抗抗骑兵单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.ANTIC] = max(astc + dstc ** (1/2), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.ANTIC] = astc ** (1/2) + dstc
		# 对抗远程攻击单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.REMOTE] = max((astc + dstc ** (1/3)) * 1.25, astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.REMOTE] = dstr
		# 对抗骑兵单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.CAVAL] = max((astc + dstc ** (2/3))*0.5, astr * 0.8)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.CAVAL] = (astc ** (1/2) + dstc) * 2
		# 对抗攻城单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.RANGE] = max((astc + dstc ** (1/3)) * 1.5, astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.RANGE] = dstr * 0.5
		# 对抗防御设施
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.DEFENCE] = max(astc + dstc ** (1/3), astr) * 0.35
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.DEFENCE] = dstr * 0.6
	elif current_type == UnitManager.BASE_UNIT_LAND_CLASS.REMOTE:
		# 对抗近战单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.MELEE] = max(astc + dstc ** (1/2), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.MELEE] = astc ** (1/2) + dstc
		# 对抗抗骑兵单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.ANTIC] = max(astc + dstc ** (1/2), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.ANTIC] = astc ** (1/2) + dstc
		# 对抗远程攻击单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.REMOTE] = max(astc + dstc ** (1/3), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.REMOTE] = dstr
		# 对抗骑兵单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.CAVAL] = max((astc + dstc ** (2/3))*0.5, astr * 0.8)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.CAVAL] = (astc ** (1/2) + dstc) * 0.25
		# 对抗攻城单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.RANGE] = max(astc + dstc ** (1/3), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.RANGE] = dstr * 0.5
		# 对抗防御设施
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.DEFENCE] = max(astc + dstc ** (1/3), astr) * 0.75
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.DEFENCE] = dstr * 0.5
	elif current_type == UnitManager.BASE_UNIT_LAND_CLASS.CAVAL:
		# 对抗近战单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.MELEE] = max(astc + dstc ** (1/2), astr) * 1.25
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.MELEE] = (astc ** (1/2) + dstc) * 1.5
		# 对抗抗骑兵单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.ANTIC] = max((astc + dstc ** (1/2)) * 0.25, astr * 1.25)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.ANTIC] = (astc ** (1/2) + dstc) * 1.25
		# 对抗远程攻击单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.REMOTE] = max((astc + dstc ** (1/3)) * 1.75, astr * 1.25)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.REMOTE] = dstr
		# 对抗骑兵单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.CAVAL] = max((astc + dstc ** (2/3)), astr * 0.8)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.CAVAL] = astc ** (1/2) + dstc
		# 对抗攻城单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.RANGE] = max((astc + dstc ** (1/3)) * 2.25, astr * 1.25)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.RANGE] = dstr * 0.5
		# 对抗防御设施
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.DEFENCE] = max((astc + dstc ** (1/3)) * 0.1, astr * 0.75)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.DEFENCE] = dstr * 0.5
	elif current_type == UnitManager.BASE_UNIT_LAND_CLASS.RANGE:
		# 对抗近战单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.MELEE] = max(astc + dstc ** (1/2), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.MELEE] = astc ** (1/2) + dstc
		# 对抗抗骑兵单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.ANTIC] = max(astc + dstc ** (1/2), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.ANTIC] = astc ** (1/2) + dstc
		# 对抗远程攻击单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.REMOTE] = max(astc + dstc ** (1/3), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.REMOTE] = dstr
		# 对抗骑兵单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.CAVAL] = max(astc + dstc ** (2/3), astr * 0.8)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.CAVAL] = (astc ** (1/2) + dstc) * 0.25
		# 对抗攻城单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.RANGE] = max(astc + dstc ** (1/3), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.RANGE] = dstr * 0.5
		# 对抗防御设施
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.DEFENCE] = max((astc + dstc ** (1/3)) * 0.25, astr * 2)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.DEFENCE] = dstr * 0.5
	else:
		# 对抗近战单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.MELEE] = max(astc + dstc ** (1/2), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.MELEE] = astc ** (1/2) + dstc
		# 对抗抗骑兵单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.ANTIC] = max(astc + dstc ** (1/2), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.ANTIC] = astc ** (1/2) + dstc
		# 对抗远程攻击单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.REMOTE] = max(astc + dstc ** (1/3), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.REMOTE] = dstr
		# 对抗骑兵单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.CAVAL] = max(astc + dstc ** (2/3), astr * 0.8)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.CAVAL] = (astc ** (1/2) + dstc) * 0.25
		# 对抗攻城单位
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.RANGE] = max(astc + dstc ** (1/3), astr)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.RANGE] = dstr * 0.5
		# 对抗防御设施
		sd_anti[UnitManager.BASE_UNIT_LAND_CLASS.DEFENCE] = max((astc + dstc ** (1/3)) * 0.25, astr * 2)
		sd_defe[UnitManager.BASE_UNIT_LAND_CLASS.DEFENCE] = dstr * 0.5
	return [sd_anti, sd_defe]
	
func get_portrait():
	var ps = portrait_scene.instantiate()
	ps.get_node("Portrait").texture_normal = load(unit_portrait_path)
	# 在这里设置场景的武器和盔甲图片
	if weapon_id != null:
		var w = load(GlobalConfig.weapons[weapon_id]["icon"])
		ps.get_node("Portrait/Weapon").texture = w
	if armour_id != null:
		var a = load(GlobalConfig.armours[armour_id]["icon"])
		ps.get_node("Portrait/Armour").texture = a
	if vehicle_id != null:
		var v = load(GlobalConfig.vehicles[vehicle_id]["icon"])
		ps.get_node("Portrait/Vehicle").texture = v
	#
	var num = ps.get_node("Number")
	num.max_value = self.max_num
	num.value = self.current_num
	return ps
