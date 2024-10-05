extends Panel

var item_scene = preload("res://scenes/UIs/TechAndCiv/Civic_Item.tscn")

func _ready():
	var civs = GlobalConfig.civs
	# 显示
	for civ in civs:
		var item = item_scene.instantiate()
		item.get_node("CivIcon").texture = load(civs[civ]["icon"])
		item.get_node("Name").text = civs[civ]["name"]
		item.tooltip_text = civs[civ]["description"]
		item.get_node("Ability").text = civs[civ]["adescription"]
		item.name = str(civ)
		$"Main/Content".add_child(item)
	# 根据玩家研究情况
	for civ in GlobalConfig.factionManager.player_faction.civ_researched:
		# 已完成的研究
		var civitem = $"Main/Content".get_node(str(civ))
		civitem["theme_override_styles/panel"] = StyleBoxFlat.new()
		var st = civitem["theme_override_styles/panel"]
		st.border_width_left = 4
		st.border_width_top = 4
		st.border_width_right = 4
		st.border_width_bottom = 4
		st.bg_color = Color(255, 255, 255, 255)
		civitem.get_node("already").value = 1
		var nex = civitem.get_node("next")
		civitem.remove_child(nex)
		nex.queue_free()
		
func _close():
	GlobalConfig.remove_current_main()
