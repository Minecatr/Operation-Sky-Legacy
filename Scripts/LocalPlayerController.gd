extends Node

const SAVE_PATH = "user://save_config_file.ini"

onready var player = get_parent()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var nametag = $"../Nametag"
onready var _spring_arm: SpringArm = get_parent().get_node("SpringArm")
onready var _model: Spatial = get_parent().get_node("Character")
onready var net_root = get_parent().get_parent().get_node("network_root")
var state = {}

func _unhandled_input(_event):
	if Input.is_action_just_pressed("swing"):
		player.do_action("swing")
		net_root.rpc("player_swing", player.network_id)
# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("CanvasLayer").visible = true

func _process(_delta):
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
			player.use_input(str(n), true)
			rpc("player_switch_item", player.network_id, str(n))
	if Input.is_action_pressed("kill"):
		player.use_input("kill", false)
	if Input.is_action_pressed("cheat"):
		player.use_input("cheat", false)
		
		
func _physics_process(delta):
	state = {strengthX=Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left"), strengthZ=Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward"), jumpPressed=Input.is_action_just_pressed("jump"), jumpReleased=Input.is_action_just_released("jump"), _spring_arm_y_rotation=_spring_arm.rotation.y, delta=delta}
	player.do_movement(Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left"), Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward"), Input.is_action_just_pressed("jump"), Input.is_action_just_released("jump"), _spring_arm.rotation.y, delta)
	net_root.rpc("update_player", player.network_id, state)
	if player.is_moving():
		net_root.rpc("update_player_position", player.network_id, player.global_translation)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#func _on_Timer_timeout():
#	if player.is_moving():
#		net_root.rpc("update_player_position", player.network_id, player.global_translation)
