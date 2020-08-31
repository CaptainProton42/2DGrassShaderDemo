extends TextureRect

var drawing : bool
var img : Image

export var draw_radius : int = 20
export var cut_length : int = 0

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			drawing = true
		else:
			drawing = false

func _ready():
	# Get the base image for the grass patches
	img = texture.get_data()

	# Create a new ImageTexture that we can write to
	texture = ImageTexture.new()
	texture.create_from_image(img, 0)

	# Lock the image once
	img.lock()
	
func _process(_delta):
	if drawing:
		var pos = get_local_mouse_position() * Vector2(640, 360) / OS.get_window_size()
		# Draw grass in a circle around the cursor
		for i in range(-draw_radius, draw_radius):
			for j in range(-draw_radius, draw_radius):
				if (i*i + j*j <= draw_radius):
					var p = pos + Vector2(i, j)
					if (p.x > img.get_size().x || p.y > img.get_size().y || p.x < 0 || p.y < 0):
						continue
					img.set_pixelv(pos + Vector2(i, j), Color8(cut_length, cut_length, cut_length, 255))
					
		texture.set_data(img)

func _exit_tree():
	img.unlock()

func _on_HSlider_value_changed(value):
	cut_length = value