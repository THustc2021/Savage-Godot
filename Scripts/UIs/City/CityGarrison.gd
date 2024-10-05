extends Container

var choosable_units
var choose_unit
var ui_choose_unit_panel
var _city

@onready var uppercontainer = $"Main/Upper/Main"
@onready var analysebutton 

@onready var DownMain = $"Main/Down/Main"
@onready var ui_baseunits = $"Main/Down/Main/UnitPanel/ScrollContainer/BaseUnits"
@onready var ui_commander_name = $"Main/Down/Main/Panel/Inner/Basic/CommanderName"
@onready var ui_unit_state = $"Main/Down/Main/Panel/Inner/Basic/State"
@onready var ui_movement_point = $"Main/Down/Main/Panel/Inner/MovementPoint"
@onready var ui_supplement_progressbar = $"Main/Down/Main/Panel/Inner/Supplement/ProgressBar"
@onready var ui_number_progressbar = $"Main/Down/Main/Panel/Inner/Numer/ProgressBar"

func setup(city):
	_city = city
	_reset_upper()

func _choose_unit(event, unit, panel):
	if event is InputEventMouse and event.is_pressed():
		choose_unit = unit
		if ui_choose_unit_panel != null:	# 重置
			ui_choose_unit_panel["theme_override_styles/panel"] = null
		ui_choose_unit_panel = panel

func _analyse_unit():
	GlobalConfig.show_unit_analysis(choose_unit)
	
func _reset_upper():
	for c in uppercontainer.get_children():
		uppercontainer.remove_child(c)
		c.queue_free()
	# 加入节点	
	choosable_units = _city.garrison_unit.duplicate()
	for u in choosable_units:
		var bvcp = PanelContainer.new()
		var bvc = VBoxContainer.new()
		var t = u.get_node("Portrait").duplicate()
		t.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		t.size_flags_vertical = Control.SIZE_SHRINK_END
		t.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		bvc.add_child(t)
		var tl = Label.new()
		tl.text = u.commander.general_name
		tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		bvc.add_child(tl)
		bvc.size_flags_horizontal = Control.SIZE_EXPAND
		bvc.size_flags_vertical = Control.SIZE_SHRINK_END
		bvc["theme_override_constants/separation"] = -4
		bvcp.add_child(bvc)
		bvcp.custom_minimum_size.y = 130
		t.connect("gui_input", _choose_unit.bind(u, bvcp))
		uppercontainer.add_child(bvcp)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if GlobalConfig.selected_city != _city:
		GlobalConfig.remove_current_main()
		return
	if len(choosable_units) != len(_city.garrison_unit) or choose_unit not in choosable_units:	# 发生改变，重置之
		_reset_upper()
		choose_unit = null
		ui_choose_unit_panel = null
	if choose_unit != null:
		# 设置选中
		ui_choose_unit_panel["theme_override_styles/panel"] = StyleBoxFlat.new()
		ui_choose_unit_panel["theme_override_styles/panel"].bg_color = Color(0, 0, 0, 0)
		ui_choose_unit_panel["theme_override_styles/panel"].border_width_left = 3
		ui_choose_unit_panel["theme_override_styles/panel"].border_width_top = 3
		ui_choose_unit_panel["theme_override_styles/panel"].border_width_bottom = 3
		ui_choose_unit_panel["theme_override_styles/panel"].border_width_right = 3
		ui_choose_unit_panel["theme_override_styles/panel"].border_color = Color(0, 1, 0, 1)
		# 下方的内容
		DownMain.visible = true
		ui_commander_name.text = choose_unit.commander.general_name
		if choose_unit.current_state == GlobalConfig.UNIT_STATE.IDLE:
			ui_unit_state.text = "空闲"
		elif choose_unit.current_state == GlobalConfig.UNIT_STATE.SETTLE:
			ui_unit_state.text = "驻扎"
		elif choose_unit.current_state == GlobalConfig.UNIT_STATE.COLLECT:
			ui_unit_state.text = "收集"
		ui_movement_point.text = "移动力：" + str(choose_unit.current_movement_point) \
												+ "/" + str(choose_unit.movement_point)
		ui_supplement_progressbar.max_value = choose_unit.supplement
		ui_supplement_progressbar.value = choose_unit.current_supplement
		ui_number_progressbar.max_value = choose_unit.max_total_soldiers_num
		ui_number_progressbar.value = choose_unit.current_total_soldiers_num
		#显示基本单位
		for c in ui_baseunits.get_children():
			c.queue_free()
		for bu in choose_unit.current_unit_list:
			var v = bu.get_portrait()
			ui_baseunits.add_child(v)
	else:
		# 清空所有内容
		DownMain.visible = false
