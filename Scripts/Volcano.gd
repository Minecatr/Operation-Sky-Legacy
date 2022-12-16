extends CSGBox

var lava = preload("res://Scenes/LavaChunk.tscn")

func _on_Timer_timeout():
	var lava2 = lava.instance()
	var impulse = Vector3(0,rand_range(5,10),rand_range(1,5)).rotated(Vector3.UP, deg2rad(rand_range(0,360)))
	lava2.translation = Vector3(0,7,0)
	lava2.apply_impulse(Vector3.ZERO,impulse)
	lava2.rotation = impulse
	add_child(lava2)
