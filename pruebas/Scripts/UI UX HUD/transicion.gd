extends CanvasLayer

@onready var anim = %AnimationPlayer

func cambiar_escena(ruta_escena: String):
	anim.play("fade_to_black")
	await anim.animation_finished
	
	get_tree().change_scene_to_file(ruta_escena)
	
	anim.play("fade_from_black")
