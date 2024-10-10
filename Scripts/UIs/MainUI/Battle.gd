extends ConfirmationDialog

@onready var leftmain =$"Main/Player"
@onready var lefticon = $"Main/Player/Icon"
@onready var leftfaction = $"Main/Player/Faction"
@onready var leftgeneral = $"Main/Player/General"
@onready var leftunits = $"Main/Player/Unit"

@onready var rightmain = $"Main/AI"
@onready var righticon = $"Main/AI/Icon"
@onready var rightfaction = $"Main/AI/Faction"
@onready var rightgeneral = $"Main/AI/General"
@onready var rightunits = $"Main/AI/Unit"

@onready var powercompare = $"Main/StrengthComp/Main"
@onready var w1 = $"Main/Prob/GridContainer/W1"
@onready var w2 = $"Main/Prob/GridContainer/W2"
@onready var w3 = $"Main/Prob/GridContainer/W3"
@onready var m = $"Main/Prob/GridContainer/M"
@onready var l1 = $"Main/Prob/GridContainer/L1"
@onready var l2 = $"Main/Prob/GridContainer/L2"
@onready var l3 = $"Main/Prob/GridContainer/L3"

func setup(attacker, defender, attacker_strength, defender_strength, probs):
	
	if attacker.belonged_faction == GlobalConfig.factionManager.player_faction:
		leftmain["theme_override_styles/panel"].border_color = attacker.belonged_faction.faction_color
		rightmain["theme_override_styles/panel"].border_color = defender.belonged_faction.faction_color
		leftfaction.text = "进攻方：" + attacker.belonged_faction.tribe_name
		rightfaction.text = "防御方：" + defender.belonged_faction.tribe_name
		leftgeneral.text = attacker.commander.general_name
		rightgeneral.text = defender.commander.general_name
		leftunits.text = "人数：" + str(attacker.current_total_soldiers_num)
		rightunits.text = "人数：" + str(defender.current_total_soldiers_num)
		var pl = attacker.belonged_faction.icon.duplicate()
		pl.anchors_preset = Control.PRESET_CENTER
		lefticon.add_child(pl)
		var pr = defender.belonged_faction.icon.duplicate()
		pr.anchors_preset = Control.PRESET_CENTER
		righticon.add_child(pr)
		powercompare.value = attacker_strength / (attacker_strength + defender_strength)
		attacker.commander.add_portrait_to_node(leftmain)
		defender.commander.add_portrait_to_node(rightmain)
		var l = [w1, w2, w3, m, l1, l2, l3]
		for i in range(len(probs)):
			l[i].text = "%.f" % (probs[i]*100) + "%"
	else:
		leftmain["theme_override_styles/panel"].border_color = defender.belonged_faction.faction_color
		rightmain["theme_override_styles/panel"].border_color = attacker.belonged_faction.faction_color
		leftfaction.text = "防御方：" + defender.belonged_faction.tribe_name
		rightfaction.text = "进攻方：" + attacker.belonged_faction.tribe_name
		leftgeneral.text = defender.commander.general_name
		rightgeneral.text = attacker.commander.general_name
		leftunits.text = "人数：" + str(defender.current_total_soldiers_num)
		rightunits.text = "人数：" + str(attacker.current_total_soldiers_num)
		var pl = defender.belonged_faction.icon.duplicate()
		pl.anchors_preset = Control.PRESET_CENTER
		lefticon.add_child(pl)
		var pr = attacker.belonged_faction.icon.duplicate()
		pr.anchors_preset = Control.PRESET_CENTER
		righticon.add_child(pr)
		powercompare.value = defender_strength / (attacker_strength + defender_strength)
		attacker.commander.add_portrait_to_node(rightmain)
		defender.commander.add_portrait_to_node(leftmain)
		var l = [l3, l2, l1, m, w3, w2, w1]
		for i in range(len(probs)):
			l[i].text = "%.f%" % (probs[i]*100) + "%"

func _on_canceled():
	## 撤退
	get_parent().remove_child(self)
	queue_free()
	

func _on_confirmed():
	## 交战
	get_parent().remove_child(self)
	queue_free()
