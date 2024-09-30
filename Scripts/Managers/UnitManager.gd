extends Node

class_name UnitManager

static var unit_scene = preload("res://scenes/Units/base_unit.tscn")
static var base_units = {
	0: preload("res://Scripts/Units/Units/tribesman.gd")
}	# 加载脚本
enum BASE_UNIT_TYPE{
	TRIBESMAN
}

static func create_base_unit(base_unit_id, max_num=120, current_num=120, weapon_id_=0, armour_id_=0, vehicle_id_=null):
	var base_unit = base_units[base_unit_id].new()
	base_unit.setup(max_num, current_num, weapon_id_, armour_id_, vehicle_id_)
	return base_unit

func create_unit(base_units, tile_pos, faction):
	var unit = unit_scene.instantiate()
	unit.setup(tile_pos, base_units, faction)
	add_child(unit)
	return unit
