extends Label

func _on_HSlider_value_changed(value):
	if value > 0:
		text = "Cut Length: %d" % value
	else:
		text = "Cut Length: 0 (Erase)"
