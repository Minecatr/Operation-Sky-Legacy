extends KinematicBody

export var speed := 5.0
export var jump_strength := 15.0
export var gravity := 50.0

var _velocity := Vector3.ZERO
var _snap_vector := Vector3.DOWN
var jumping := false
var cachepos := translation

onready var _spring_arm: SpringArm = $SpringArm
onready var _model: Spatial = $Character

####################################################


signal health_updated(health)
signal killed()

# const Big = preload("res://Scripts/Big.gd")

export (int) var max_health = 100

onready var health = max_health setget _set_health
onready var invulnerability_timer = $InvulnerabilityTimer
# onready var effects_animation = $EffectsAnimation

onready var animation_player = $Character/RootNode/AnimationPlayer
onready var character = $Character
#onready var arms = $Arms/Arms
# onready var ui = $CanvasLayer/UI
onready var structuresfolder = $"../Structures"
onready var statsui = $CanvasLayer/UI/Tab/TabContainer/Stats/VBoxContainer
onready var upgradesui = $CanvasLayer/UI/Tab/TabContainer/Upgrades/VBoxContainer
onready var furnaceui = $CanvasLayer/UI/Tab/MiddleTabs/Furnace
onready var structuresui = $CanvasLayer/UI/Tab/SideTabs/Build/GridContainer
onready var quickbar = $CanvasLayer/UI/Quickbar/HBoxContainer
onready var settings = $CanvasLayer/UI/Tab/TabContainer/Settings/VBoxContainer
onready var stats = $Stats.stats
onready var statcolors = $Stats.colors
# onready var health = $Stats.health
onready var healthbar = $CanvasLayer/UI/Quickbar/HBoxContainer/Health

onready var animplayer = $CanvasLayer/UI/AnimationPlayer
onready var bgm = $CanvasLayer/UI/AudioStreamPlayer

var velocity = Vector2.ZERO
var actiondown = false
var equippeditem = ""
var anim = ""
var animstop = false
var animalternate = false
var canclick = true

var firesword = false
var speedsword = false
var jumpsword = false

#var spawn = Vector2(0,1.5)

var suffixes = ["", "k", "M", "G", "T", "P", "E", "Z", "Y"]
var rebirths = 0

var template = preload("res://Scenes/TemplateStat.tscn")
var template2 = preload("res://Scenes/TemplateStat2.tscn")
var template3 = preload("res://Scenes/TemplateUpgrade.tscn")
var template4 = preload("res://Scenes/TemplateStructure.tscn")
var template5 = preload("res://Scenes/TemplateStat4.tscn")
var template6 = preload("res://Scenes/TemplateRecipe.tscn")

var upgrades = load("res://Assets/Resources/Upgrades.tres")
var furnaceRecipes = load("res://Assets/Resources/Furnace.tres")

var selectedstructure = ""
var structures = [
	"Bridge",
	"Wall",
	"Stone-Wall",
	"Wedge",
	"Collector",
	"Drill",
	"Display",
	"Spike",
	"Dropper",
	"Furnace",
	"Laser"
]
func _unhandled_input(_event):
	if Input.is_action_just_pressed("swing"):
		if equippeditem == "Build" and selectedstructure != "": # make sure everything is ready to place a structure
				var structure = load("res://Scenes/Builds/"+selectedstructure+".tscn").instance()
				var canplace = true
				for stat in structure.get_node("Stats").stats.keys(): # see if player has enough resources
					if stats[stat] < structure.get_node("Stats").stats[stat] or translation.y > 50:
						canplace = false
						$BuildOutline.material_override = load("res://Assets/Resources/build-failed.tres")
						$Failtimer.start()
				if canplace == true: # if it does place it
					for stat in structure.get_node("Stats").stats.keys():
						stats[stat] -= structure.get_node("Stats").stats[stat]
					updstats()
					structure.translation = translation
					structure.translation.y += 0.55
					structure.rotation = rotation + $BuildOutline.rotation
					structuresfolder.add_child(structure)
					structure.place()
		if equippeditem == "Food" and health < max_health and stats["Food"] > 0:
			stats["Food"] -= 1
			_set_health(health+25)
			updstats()
		if equippeditem == "Sword":
			animstop = true
			animation_player.play("idle")
			animation_player.play("swing")
			$Hit/CollisionShape2D2.disabled = true
			$Hit/Sword.disabled = true
		elif equippeditem == "":
			animstop = true
			if animalternate:
				animation_player.play("punch_right")
			else:
				animation_player.play("punch_left")
			animalternate = !animalternate
	if Input.is_action_just_released("swing"):
		pass
