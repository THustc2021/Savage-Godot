signal update_faction_turn(f)
signal next_turn_start

func main(faction_containers, main_game, factions_ingame, tilemap):
	connect("update_faction_turn", faction_containers.update)
	connect("next_turn_start", main_game.on_turn_start)
	# 执行AI操作
	for f in factions_ingame:
		f.on_turn_begin()
		if not f.is_player_faction:
			# 更新此线程
			call_deferred("emit_signal", "update_faction_turn", f)
			# 随机移动单位
			for u in f.unit_list:
				var target_tile = Vector2i(randi()%tilemap.map_width_tiles_num, randi()%tilemap.map_height_tiles_num)
				# 判断是否合法移动
				if target_tile in f.astar.valid_cells and not u.tile_position == target_tile:
					u.prepare_move(target_tile)
					u.move()	# 这似乎是线程安全的
				else:
					print("AI need move OR out of area!")
			for i in range(1000000):
				i += 1
	call_deferred("emit_signal", "next_turn_start")
