extends Panel

var city

@onready var cityname = $"CityName"
@onready var peoplenum = $"Main/Population/Title/Value"
@onready var people_distribution_progressbar = $"Main/Population/Main/Distribution/Value"
@onready var people_composition_progressbar = $"Main/Population/Main/Composition/Value"

func _ready():
	city = GlobalConfig.selected_city
	people_distribution_progressbar.setup(
		[
			[city.can_fight_population*city.can_useto_fight_ratio, Color(0, 1, 0), "可保卫城市"],
			[city.can_fight_population-city.can_fight_population*city.can_useto_fight_ratio, Color(0, 0, 1), "可招募"],
			[city.population - city.can_fight_population, Color(1, 1, 1), "弱势群体"]
		], city.population)

	var ctmp = []
	for k in city.population_composition:
		ctmp.append([city.population_composition[k], k.faction_color, k.tribe_name])
	people_composition_progressbar.setup(ctmp, city.population)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if city != null:
		cityname.text = city.city_name
		peoplenum.text = str(city.population)
	else:
		GlobalConfig.remove_current_main()
		
func _close():
	GlobalConfig.remove_current_main()
