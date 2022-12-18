extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var islands = get_parent().get_node("Islands").get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	var new_positions = rpc("get_island_positions")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
