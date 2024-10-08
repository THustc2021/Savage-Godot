extends Control

var event_list := []
var event_list_tmp := []
var MAX_SHOW_NUM = 10
var current_show_num = 0

var item_scene = preload("res://scenes/UIs/MainUI/EventNote.tscn")

func show_event(event_item):
	if current_show_num < MAX_SHOW_NUM:
		# 立即激活
		var item = item_scene.instantiate()
		item.setup(event_item[0], event_item[1])
		item.add_to_group("event_this_turn")
		call_deferred("add_child", item)
		await GlobalConfig.get_tree().create_timer(0.01).timeout
		current_show_num += 1
	else:
		event_list_tmp.append(event_item)

func add_event(event_item):
	if GlobalConfig.player_turn:
		show_event(event_item)
	else:
		event_list.append(event_item)
		
func remove_event(event_node):
	remove_child(event_node)
	event_node.queue_free()
	current_show_num -= 1
	if len(event_list_tmp) > 0:
		show_event(event_list_tmp.pop_at(0))
	
func on_turn_begin():
	for item in event_list:
		show_event(item)
		await get_tree().create_timer(0).timeout	# 手动等待一帧
	
func on_player_turn_end():
	for c in get_children():
		if c.is_in_group("event_this_turn"):
			remove_child(c)
			c.queue_free()
	event_list.clear()
