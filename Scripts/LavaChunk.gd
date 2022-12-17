extends RigidBody

func _ready():
	$CSGBox.material = $CSGBox.material.duplicate()
	$AnimationPlayer.play("Start")

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
