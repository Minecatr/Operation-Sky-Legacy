extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var move_islands = false
var my_info
var config
const config_path = "user://save_config_file.ini"
# Called when the node enters the scene tree for the first time.
func _ready():
	config = ConfigFile.new()
	config.load(config_path)
	my_info = { name = config.get_value("User", "name", "Player" + str(rand_range(0, 100))), id=get_tree().get_network_unique_id(), player_instance = get_parent().get_node("Player")}
	my_info.player_instance.get_node("Nametag").text = my_info.name
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	print("Loaded network_root Scene, doing all shit")

var player_info = {}
# Info we send to other players

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.

func _connected_ok():
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func damage_player(id, amount):
	player_info[id].player_instance.damage(amount)

remote func set_island_position(island, position):
	var islands = my_info.player_instance.get_parent().get_node("Islands").get_children()
	for value in islands:
		if value.name == island:
			value.translation = position
	#print(player_info)
	#var islands_array = my_info.player_instance.get_parent().get_node("Islands").get_children()
	#var positions = {}
	#for island in islands_array:
	#	positions[island.name] = island.translation
	#return positions

remote func update_player(id, state):
	player_info[id].player_instance.do_movement(state.strengthX, state.strengthZ, state.jumpPressed, state.jumpReleased, state._spring_arm_y_rotation, state.delta)
remote func player_swing(id):
	player_info[id].player_instance.do_action("swing")
remote func player_switch_item(id, slot):
	player_info[id].player_instance.use_input(str(slot), true)
remote func update_player_position(id, position):
	player_info[id].player_instance.translation = position
remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	var new_player = load("res://Scenes/Player.tscn").instance()
	info.player_instance = new_player
	get_parent().add_child(new_player)
	# Store the info
	player_info[id] = info
	player_info[id].player_instance.get_node("Nametag").text = player_info[id].name

	# Call function to update lobby UI here


func _on_Timer_timeout():
	if my_info.player_instance.get_tree().is_network_server():
		var islands = my_info.player_instance.get_parent().get_node("Islands").get_children()
		for island in islands:
			rpc("set_island_position", island.name, island.translation)
