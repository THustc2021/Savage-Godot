extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	var mw = GlobalConfig.tilemap.map_width_tiles_num
	var mh = GlobalConfig.tilemap.map_height_tiles_num
	
	for y in range(mh):
		for x in range(mw):
			set_cell(0, Vector2i(x,y), 0, Vector2i(0, 0))
			
	GlobalConfig.fog_of_war = self
	
	# 基于shader的实现，不对劲
	#var iw = texture.get_width()
	#var ih = texture.get_height()
	#
	##self.texture.size = Vector2(mw, mh)
	#self.scale = Vector2(mw/iw, mh/ih) + Vector2(1, 1)
	#self.position = Vector2(mw, mh) / 2
	#
	#material.set("shader_parameter/size", Vector2(self.scale[0] * iw, self.scale[1] * ih))
	#material.set("shader_parameter/offset", Vector2(self.scale[0] * iw - mw, self.scale[1]*ih - mh) / 2)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#material.set("shader_parameter/num_points", len(GlobalConfig.factionManager.player_faction.view_list))
	## 设置点的坐标 (注意这是UV坐标，0~1范围内)
	#material.set("shader_parameter/points", GlobalConfig.factionManager.player_faction.view_list)
	#material.set("shader_parameter/num_highlight_points", len(GlobalConfig.factionManager.player_faction.view_highlight_list))
	## 设置点的坐标 (注意这是UV坐标，0~1范围内)
	#material.set("shader_parameter/highlight_points", GlobalConfig.factionManager.player_faction.view_highlight_list)
