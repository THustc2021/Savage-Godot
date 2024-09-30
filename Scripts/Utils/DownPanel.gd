extends Panel

var offset_unit_panel

func _ready():
	offset_unit_panel = get_rect().position + Vector2(288, 40)
	$"Outer/Panel/Inner/Analyse".connect("pressed", GlobalConfig.show_unit_analysis)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if GlobalConfig.selected_unit != null:
		var u = GlobalConfig.selected_unit
		$"Outer/Panel/Inner/Basic/CommanderName".text = u.commander.general_name
		var us = GlobalConfig.UNIT_STATE
		if u.current_state == us.IDLE:
			$"Outer/Panel/Inner/Basic/State".text = "空闲"
		elif u.current_state == us.SETTLE:
			$"Outer/Panel/Inner/Basic/State".text = "驻扎"
		elif u.current_state == us.COLLECT:
			$"Outer/Panel/Inner/Basic/State".text = "收集"
		$"Outer/Panel/Inner/MovementPoint".text = "移动力：" + str(u.current_movement_point) \
												+ "/" + str(u.movement_point)
		$"Outer/Panel/Inner/Supplement/ProgressBar".max_value = u.supplement
		$"Outer/Panel/Inner/Supplement/ProgressBar".value = u.current_supplement
		$"Outer/Panel/Inner/Numer/ProgressBar".max_value = u.max_total_soldiers_num
		$"Outer/Panel/Inner/Numer/ProgressBar".value = u.current_total_soldiers_num
		#显示基本单位
		for c in $Outer/UnitPanel/BaseUnits.get_children():
			c.queue_free()
		for bu in u.current_unit_list:
			var v = bu.get_portrait()
			$Outer/UnitPanel/BaseUnits.add_child(v)
	else:
		GlobalConfig.remove_current_main()
