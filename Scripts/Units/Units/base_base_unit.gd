class_name Base_Base_Unit

var close_attack_strength
var close_defend_strength
var movement_point
var recruit_need_time

var portrait_scene
var unit_portrait_path
var unit_base_name
var unit_base_description

var weapon_id
var armour_id
var vehicle_id

var max_num
var current_num	# 当前人数

# 最基本的单位
func setup(max_num_, current_num_, weapon_id_=null, armour_id_=null, vehicle_id_=null):
	self.max_num = max_num_
	self.current_num = current_num_
	self.weapon_id = weapon_id_
	self.armour_id = armour_id_
	self.vehicle_id = vehicle_id_
	
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
