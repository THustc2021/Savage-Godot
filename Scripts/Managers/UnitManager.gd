extends Node

@export var units = {
	0: preload("res://scenes/Units/Barbarian.tscn")
}

func create_unit(unit_id):
	var unit = units[unit_id].instantiate()
	add_child(unit)
	return unit
