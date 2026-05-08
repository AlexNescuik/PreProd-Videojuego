extends CanvasLayer

@onready var anim = %AnimationPlayer

func cambiar_escena(ruta_escena: String):
	var escena_actual = get_tree().current_scene
	
	for hijo in escena_actual.get_children():
		if hijo is CanvasLayer or hijo is Control:
			var tween = create_tween()
			tween.tween_property(hijo, "modulate:a", 0.0, 0.4) 
	
	anim.play("fade_to_black")
	await anim.animation_finished
	get_tree().change_scene_to_file(ruta_escena)
	anim.play("fade_from_black")
