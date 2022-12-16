extends Spatial

onready var islands = $Islands
onready var timer = $ResourceTimer
onready var sprite = $"Islands/Main Island"

var upgrades = load("res://Assets/Resources/Upgrades.tres")
var original = load("res://Assets/Resources/UpgradeValue.tres")
var rebirths = 0
var extrasources = 0
var maximumresource = {
	"Tree": upgrades.value["Max Tree"],
	"Rock": upgrades.value["Max Rock"],
	"Bush": upgrades.value["Max Bush"],
	"Cactus": 8,
	"Sand": 8,
	"Coal": 8,
	"Dirt": 8,
	"Gold": 2
}

func _ready():
	randomize()
	$Islands/Desert.translation = Vector3(rand_range(-16,16)*4,-0.25,rand_range(-16,16)*4)
	$Islands/Volcano.translation = Vector3(rand_range(-24,24)*4,-0.5,rand_range(-24,24)*4)
	$"Islands/Gravity City".translation = Vector3(rand_range(-32,32)*4,50,rand_range(-32,32)*4)
	$"Islands/Laser Matrix".translation = Vector3(rand_range(-32,32)*4,rand_range(-8,8)*4,rand_range(-32,32)*4)

func _on_ResourceTimer_timeout():
	timer.wait_time = 120.0/(float(upgrades.value["Material Spawnrate"])+2.0) #120
	maximumresource["Tree"] = upgrades.value["Max Tree"]
	maximumresource["Rock"] = upgrades.value["Max Rock"]
	maximumresource["Bush"] = upgrades.value["Max Bush"]
	for island in islands.get_children():
		for resource in island.get_node("Resources").get_children():
			if maximumresource[resource.name] > resource.get_child_count():
				var clone = load("res://Scenes/Resources/"+resource.name+".tscn").instance()
				clone.translation = Vector3(((2*randf())-1)*(island.width*0.5),0.5,((2*randf())-1)*(island.depth*0.5))
				if island.name == "Volcano" or island.name == "Desert":
					if 6-((abs(clone.translation.x)+abs(clone.translation.z))/2) > 0.5:
						clone.translation = Vector3(clone.translation.x, 6-((abs(clone.translation.x)+abs(clone.translation.z))/2), clone.translation.z)
				resource.add_child(clone)
	timer.start()

func _process(_delta):
	if upgrades.value["Extra Source"] != extrasources:
		var extrasource = load("res://Scenes/Source Island.tscn").instance()
		var dm = upgrades.value["Extra Source"] * 10
		extrasource.get_node("CSGBox").material = extrasource.get_node("CSGBox").material.duplicate()
		extrasource.translation = Vector3(rand_range(-dm,dm),clamp(rand_range(-dm,dm), -50, 100),rand_range(-dm,dm))
		$"Extra Sources".add_child(extrasource)
		extrasources += 1
	if upgrades.value["Rebirth"] != rebirths:
		for resource in $"Islands/Main Island".get_node("Resources").get_children():
			for node in resource.get_children():
				node.queue_free()
		for upgrade in upgrades.value:
			if upgrade != "Rebirth":
				upgrades.value[upgrade] = 0
				upgrades.cost[upgrade] = original.cost[upgrade]
		rebirths = upgrades.value["Rebirth"]
	if upgrades.value["PSize"]*2+8 != sprite.width:
		sprite.width = upgrades.value["PSize"]*2+8
	if upgrades.value["PSize"]*2+8 != sprite.depth:
		sprite.depth = upgrades.value["PSize"]*2+8
