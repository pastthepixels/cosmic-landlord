extends PanelContainer

func set_stats(temperature_level, oxygen_level, carbon_dioxide_level, water_to_land_ratio, name):
	$%Title.text = name
	$%Temp/ProgressBar.value = temperature_level
	$%Oxygen/ProgressBar.value = oxygen_level
	$"%Carbon Dioxide/ProgressBar".value = carbon_dioxide_level
	$%Land_Water/ProgressBar.value = water_to_land_ratio
