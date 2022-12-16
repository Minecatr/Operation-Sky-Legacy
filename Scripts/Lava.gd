extends Area

func _on_Hitbox_area_entered(area):
	if area.is_in_group("hitbox"):
		area.get_parent().damage(25)
		$CollisionShape.disabled = true
		$"../Timer".start()

func _on_Timer_timeout():
	$CollisionShape.disabled = false
