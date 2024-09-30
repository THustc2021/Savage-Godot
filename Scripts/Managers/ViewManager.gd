extends Node

class_name ViewManager

var view_tile_list = []
var view_highlight_tile_list = []

var belonged_faction

func setup_view(target):
	if target.tile_position not in view_tile_list:
		view_tile_list.append(target.tile_position)	
		belonged_faction.astar.update_position(target.tile_position)
		belonged_faction.modify_exploration(0.25)
		
	for vec in GlobalConfig.tilemap.get_surrounding_cells(target.tile_position):
		if vec not in view_tile_list:
			view_tile_list.append(vec)	
			belonged_faction.astar.update_position(vec)
			belonged_faction.modify_exploration(0.25)

func setup_view_highlight():
	# 设置高亮视野
	view_highlight_tile_list.clear()
	for city in belonged_faction.city_list:
		# 视野检查
		if city.tile_position not in view_highlight_tile_list:
			view_highlight_tile_list.append(city.tile_position)	
		for vec in GlobalConfig.tilemap.get_surrounding_cells(city.tile_position):
			if vec not in view_highlight_tile_list:
				view_highlight_tile_list.append(vec)	
	for unit in belonged_faction.unit_list:
		# 视野检查
		if unit.tile_position not in view_highlight_tile_list:
			view_highlight_tile_list.append(unit.tile_position)	
		for vec in GlobalConfig.tilemap.get_surrounding_cells(unit.tile_position):
			if vec not in view_highlight_tile_list:
				view_highlight_tile_list.append(vec)
