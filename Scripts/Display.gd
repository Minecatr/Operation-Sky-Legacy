extends CSGBox

onready var colors = load("res://Scenes/Stats.tscn").instance().colors
onready var statsui = $"../Viewport/ScrollContainer/VBoxContainer"

var template = preload("res://Scenes/TemplateStat3.tscn")


func _ready():
	for stat in load("res://Scenes/Stats.tscn").instance().stats.keys():
		var tc = template.instance()
		tc.name = stat
		tc.self_modulate = colors[stat]
		statsui.add_child(tc)
	$"../Timer".play("Update")

func _on_Area_area_entered(area):
	if $"..".placed and area.is_in_group("storage"):
		for container in statsui.get_children():
			container.get_node("Label").text = str(area.get_parent().get_node("Storage").stats[container.name])


func _on_Timer_animation_finished(_anim_name):
	$"../Timer".play("Update")
