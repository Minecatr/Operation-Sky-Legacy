extends CSGBox

onready var stats = $Has.stats

func insert(statss): #INSERT
	for stat in statss:
		stats[stat] += statss[stat]
		statss[stat] -= statss[stat]
