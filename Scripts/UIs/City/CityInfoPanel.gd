extends Panel

@onready var cityname = $"CityName"
@onready var peoplenum = $"Main/Population/Main/Value"
@onready var people_distribution_progressbar = $"Main/Population/Main/DistributionValue"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var city = GlobalConfig.selected_city
	if city != null:
		cityname.text = city.city_name
		peoplenum.text = str(city.population)
		people_distribution_progressbar.max_value = city.population
		people_distribution_progressbar.value = city.can_fight_population
	else:
		GlobalConfig.remove_current_main()
		
func _close():
	GlobalConfig.remove_current_main()
