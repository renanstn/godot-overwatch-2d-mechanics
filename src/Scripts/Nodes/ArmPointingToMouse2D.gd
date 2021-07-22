extends Node2D

class_name ArmPointingToMouse2D

"""
This script provides a node that is always
looking at the mouse pointer.

Copy this script to your project, and a new node
'ArmPointingToMouse2D' will appear in godot's list,
 as a Node2D's child.

Credits: Renan Santana Desiderio
https://github.com/renanstd
"""


export var FIX_ROTATION : bool = true
export(float) var offset = 0
# TODO criar uma variação de ângulo para que fique perceptível
# um outro braço segurando uma arma ao fundo do player

func _process(_delta):
	look_to_mouse()
	if FIX_ROTATION:
		fix_rotation()


func look_to_mouse() -> void:
	look_at(get_global_mouse_position())


func fix_rotation():
	if global_position.x < get_global_mouse_position().x:
		set_scale(Vector2(1, 1))
	else:
		set_scale(Vector2(1, -1))
