class_name base_general

var general_name
var general_level
var general_ability_list := []

var icon_scene = preload("res://scenes/Icons/general_icon.tscn")
var icon

func _init():
	general_name = GlobalConfig.general_names["chinese"][randi() % len(GlobalConfig.general_names["chinese"])]
	general_level = randi() % 2
	
	icon = icon_scene.instantiate()
	icon.setup()
