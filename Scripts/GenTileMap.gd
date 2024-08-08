extends TileMap

@export var map_width_tiles_num = 30
@export var map_height_tiles_num = 30

var map_width = tile_set.tile_size[0] * map_width_tiles_num
##!! 注意这里，由于六边形堆叠作用，这里的高度实际上不能像宽度一样计算
#var map_height = tile_set.tile_size[1] * (107/140) * map_height_tiles_num
var height_const = 105	# 高度控制项
var map_height = map_height_tiles_num * height_const + (tile_set.tile_size[1] - height_const)

# Called when the node enters the scene tree for the first time.
func _ready():
	var source_num = tile_set.get_source_count() 
	for x in range(map_width_tiles_num):
		for y in range(map_height_tiles_num):
			set_cell(0, Vector2i(x, y), randi()%(source_num-1), Vector2i(0, 0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
