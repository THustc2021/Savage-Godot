class_name ResourceManager

static var RESOURCES = {
	0: preload("res://scenes/Resources/cow.tscn"),
	1: preload("res://scenes/Resources/sheep.tscn"),
	2: preload("res://scenes/Resources/horse.tscn"),
	3: preload("res://scenes/Resources/wheat.tscn")
}

static func create_resource(resource_id, tile_pos):
	var ds = RESOURCES[resource_id].instantiate()
	ds.setup(tile_pos)
	GlobalConfig.tilemap.add_child(ds)
