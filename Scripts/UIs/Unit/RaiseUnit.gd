extends ConfirmationDialog

var city	# 关联的城市
var _user_propose_unit
var _user_propose_unit_weapon
var _user_propose_unit_armour
var _user_propose_unit_vehicle
var proposed_unit_list := []
var proposed_total_num = 0

var default_per_max_unti_num
var unit_num_set_max_checked = false

@onready var unit_num_proposed_lineedit = $"Outer/Main/Numset/Number/TextEdit"
@onready var unit_num_proposed_slider = $"Outer/Main/HSlider"
@onready var unit_num_set_max = $"Outer/Main/Numset/Number/CheckBox"
@onready var _unit_select_type = $"Outer/Main/Numset/Select/SelectType"
@onready var _unit_proposed_portrait = $"Outer/Main/UnitTools/PortraitItem/Portrait"
@onready var _unit_proposed_weapon = $"Outer/Main/UnitTools/PortraitItem/Portrait/Weapon"
@onready var _unit_proposed_armour = $"Outer/Main/UnitTools/PortraitItem/Portrait/Armour"
@onready var _unit_proposed_vehicle = $"Outer/Main/UnitTools/PortraitItem/Portrait/Vehicle"
@onready var _weapon_avail_container = $"Outer/Main/UnitTools/Weapons/Panel/GridContainer"
@onready var _armour_avail_container = $"Outer/Main/UnitTools/Armours/Panel/GridContainer"
@onready var _vehicle_avail_container = $"Outer/Main/UnitTools/Vehicles/Panel/GridContainer"
@onready var _result_units_container = $"Outer/Result/Main/Units/UnitsMain"
@onready var _prepared_unit_num = $"Outer/Result/Main/Info/UnitNum/Num"
@onready var _prepared_total_num = $"Outer/Result/Main/Info/TotalNum/Num"
@onready var _analysis_button = $"Outer/Result/Main/Analysis"

# 实例化可供招募的目标
func setup(p_c, max_base_unit_number):
	city = p_c
	for ut in city.can_recruit_unit_type:
		var bvcp = Panel.new()
		var bvc = VBoxContainer.new()
		var bu = UnitManager.BASE_UNITS[ut].new()
		var t = TextureButton.new()
		t.texture_normal = load(bu.unit_portrait_path)
		t.custom_minimum_size = Vector2(50, 100)
		t.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		t.ignore_texture_size = true
		t.stretch_mode = TextureButton.STRETCH_SCALE
		t.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		bvc.add_child(t)
		var tl = Label.new()
		tl.text = bu.unit_base_name
		tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		bvc.add_child(tl)
		bvc.set_anchors_preset(Control.PRESET_CENTER)
		bvc.set_offsets_preset(Control.PRESET_CENTER)
		bvcp.add_child(bvc)
		bvcp.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		bvcp.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bvcp.custom_minimum_size = Vector2(70, 150)
		t.connect("pressed", _propose_target.bind(ut, bu, bvcp))
		$"Outer/Main/Panel/UnitType".add_child(bvcp)
	unit_num_proposed_slider.max_value = max_base_unit_number
	default_per_max_unti_num = max_base_unit_number
	unit_num_proposed_slider.connect("value_changed", _on_slider_value_changed)
	unit_num_proposed_slider.value = city.can_fight_population
	unit_num_proposed_lineedit.connect("text_changed", _on_textedit_value_changed)
	# 显示可供使用的装备
	for w in city.avail_weapon:
		var t = TextureButton.new()
		t.texture_normal = load(GlobalConfig.weapons[w]["icon"])
		t.custom_minimum_size = Vector2(30, 30)
		t.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		t.ignore_texture_size = true
		t.stretch_mode = TextureButton.STRETCH_SCALE
		t.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		t.connect("pressed", _set_proposed_weapon.bind(w, t.texture_normal))
		_weapon_avail_container.add_child(t)
		_user_propose_unit_weapon = w
	for w in city.avail_armour:
		var t = TextureButton.new()
		t.texture_normal = load(GlobalConfig.armours[w]["icon"])
		t.custom_minimum_size = Vector2(30, 30)
		t.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		t.ignore_texture_size = true
		t.stretch_mode = TextureButton.STRETCH_SCALE
		t.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		t.connect("pressed", _set_proposed_armour.bind(w, t.texture_normal))
		_armour_avail_container.add_child(t)
		_user_propose_unit_armour = w
	for w in city.avail_vehicle:
		var t = TextureButton.new()
		t.texture_normal = load(GlobalConfig.vehicles[w]["icon"])
		t.custom_minimum_size = Vector2(30, 30)
		t.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		t.ignore_texture_size = true
		t.stretch_mode = TextureButton.STRETCH_SCALE
		t.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		t.connect("pressed", _set_proposed_vehicle.bind(w, t.texture_normal))
		_vehicle_avail_container.add_child(t)
		_user_propose_unit_vehicle = w
	connect("confirmed", _recruit_confirmed)
	connect("canceled", _recruit_cancelled)
	_analysis_button.connect("pressed", _analyse_unit)
	unit_num_set_max.connect("toggled", _toggle_check_box)

func _toggle_check_box(flag):
	unit_num_set_max_checked = flag

func _analyse_unit():
	var baseunit_tmp = UnitManager.create_unit(proposed_unit_list, city.belonged_faction)
	GlobalConfig.show_unit_analysis(baseunit_tmp)

