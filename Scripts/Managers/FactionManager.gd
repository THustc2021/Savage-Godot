extends Node

@export var factions = {
	0: preload("res://scenes/Factions/rome.tscn")
}
@onready var factions_ingame = []
@onready var player_faction

@export var tribe_base = preload("res://Scripts/Factions/base_tribe.gd")

func create_tribe(faction_id_ingame, tribe_name, astar, init_color=null, is_player_faction=false):
	var ds = tribe_base.new()
	if not ds.setup(tribe_name, astar, init_color, is_player_faction):
		ds.free()
		return null
	else:
		# 自动添加到列表中
		factions_ingame.append(ds)	
		ds.id_in_game = faction_id_ingame
		return ds
