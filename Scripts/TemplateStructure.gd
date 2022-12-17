extends TextureButton

func _ready():
	$Viewport.add_child(load("res://Scenes/Builds/"+name+".tscn").instance())
	texture_normal = $Viewport.get_texture()
	texture_hover = $Viewport.get_texture()
	texture_pressed = $Viewport.get_texture()
	texture_click_mask = $Viewport.get_texture()
func _pressed():
	if pressed == false:
		get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().Select("")
	else:
		get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().Select(name)
	for child in get_parent().get_children():
		if child != self:
			child.pressed = false


