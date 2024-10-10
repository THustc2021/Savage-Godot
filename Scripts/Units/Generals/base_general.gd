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
	
func add_portrait_to_node(node):
	var cicon = icon.duplicate()
	cicon.anchors_preset = Control.PRESET_CENTER
	cicon.self_modulate = Color(0.5, 0.5, 0.5, 1)
	cicon.scale = Vector2(4, 4)
	node.add_child(cicon)
	node.move_child(cicon, 0)
