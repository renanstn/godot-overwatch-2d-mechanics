extends KinematicBody2D

class_name Missile

"""
	This script provides a basic missile bullet, with
	multiples configurable parameters.
	
	Copy this script to your project, and a new node
	'Missile' will appear in godot's list, as a
	KinematicBody2D's child.
	
	Credits: Renan Santana Desiderio
	https://github.com/Doc-McCoy
"""

export var explosion_animation_scene : PackedScene

export(float) var damage
export(float) var speed
export(bool) var speed_increase
export(float) var initial_speed
export(float) var max_speed
export(float) var increase_tax

var velocity : Vector2

signal hit_something
signal hit_enemy
signal cause_damage(how_much)


func _ready():
	if speed_increase:
		speed = initial_speed


func _physics_process(_delta):
	if speed_increase:
		velocity = Vector2(speed, 0).rotated(rotation)
		velocity = move_and_slide(velocity)
		if speed < max_speed:
			speed += increase_tax
	else:
		velocity = Vector2(speed, 0).rotated(rotation)
		velocity = move_and_slide(velocity)


func create_hit_animation(collision_point : Vector2) -> void:
	var hit_animation = explosion_animation_scene.instance()
	hit_animation.global_position = collision_point
	hit_animation.rotation_degrees = rand_range(0, 360)
	get_node("/root").add_child(hit_animation)


func _on_Area2D_body_entered(body):
	emit_signal("hit_something")
	var body_groups = body.get_groups()
	if "enemy" in body_groups:
		emit_signal("hit_enemy")
		emit_signal("cause_damage", damage)
	create_hit_animation(position)
	queue_free()
