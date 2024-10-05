extends Panel

var player_tribe

var GovernmentType = ["酋邦"]

func _ready():
	$"AnimationPlayer".play("LeftPanel_movein")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	player_tribe = GlobalConfig.factionManager.player_faction
	$"Vcontainer/FactionName".text = player_tribe.tribe_name
	$"Vcontainer/BaseInfo/GovermentType/Value".text = GovernmentType[player_tribe.goverment_type]
	$"Vcontainer/BaseInfo/UnitNum/Value".text = str(len(player_tribe.unit_list)) + "/" + str(player_tribe.allowed_unit_num)
	$"Vcontainer/BaseInfo/CityNum/Value".text = str(len(player_tribe.city_list))
	$"Vcontainer/Transfer/TransferTime".text = str(player_tribe.transfer_to_citystate_point)
	$"Vcontainer/Properties/Aggressiveness/Label2".text = str(player_tribe.aggressiveness)
	$"Vcontainer/Properties/Exploration/Label2".text = str(player_tribe.exploration)
	$"Vcontainer/Properties/Peacelover/Label2".text = str(player_tribe.peacelover)
