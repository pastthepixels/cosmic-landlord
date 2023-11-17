extends Control

func _on_button_pressed():
	$FadeRect.show()
	var tween = get_tree().create_tween()
	tween.tween_property($MenuTheme, "volume_db", -20, 1.33).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property($FadeRect, "modulate:a", 1, 1.33).set_trans(Tween.TRANS_SINE)
	$DrumFill.play()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_drum_fill_finished():
	get_tree().change_scene_to_file("res://scenes/planet_screen/planet_screen.tscn")
