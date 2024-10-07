extends Panel

var target_unit

func setup(unit):	# 单位作为分析对象
	target_unit = unit
	
	var ui_Radar_Attack = $"Main/Content/PanelContainer/Attack/RadarMapAttack"
	var ui_Radar_Defend = $"Main/Content/PanelContainer/Defend/RadarMapDefend"
	
	# 调用分析图逻辑
	var res = unit.analyse_unit_strength(GlobalConfig.tilemap.grid[unit.tile_position.x][unit.tile_position.y])
	ui_Radar_Attack.data = res[0].values()
	ui_Radar_Defend.data = res[1].values()
