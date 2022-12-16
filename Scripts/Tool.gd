extends TextureButton
func press():
	pressed = !pressed
	_pressed()
func _pressed():
	if pressed == false:
		get_parent().get_parent().get_parent().get_parent().Equip("")
	else:
		get_parent().get_parent().get_parent().get_parent().Equip(name)
	for child in get_parent().get_children():
		if child != self:
			child.pressed = false
