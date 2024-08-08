extends Node2D

# 最后执行此脚本

# Called when the node enters the scene tree for the first time.
func _ready():
	var barbarian = $unitManager.create_unit(0)
	barbarian.setup(Vector2i(200, 200))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
