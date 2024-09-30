extends Area2D

@onready var tilemap

var tile_position := Vector2i()

var belonged_faction

func setup(tilepos, faction):
	self.tilemap = GlobalConfig.tilemap
	faction.register_district(self)
	# 设置位置属性
	self.tile_position = tilepos
	self.position = tilemap.map_to_local(tilepos)
	# 设置碰撞体检测大小
	var srect = $"Sprite2D".get_rect().size
	$"CollisionShape2D".shape.size = Vector2i(srect)
