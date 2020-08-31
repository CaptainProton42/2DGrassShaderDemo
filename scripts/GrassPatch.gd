extends TextureRect

var drawing

var img

export var draw_radius : int
export var cut_length : int

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			drawing = true
		else:
			drawing = false

func _ready():
	img = texture.get_data()
	texture = ImageTexture.new()
	texture.create_from_image(img, 0)
	img.lock()
	
func _process(_delta):
	if drawing:
		var pos = get_local_mouse_position() * Vector2(640, 360) / OS.get_window_size()
		print(pos)
		for i in range(-draw_radius, draw_radius):
			for j in range(-draw_radius, draw_radius):
				if (i*i + j*j <= draw_radius):
					img.set_pixelv(pos + Vector2(i, j), Color8(cut_length, cut_length, cut_length, 255))
					
		texture.create_from_image(img, 0)


func _on_HSlider_value_changed(value):
	cut_length = value