func _propose_target(ut, bu, bvcp):
	if _user_propose_unit != bu:
		_user_propose_unit = bu	# 用户选中此单位
		bvcp["theme_override_styles/panel"] = StyleBoxFlat.new()
		bvcp["theme_override_styles/panel"].bg_color = Color(0, 0, 0, 0)
		bvcp["theme_override_styles/panel"].border_width_left = 3
		bvcp["theme_override_styles/panel"].border_width_top = 3
		bvcp["theme_override_styles/panel"].border_width_bottom = 3
		bvcp["theme_override_styles/panel"].border_width_right = 3
		bvcp["theme_override_styles/panel"].border_color = Color(0, 1, 0, 1)
		_unit_select_type.text = bu.unit_base_name
		#
		_unit_proposed_portrait.texture_normal = load(bu.unit_portrait_path)
		# 如果有可用的装备
		if len(city.avail_weapon) > 0:
			_unit_proposed_weapon.texture = _weapon_avail_container.get_child(0).texture_normal
		if len(city.avail_armour) > 0:
			_unit_proposed_armour.texture = _armour_avail_container.get_child(0).texture_normal
		if len(city.avail_vehicle) > 0:
			_unit_proposed_vehicle.texture = _vehicle_avail_container.get_child(0).texture_normal
	else:	# 用户确认点击
		bvcp.modulate.a = 0.5
		# 加入到队列中
		var _max_value = default_per_max_unti_num if not unit_num_set_max_checked else unit_num_proposed_slider.value
		var _proposed_base_unit = UnitManager.create_base_unit(
							ut, _max_value, 
							unit_num_proposed_slider.value,
							_user_propose_unit_weapon, _user_propose_unit_armour, _user_propose_unit_vehicle
							)
		proposed_unit_list.append(_proposed_base_unit)
		proposed_total_num += _proposed_base_unit.current_num
		# 在右侧展示
		var cc = VBoxContainer.new()
		var c = _unit_proposed_portrait.duplicate()
		c.connect("draw", _draw_mask.bind(c, _proposed_base_unit.recruit_need_time))
		c.connect("pressed", _cancel_this_unit.bind(cc, _proposed_base_unit))
		cc.add_child(c)
		var l = Label.new()
		l.text = str(_proposed_base_unit.current_num) + "/" + str(_max_value)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cc.add_child(l)
		cc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_result_units_container.add_child(cc)
		# 更新其余信息
		_prepared_unit_num.text = str(len(proposed_unit_list))
		_prepared_total_num.text = str(proposed_total_num)

func _draw_mask(c, number, circle_radius=16):
	# 绘制长方形蒙版
	c.draw_rect(Rect2(Vector2.ZERO, c.size), Color(0.5, 0.5, 0.5, 0.5))
	# 计算圆形的中心位置
	var circle_center = c.size / 2
	# 绘制圆形
	c.draw_circle(circle_center, circle_radius, Color(0, 1, 0, 1))
	# 绘制数字
	var font = ThemeDB.fallback_font
	# 确保有一个字体资源
	var text_size = font.get_string_size(str(number)) - Vector2(0, 9)	# 微调一下
	c.draw_string(font, circle_center - Vector2(text_size[0], -text_size[1]) / 2, 
					str(number), HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
					
func _cancel_this_unit(c, unit):
	_result_units_container.remove_child(c)
	c.queue_free()
	proposed_unit_list.erase(unit)
	# 更新数量
	proposed_total_num -= unit.current_num
	# 更新ui
	_prepared_unit_num.text = str(len(proposed_unit_list))
	_prepared_total_num.text = str(proposed_total_num)

func _recruit_confirmed():
	if len(proposed_unit_list) > 0:
		# 保存
		# 如果该城市表面已有单位，则放到驻军单位里面去
		if city.get_overlapping_bodies():
			var u = UnitManager.create_unit(proposed_unit_list, city.belonged_faction, city.tile_position, true)
			city.garrison_unit.append(u)
		else:
			var u = UnitManager.create_unit(proposed_unit_list, city.belonged_faction, city.tile_position)
		#
		city.remove_child(self)
		call_deferred("free")
		city.city_recruit_window = null
func _recruit_cancelled():
	city.remove_child(self)
	call_deferred("free")
	city.city_recruit_window = null
	
func _on_slider_value_changed(value):
	unit_num_proposed_lineedit["theme_override_colors/font_color"] = Color(1, 1, 1)  # 恢复为白色
	unit_num_proposed_lineedit.text = str(value)
func _on_textedit_value_changed(new_text):
	var value = int(new_text)
	# 检查输入是否在合法范围内
	if value < unit_num_proposed_slider.min_value or \
		value > unit_num_proposed_slider.max_value:
		unit_num_proposed_lineedit["theme_override_colors/font_color"] = Color(1, 0, 0)  # 设置为红色
	else:
		unit_num_proposed_lineedit["theme_override_colors/font_color"] = Color(1, 1, 1)  # 恢复为白色
	unit_num_proposed_slider.value = value  # 更新滑动条值
	unit_num_proposed_lineedit.caret_column = len(new_text)
func _set_proposed_weapon(wid, t):
	_user_propose_unit_weapon = wid 
	_unit_proposed_weapon.texture = t
func _set_proposed_armour(aid, t):
	_user_propose_unit_armour = aid 
	_unit_proposed_armour.texture = t
func _set_proposed_vehicle(vid, t):
	_user_propose_unit_vehicle = vid 
	_unit_proposed_vehicle.texture = t
	
func _process(delta):
	if len(proposed_unit_list) == 0:
		get_ok_button().disabled = true
		get_ok_button().tooltip_text = "您必须部署至少一个单位。"
	else:
		get_ok_button().disabled = false
		get_ok_button().tooltip_text = ""
