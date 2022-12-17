extends Spatial

func _on_Host_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/World.tscn")

func _on_Join_pressed():
	print($CanvasLayer/Control/VBoxContainer/Address.text)

func _on_Quit_pressed():
	get_tree().quit()