func get_input():
	if Input.is_action_just_pressed("ui_cancel"):
		$CanvasLayer/UI/Tab/MiddleTabs.visible = false
	if Input.is_action_just_pressed("rotate"):
		$BuildOutline.rotation_degrees.x += 90
	for n in range(1,9): # Hotbar
		if Input.is_action_just_pressed(str(n)) and n <= $CanvasLayer/UI/HBoxContainer2.get_child_count():
			$CanvasLayer/UI/HBoxContainer2.get_child(n-1).press()
	if Input.is_action_pressed("kill"): # Self harm testing only
		damage(5)
	if Input.is_action_pressed("cheat"): # cheating testing only
		stats["Points"] += 234534
		activatefiresword()
		activateshovelsword()
		activatespeedsword()
		activatejumpsword()
		
		var item = load("res://Scenes/Item.tscn").instance()
		var itemstats = item.get_node("Stats").stats
		itemstats[load("res://Scenes/Stats.tscn").instance().stats.keys()[randi() % load("res://Scenes/Stats.tscn").instance().stats.keys().size()]] = 100
		item.translation = translation + Vector3(0,0,1.5).rotated(Vector3.UP, rotation.y)
		get_parent().add_child(item)
		updstats()

func Drop(item):
	if stats[item] > 0:
		var itemtemplate = load("res://Scenes/Item.tscn").instance()
		var itemstats = itemtemplate.get_node("Stats").stats
		stats[item] -= 1
		itemstats[item] = 1
		itemtemplate.translation = translation + Vector3(0,0.5,1.5).rotated(Vector3.UP, rotation.y)
		itemtemplate.apply_impulse(Vector3.ZERO, Vector3(0,2,2).rotated(Vector3.UP, rotation.y))
		get_parent().add_child(itemtemplate)
		updstats()

func _on_AnimationPlayer_animation_finished(_anim_name): # alternate between left and right animation -for punching
	animstop = false

func animate(type,player): # all animations
	var new_anim = anim
	new_anim = type
	if new_anim != anim:
		anim = new_anim
		if player == 0:
			animation_player.play(anim)
		elif player == 1:
			animation_player.play(anim)
			$Hit/CollisionShape2D2.disabled = true
			$Hit/Sword.disabled = true
		elif player == 2:
			animation_player.play_backwards(anim)
			$Hit/CollisionShape2D2.disabled = true
			$Hit/Sword.disabled = true
	anim = ""

func _process(_delta: float) -> void:
	_spring_arm.translation = translation + Vector3(0,1,0) # first person and camera
	if _spring_arm.spring_length == 0:
		_model.visible = false
	else:
		_model.visible = true
	if upgrades.value["Rebirth"] != rebirths: # rebirth check
		#for stat in stats:
			#stats[stat] = 0
		pass
	updupgrades()

func _physics_process(delta: float) -> void:
	if translation.y < -100:
		kill()
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left")
	move_direction.z = Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward")
	if animstop:
		pass
#	elif _velocity.y > 0:
#		animate("jump",1)
#	elif is_on_floor() and _snap_vector == Vector3.ZERO:
#		animate("land",1)
#	elif not is_on_floor() and _velocity.y < -7:
#		print(_velocity.y)
#		animate("fall",1)
	elif move_direction.x > 0:
		animate("right_strafe",1)
	elif move_direction.x < 0:
		animate("left_strafe",1)
	elif move_direction.z > 0:
		animate("walk",2)
	elif move_direction.z < 0:
		animate("walk",1)
	else:
		animate("idle",1)
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	
	
	_velocity.x = move_direction.x * speed
	_velocity.z = move_direction.z * speed
	_velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump"):
		jumping = true
	elif Input.is_action_just_released("jump"):
		jumping = false
	
	var just_landed := is_on_floor() and _snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and jumping 
	
	if is_jumping:
		_velocity.y = jump_strength
		_snap_vector = Vector3.ZERO
	elif just_landed:
		_snap_vector = Vector3.DOWN
	#if _velocity.length() > 0.2 and _velocity.z != 0 or _velocity.x != 0:
		#var look_direction = Vector2(_velocity.z, _velocity.x)
		#rotation.y = look_direction.angle()
	_velocity = move_and_slide_with_snap(_velocity, _snap_vector, Vector3.UP, true)
	rotation_degrees.y = $SpringArm.rotation_degrees.y + 180
	get_input()

