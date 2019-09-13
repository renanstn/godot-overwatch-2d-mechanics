extends Control

onready var globals : Node = get_node("/root/GlobalsVariables")

func _on_ButtonSoldado_button_up():
	globals.player_selected = "soldado"
	globals.goto_scene("res://Scenes/Test.tscn")
