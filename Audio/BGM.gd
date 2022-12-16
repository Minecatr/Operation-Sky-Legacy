extends AudioStreamPlayer

var songs = [
	"profiles-a.ogg",
	"results-a.ogg",
	"sound-machine-a.mp3",
	"sound-machine-b.ogg",
	"sound-machine-c.ogg",
	"the-block.ogg",
	"unguarded.ogg",
	"cytochrome"
]

func changesong():
	stream = load("res://Audio/"+songs[rand_range(0,songs.size()-1)])
	play()

func _ready():
	randomize()
	changesong()

func _on_AudioStreamPlayer_finished():
	changesong()
