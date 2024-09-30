extends Panel

var item_scene = preload("res://scenes/UIs/Technology_Item.tscn")

func _ready():
	# 显示
	var techs = GlobalConfig.techs
	for tech in techs:
		var item = item_scene.instantiate()
		item.get_node("TechIcon").texture = load(techs[tech]["icon"])
		item.get_node("Name").text = techs[tech]["name"]
		item.tooltip_text = techs[tech]["description"]
		item.get_node("Ability").text = techs[tech]["adescription"]
		item.name = str(tech)
		$"Main/Content".add_child(item)
	# 根据玩家研究情况
	for tech in GlobalConfig.factionManager.player_faction.tech_researched:
		# 已完成的研究
		var techitem = $"Main/Content".get_node(str(tech))
		techitem["theme_override_styles/panel"] = StyleBoxFlat.new()
		var st = techitem["theme_override_styles/panel"]
		st.border_width_left = 4
		st.border_width_top = 4
		st.border_width_right = 4
		st.border_width_bottom = 4
		st.bg_color = Color(255, 255, 255, 255)
		techitem.get_node("already").value = 1
		var nex = techitem.get_node("next")
		techitem.remove_child(nex)
		nex.queue_free()
		
func _close():
	GlobalConfig.remove_current_main()
