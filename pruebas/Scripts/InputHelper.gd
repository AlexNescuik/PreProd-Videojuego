extends Node

signal cambio_de_dispositivo(es_control)

var usando_control = false

func _input(event):
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if !usando_control:
			usando_control = true
			cambio_de_dispositivo.emit(true)
			print("Cambiado a CONTROL")
			
	elif event is InputEventKey or event is InputEventMouseButton:
		if usando_control:
			usando_control = false
			cambio_de_dispositivo.emit(false)
			print("Cambiado a TECLADO")
