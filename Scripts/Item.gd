extends RigidBody

onready var stats = $Stats.stats

var upgrades = load("res://Assets/Resources/Upgrades.tres")

func _ready():
	var material = SpatialMaterial.new()
	var color = Color(0,0,0)
	var divider = 0
	for stat in stats.keys():
		divider += stats[stat]
		color += $Stats.colors[stat]*stats[stat]
	color /= divider
	material.albedo_color = color
	$CSGSphere.material = material

func collect(player):
	player.collect_stat(stats)
	queue_free()
	$CSGSphere.material = SpatialMaterial

func _physics_process(_delta):
	if translation.y < -100:
		queue_free()
