extends Node

onready var player = get_parent()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var _spring_arm: SpringArm = get_parent().get_node("SpringArm")
onready var _model: Spatial = get_parent().get_node("Character")
var state = {}

func _unhandled_input(_event):
	if Input.is_action_just_pressed("swing"):
		player.do_action("swing")
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func _process(delta):
	_spring_arm.translation = get_parent().translation + Vector3(0,1,0) # first person and camera
	if _spring_arm.spring_length == 0:
		_model.visible = false
	else:
		_model.visible = true
	if Input.is_action_just_pressed("ui_cancel"):
		player.use_input("ui_cancel", true)
	if Input.is_action_just_pressed("rotate"):
		player.use_input("rotate", true)
	for n in range(1,9): # Hotbar
		if Input.is_action_just_pressed(str(n)):
			player.use_input("ui_cancel", true)
	if Input.is_action_pressed("kill"):
		player.use_input("kill", false)
	if Input.is_action_pressed("cheat"):
		player.use_input("cheat", false)
		
		
func _physics_process(delta):
	state = {strengthX=Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left"), strengthZ=Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward"), jumpPressed=Input.is_action_just_pressed("jump"), jumpReleased=Input.is_action_just_released("jump"), _spring_arm_y_rotation=_spring_arm.rotation.y, delta=delta}
	player.do_movement(Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left"), Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward"), Input.is_action_just_pressed("jump"), Input.is_action_just_released("jump"), _spring_arm.rotation.y, delta)
	get_parent().get_parent().get_node("network_root").rpc("update_player", player.network_id, state)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
