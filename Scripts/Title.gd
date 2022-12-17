extends Spatial

const SAVE_PATH = "user://save_config_file.ini"

onready var thememenu = $CanvasLayer/Control/VBoxContainer/Theme

func _on_Host_pressed():
# warning-ignore:return_value_discarded
	print("Hosted server!")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(11984, 8)
	get_tree().network_peer = peer
	get_tree().change_scene("res://Scenes/World.tscn")

func _on_Join_pressed():
	print("Joined server as client!")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client($CanvasLayer/Control/VBoxContainer/Address.text, 11984)
	get_tree().network_peer = peer
	print($CanvasLayer/Control/VBoxContainer/Address.text)
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/World.tscn")

func _on_Quit_pressed():
	get_tree().quit()

func _ready():
	var config = ConfigFile.new()
	config.load(SAVE_PATH)
	thememenu.add_item("Swift")
	thememenu.add_item("Clean")
	thememenu.selected = config.get_value("Theme", "index", 0)
	$CanvasLayer/Control.theme = load("res://Assets/Resources/"+thememenu.get_item_text(config.get_value("Theme", "index", 0))+".tres")
	$CanvasLayer/Control/VBoxContainer/Username.text = config.get_value("User", "name", "")

func _on_Theme_item_selected(index):
	$CanvasLayer/Control.theme = load("res://Assets/Resources/"+thememenu.get_item_text(index)+".tres")
	var config = ConfigFile.new()
	config.set_value("Theme", "index", index)
	config.save(SAVE_PATH)

func _on_Username_text_entered(new_text):
	var config = ConfigFile.new()
	config.set_value("User", "name", new_text)
	config.save(SAVE_PATH)
