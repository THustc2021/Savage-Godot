extends RigidBody2D

var window_scene = preload("res://scenes/UIs/PopupWindow_nochoice.tscn")
var event_id
var event_args

var w

func setup(event_id_, args):
	event_id = event_id_
	event_args = args
	
	$"Sprite2D".texture = load(GlobalConfig.EVENT_INFO[event_id]["icon"])
	$"Panel/Label".text = GlobalConfig.EVENT_INFO[event_id]["name"]
	
	$"Sprite2D".connect("mouse_entered", _show_descript)
	$"Sprite2D".connect("mouse_exited", _hide_descript)
	$"Sprite2D".connect("gui_input", _act)

func _act(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_RIGHT:
			get_parent().remove_event(self)
		else:
			_show_panel()

func _show_panel():
	if w == null:
		w = window_scene.instantiate() # win_size: 484, 200
		w.title = GlobalConfig.EVENT_INFO[event_id]["name"]
		if event_id == GlobalConfig.EVENT_TYPE.MEET_NEW_FACTION:
			var label = Label.new()
			label.text = GlobalConfig.EVENT_INFO[event_id]["description"] + event_args["target"].tribe_name
			label.set_anchors_preset(Control.PRESET_CENTER)
			label.position = Vector2(-120, -90)
			label.size = Vector2(200, 96)
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			var sprite = event_args["target"].icon.duplicate()
			sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			sprite.stretch_mode = TextureRect.STRETCH_SCALE
			sprite.set_anchors_preset(Control.PRESET_CENTER)
			sprite.size = Vector2(96, 96)
			sprite.position = Vector2(-230, -90)
			w.get_node("Panel").add_child(sprite)
			w.get_node("Panel").add_child(label)
		elif event_id == GlobalConfig.EVENT_TYPE.TECH_DEVELOPED or event_id == GlobalConfig.EVENT_TYPE.CIV_DEVELOPED:
			var label = Label.new()
			label.set_anchors_preset(Control.PRESET_CENTER)
			label.text = GlobalConfig.EVENT_INFO[event_id]["description"] + event_args["target"]["name"]
			label.position = Vector2(-120, -90)
			label.size = Vector2(200, 96)
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			var sprite = TextureRect.new()
			sprite.set_anchors_preset(Control.PRESET_CENTER)
			sprite.texture = load(event_args["target"]["icon"])
			sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			sprite.stretch_mode = TextureRect.STRETCH_SCALE
			sprite.size = Vector2(96, 96)
			sprite.position = Vector2(10, 10)
			sprite.position = Vector2(-230, -90)
			var label_d = Label.new()
			label_d.set_anchors_preset(Control.PRESET_CENTER)
			label_d.text = event_args["target"]["description"]
			label_d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label_d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label_d.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label_d.size = Vector2(400, 48)
			label_d.position = Vector2(-200, 30)
			w.get_node("Panel").add_child(sprite)
			w.get_node("Panel").add_child(label)
			w.get_node("Panel").add_child(label_d)
		add_child(w)
		w.connect("canceled", _close_panel)
		w.connect("confirmed", _close_panel)

func _close_panel():
	if w != null:
		remove_child(w)
		w.queue_free()
		w = null
	
func _show_descript():
	$"Panel".visible = true

func _hide_descript():
	$"Panel".visible = false
