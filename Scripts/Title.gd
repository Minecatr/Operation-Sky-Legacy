extends Spatial

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
	get_tree().change_scene("res://Scenes/World.tscn")

func _on_Quit_pressed():
	get_tree().quit()

func _ready():
	thememenu.add_item("Swift")
	thememenu.add_item("Clean")

func _on_Theme_item_selected(index):
	$CanvasLayer/Control.theme = load("res://Assets/Resources/"+thememenu.get_item_text(index)+".tres")
