extends Area2D

@onready var tilemap
@export var rname:String

var tile_position := Vector2i()

func setup(tilepos):
	self.tilemap = GlobalConfig.tilemap
	# 设置位置属性
	self.tile_position = tilepos
	self.position = tilemap.map_to_local(tilepos)
	# 设置图标
	$"Icon".position = Vector2(0, tilemap.tile_set.tile_size[1] * 0.4)
	# 随机位置
	$"Sprite".position = Vector2(randf()-0.5, randf()-0.5)*Vector2(tilemap.tile_set.tile_size)*0.3
	$"Sprite2".position = Vector2(randf()-0.5, randf()-0.5)*Vector2(tilemap.tile_set.tile_size)*0.3
	$"Sprite3".position = Vector2(randf()-0.5, randf()-0.5)*Vector2(tilemap.tile_set.tile_size)*0.3
	return true
