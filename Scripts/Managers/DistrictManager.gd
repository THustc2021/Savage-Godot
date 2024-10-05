class_name DistrictManager

static var DISTRICTS = {
	0: preload("res://scenes/Districts/watchhouse.tscn")
}

static func create_district(district_id, tile_pos, faction):
	var ds = DISTRICTS[district_id].instantiate()
	ds.setup(tile_pos, faction)
	GlobalConfig.tilemap.add_child(ds)
	return ds
