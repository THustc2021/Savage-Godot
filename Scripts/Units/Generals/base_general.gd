extends Node

class_name base_general

var general_name = "将军"
var general_level
var general_ability_list := []

func _init():
	general_level = randi() % 3 + 1
