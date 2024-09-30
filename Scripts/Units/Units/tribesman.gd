extends Base_Base_Unit

# 带有自定义行为的单位
func _init():
	portrait_scene = preload("res://scenes/Units/TribesMan.tscn")
	unit_portrait_path = "res://assets/Units/BaseUnit/TribeMan.png"
	unit_base_name = "部落民"
	unit_base_description = "无需维护费的基础单位，士气极低，懂得操作基础的武器"
	recruit_need_time = 0	# 可以取决于数量

func setup(max_num, current_num, weapon_id_=null, armour_id_=null, vehicle_id_=null):
	
	super(max_num, current_num, weapon_id_, armour_id_, vehicle_id_)
