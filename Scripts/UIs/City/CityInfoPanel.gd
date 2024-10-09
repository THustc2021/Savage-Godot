extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var city = GlobalConfig.selected_city
	if city != null:
		$"Main/Title/CityName".text = city.city_name
		$"Main/Title/Population/Label2".text = str(city.population)
	else:
		GlobalConfig.remove_current_main()
		
func _close():
	GlobalConfig.remove_current_main()
