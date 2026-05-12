extends Node2D

func _ready():
	if has_node("MusicaNivel"):
		$MusicaNivel.play()
