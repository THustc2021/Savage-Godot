extends Node

@export var districts = {
	0: preload("res://scenes/Districts/watchhouse.tscn")
}

func create_district(district_id, tile_pos, faction):
	var ds = districts[district_id].instantiate()
	ds.setup(tile_pos, faction)
	add_child(ds)
	return ds
