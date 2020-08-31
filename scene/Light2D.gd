extends Light2D

func _process(_delta):
	position = get_viewport().size / 2.0
	scale = get_viewport().size / Vector2(640, -360) # Minus is needed for vertical mirror