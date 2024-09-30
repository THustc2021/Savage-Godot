extends Node

@export var resources = {
	0: preload("res://scenes/Resources/cow.tscn"),
	1: preload("res://scenes/Resources/sheep.tscn"),
	2: preload("res://scenes/Resources/horse.tscn"),
	3: preload("res://scenes/Resources/wheat.tscn")
}

func create_resource(resource_id, tile_pos):
	var ds = resources[resource_id].instantiate()
	if not ds.setup(tile_pos):
		ds.free()
		return null
	else:
		add_child(ds)
		return ds