func _ready():
	stats.merge(load("res://Scenes/Stats.tscn").instance().stats, false)
	$CanvasLayer/UI/Tab.rect_size = OS.window_size
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(0.25))
	# stat making
	for stat in load("res://Scenes/Stats.tscn").instance().stats.keys():
		var tc = template.instance()
		tc.name = stat
		tc.self_modulate = statcolors[stat]
		statsui.add_child(tc)
		var tc2 = template2.instance()
		tc2.visible = false
		tc2.name = stat
		tc2.self_modulate = statcolors[stat]
		quickbar.add_child(tc2)
		var tc5 = template5.instance()
		tc5.name = stat
		tc5.self_modulate = statcolors[stat]
		$CanvasLayer/UI/Tab/HBoxContainer.add_child(tc5)
	updstats()
	# upgrade making
	for upgrade in upgrades.value.keys():
		var tc3 = template3.instance()
		tc3.name = upgrade
		upgradesui.add_child(tc3)
	updupgrades()
	# structure menu making
	for structure in structures:
		var tc4 = template4.instance()
		tc4.name = structure
		structuresui.add_child(tc4)
	for recipe in furnaceRecipes.input.keys():
		var tc6 = template6.instance()
		tc6.name = recipe
		tc6.get_node("Input").self_modulate = statcolors[furnaceRecipes.input[recipe]]
		tc6.get_node("Input/Label").text = str(furnaceRecipes.inputamount[recipe])
		tc6.get_node("Output").self_modulate = statcolors[recipe]
		tc6.get_node("TextureRect/Label").text = str(furnaceRecipes.coalamount[recipe])
		furnaceui.add_child(tc6)

func updstats():
	for container in statsui.get_children():
		container.get_node("Label").text = container.name+": "+str(stats[container.name])
	for container in quickbar.get_children():
		if container.name != "Health":
			var amount = stats[container.name]
			container.visible = amount > 0
# warning-ignore:integer_division
			var exponent = str(round(amount/10)).length()/3
			if exponent > 0:
				amount = str(round(amount/pow(1000,exponent)))+suffixes[exponent]
			else:
				amount = str(amount)
			container.get_node("Label").text = amount

func updupgrades():
	for container in upgradesui.get_children():
		var amount = upgrades.cost[container.name]
# warning-ignore:integer_division
		var exponent = str(round(amount/10)).length()/3
		if exponent > 0:
			amount = str(round(amount/pow(1000,exponent)))+suffixes[exponent]
		else:
			amount = str(amount)
		container.text = str(upgrades.value[container.name])+" - Upgrade "+container.name+" "+amount+" "+upgrades.type[container.name]

func _on_Hit_area_entered(area):
	if area.is_in_group("hurtbox_structure") and area.get_parent().name == "Furnace" and equippeditem == "":
		$CanvasLayer/UI/Tab/MiddleTabs.visible = true
	if area.is_in_group("hurtbox"):
		if area.health > 0:
			if equippeditem == "Sword":
				area.take_damage(1+upgrades.value["Damage Multi"],self)
				if firesword and !area.onfire:
					var onfireclone = load("res://Scenes/OnFire.tscn").instance()
					onfireclone.player = self
					area.add_child(onfireclone)
					area.onfire = true
			else:
				area.take_damage(1,self)
	elif area.is_in_group("hurtbox_structure") and equippeditem == "Sword":
		if area.get_parent().health > 0:
			area.get_parent().take_damage(1+upgrades.value["Damage Multi"],self)
	elif area.is_in_group("storage"):
		collect_stat(area.get_parent().get_node("Storage").stats)

func collect_stat(statss):
	for stat in statss:
		stats[stat] += statss[stat]
		statss[stat] = 0
	updstats()
func collect_stat_resource(statss):
	for stat in statss:
		stats[stat] += statss[stat]*(upgrades.value["Rebirth"]+1)
		statss[stat] = 0
	updstats()
# Settings

func _on_Character_Color_color_changed(color):
	$Character/RootNode/Beta_Surface.get("material/0").albedo_color = color

func _on_Arms_Color_color_changed(color):
	$Character/RootNode/Beta_Joints.get("material/0").albedo_color = color

# Health System

func damage(amount):
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		_set_health(health-amount)
		pass#effects_animation.play("damage")
		pass#effects_animation.queue("flash")
func kill():
	$Hit/Sword.shape.set_extents(Vector3(0.05,0.5,0.1))
	$Hit/Sword/Model.scale.x = 0.25
	$Hit/Sword/Model.set("material/0", load("res://Assets/Resources/chrome.tres"))
	firesword = false
	speedsword = false
	$Hit/Sword/Speed.visible = false
	speed = 5.0
	jumpsword = false
	$Hit/Sword/Jump.visible = false
	gravity = 50
	translation = cachepos
	health = 100
	
func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health == 0:
			kill()
			emit_signal("killed")
	healthbar.value = health
	healthbar.get_node("Label").text = "Health: "+str(health)
	$Stats.health = health

