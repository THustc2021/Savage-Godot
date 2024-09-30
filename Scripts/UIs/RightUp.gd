extends Control

var ptrd := 0
var visible_list := []
var tmp_f

@onready var lastSprite = $"lastSprite"
@onready var centerSprite = $"centerSprite"
@onready var nextSprite = $"nextSprite"
@onready var nextnextSprite = $"nextnextSprite"

@onready var lastPlaceholder = $"lastSprite".duplicate()
@onready var centerPlaceholder = $"centerSprite".duplicate()
@onready var nextPlaceholder = $"nextSprite".duplicate()
@onready var nextnextPlaceholder = $"nextnextSprite".duplicate()

func _ready():
	$"AnimationPlayer".connect("animation_finished", _animation_finished)
	
func _compare_by_name(a, b):
	return true if a.id_in_game < b.id_in_game else false

func setup_this_turn():
	visible_list = [GlobalConfig.factionManager.player_faction]
	visible_list.append_array(GlobalConfig.factionManager.player_faction.visible_faction_list)
	# 排序
	visible_list.sort_custom(_compare_by_name)
	ptrd = 0
	tmp_f = null
	$"AnimationPlayer".stop()
	# 设置标签名
	$"Label".text = visible_list[ptrd].tribe_name
	reset_centerSprite(ptrd)
	reset_nextSprite(ptrd+1)
	if len(visible_list) > 2:
		reset_lastSprite(-1)
	else:
		reset_lastSprite(2)	# 取不到的值
	reset_nextnextSprite(ptrd+2)

func update_f_on_list(f):	# 在运行时发现的新势力，加入到列表中
	visible_list.append(f)
	visible_list.sort_custom(_compare_by_name)
	# 如果是当前文明执行过程中的前序文明，则插入到列表前；ptrd+1；并且如果正好是前序文明，则重设lastSprite
	if f.id_in_game - visible_list[ptrd].id_in_game < 0:	# 更早的势力
		ptrd += 1
		if visible_list.find(f) == ptrd - 1: # 如果紧邻
			reset_lastSprite(ptrd - 1)
	elif f.id_in_game - visible_list[ptrd].id_in_game > 0:	# 如果是当前文明执行过程中的，则插入到列表后；
		# 如果正是当前文明！则重置所有值，同时ptrd+1（因为ptrd默认会滞后）
		if f == tmp_f:
			ptrd += 1
			_reset_all()
		# 并且如果正好是后序文明，则重设nextSprite（nextSprite或许也该设置）
		elif visible_list.find(f) == ptrd + 1:
			reset_nextSprite(ptrd + 1)
			reset_nextnextSprite(ptrd + 2)
			if ptrd == 0 and len(visible_list) == 3:	# 如果因此导致3个文明，则更新
				reset_lastSprite(-1)
		else:
			if visible_list.find(f) == len(visible_list) - 1 and ptrd == 0:	# 若是列表中最后的文明
				reset_lastSprite(-1)
	else:
		printerr("更新势力回合出错：新发现的势力与已发现的势力相同")	# 考虑到重建问题？

func reset_centerSprite(ptr):
	var s = get_node("centerSprite")
	if s != null:
		remove_child(s)
		s.free()
	if ptr < len(visible_list):
		centerSprite = visible_list[ptr].icon.duplicate()
		centerSprite.name = "centerSprite"
	else:
		centerSprite = centerPlaceholder.duplicate()
	add_child(centerSprite)
	centerSprite.scale = Vector2(1, 1)
	centerSprite.position = Vector2(80, 16)
	
func reset_nextSprite(ptr):
	var s = get_node("nextSprite")
	if s != null:
		remove_child(s)
		s.free()
	if ptr < len(visible_list):
		nextSprite = visible_list[ptr].icon.duplicate()
		nextSprite.name = "nextSprite"
	else:
		nextSprite = nextPlaceholder.duplicate()
	add_child(nextSprite)
	nextSprite.scale = Vector2(0.5, 0.5)
	nextSprite.position = Vector2(173, 13)
	
func reset_lastSprite(ptr):
	var s = get_node("lastSprite")
	if s != null:
		remove_child(s)
		s.free()
	if ptr < len(visible_list):
		lastSprite = visible_list[ptr].icon.duplicate()
		lastSprite.name = "lastSprite"	# 改掉了已有结点的名称
	else:
		lastSprite = lastPlaceholder.duplicate()
	add_child(lastSprite)
	lastSprite.scale = Vector2(0.5, 0.5)
	lastSprite.position = Vector2(34, 13)
	
func reset_nextnextSprite(ptr):
	var s = get_node("nextnextSprite")
	if s != null:
		remove_child(s)
		s.free()
	if ptr < len(visible_list):
		nextnextSprite = visible_list[ptr].icon.duplicate()
		nextnextSprite.name = "nextnextSprite"
	else:
		nextnextSprite = nextnextPlaceholder.duplicate()
	add_child(nextnextSprite)
	nextnextSprite.scale = Vector2(0, 0)
	nextnextSprite.position = Vector2(0, 0)
	
func _reset_all():
	# 重设四个状态
	reset_lastSprite(ptrd-1)
	reset_centerSprite(ptrd)
	$"Label".text = visible_list[ptrd].tribe_name
	if ptrd + 1 >= len(visible_list) and ptrd + 1 != 2:
		reset_nextSprite(0)
	else:
		reset_nextSprite(ptrd+1)
	if ptrd + 2 >= len(visible_list):
		reset_nextnextSprite(0)
	else:
		reset_nextnextSprite(ptrd+2)
	
func _animation_finished(_n):
	ptrd += 1
	_reset_all()
	
func update(f):
	if f not in visible_list:
		tmp_f = f
		return
	$AnimationPlayer.play("turn")
	
	
