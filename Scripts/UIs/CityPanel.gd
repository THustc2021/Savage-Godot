extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$"AnimationPlayer".play("button_on_click")
	# 连接
	$"InfoButton".connect("pressed", GlobalConfig.show_city_info)
	$"RecruitButton".connect("pressed", get_parent().recruit_unit)