func _on_InvulnerabilityTimer_timeout():
	pass#effects_animation.play("rest")

# UI

func Craft(recipe):
	if stats[furnaceRecipes.input[recipe]] >= furnaceRecipes.inputamount[recipe] and stats["Coal"] >= furnaceRecipes.coalamount[recipe]:
		stats["Coal"] -= furnaceRecipes.coalamount[recipe]
		stats[furnaceRecipes.input[recipe]] -= furnaceRecipes.inputamount[recipe]
		stats[recipe] += 1
		updstats()
func Upgrade(upgrade):
	if upgrades.cost[upgrade] <= stats[upgrades.type[upgrade]]:
		stats[upgrades.type[upgrade]] -= upgrades.cost[upgrade]
		upgrades.value[upgrade] += 1
		upgrades.cost[upgrade] = ceil(upgrades.cost[upgrade]*1.3)
	updupgrades()
	updstats()
func DeleteStructureOutline():
	for child in $BuildOutline.get_children():
		child.queue_free()
func Equip(item):
	equippeditem = item
	$Hit/Sword/Model.visible = item == "Sword"
	$Hit/Sword/Food.visible = item == "Food"
	$CanvasLayer/UI/Tab/SideTabs.visible = item == "Build"
	$CanvasLayer/UI/Tab/HBoxContainer.visible = item == "Build"
	if item == "Sword":
		if speedsword == true:
			speed = 10.0
			$Hit/Sword/Speed.visible = true
		if jumpsword == true:
			gravity = 15
			$Hit/Sword/Jump.visible = true
	else:
		$Hit/Sword/Speed.visible = false
		$Hit/Sword/Jump.visible = false
		speed = 5.0
		gravity = 50
	if item == "Build":
		DeleteStructureOutline()
		if selectedstructure != "":
			var structure = load("res://Scenes/Builds/"+selectedstructure+".tscn").instance()
			$BuildOutline.add_child(structure)
	else:
		DeleteStructureOutline()

func Select(structure):
	selectedstructure = structure
	for thing in $CanvasLayer/UI/Tab/HBoxContainer.get_children():
		thing.visible = false
	if equippeditem == "Build":
		DeleteStructureOutline()
		if structure != "":
			var structurec = load("res://Scenes/Builds/"+structure+".tscn").instance()
			$BuildOutline.add_child(structurec)
			for stat in structurec.stats.keys():
				if structurec.stats[stat] > 0:
					get_node("CanvasLayer/UI/Tab/HBoxContainer/"+stat+"/Label").text = str(structurec.stats[stat])
					get_node("CanvasLayer/UI/Tab/HBoxContainer/"+stat).visible = true

func _on_Close_toggled(button_pressed):
	if button_pressed == true:
		animplayer.play("Close1")
	else:
		animplayer.play_backwards("Close1")

func _on_Master_Volume_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value/100))

func _on_Failtimer_timeout():
	$BuildOutline.material_override = load("res://Assets/Resources/build.tres")

func _on_Collection_area_entered(area):
	if area.is_in_group("item"):
		area.get_parent().collect(self)

func activateshovelsword():
	$Hit/Sword.shape.set_extents(Vector3(0.05,1,0.15))
	$Hit/Sword/Model.scale.x = 0.5
func activatefiresword():
	$Hit/Sword/Model.set("material/0", load("res://Assets/Resources/firesteel.tres"))
	firesword = true
func activatespeedsword():
	speedsword = true
	if equippeditem == "Sword":
		speed = 10.0
		$Hit/Sword/Speed.visible = true
func activatejumpsword():
	jumpsword = true
	if equippeditem == "Sword":
		gravity = 15
		$Hit/Sword/Jump.visible = true

func _on_MiddleTabs_tab_changed(tab):
	if tab == 1:
		$CanvasLayer/UI/Tab/MiddleTabs.visible = false
		$CanvasLayer/UI/Tab/MiddleTabs.current_tab = 0

func _on_Save_pressed():
	# This is where data would be saved
	print($CanvasLayer/UI/Tab/TabContainer/Settings/VBoxContainer/World.text)

func _on_World_text_entered(new_text):
	# This is where data would be loaded
	print(new_text)

func _on_Quit_pressed():
<<<<<<< HEAD
# warning-ignore:return_value_discarded
=======
	if get_tree().is_network_server():
		print("Server closed!")
	else:
		print("Client disconnected from server!")
	get_tree().network_peer = null
>>>>>>> fde107e36927a0e44bf665b90231daf63246aa9d
	get_tree().change_scene("res://Scenes/Title.tscn")


