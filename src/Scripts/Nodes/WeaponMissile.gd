extends Node2D

class_name WeaponMissile

"""
	This script provides a basic missile weapon, with
	multiples configurable parameters.
	
	Copy this script to your project, and a new node
	'WeaponMissile' will appear in godot's list, as a
	Node2D's child.
	
	Credits: Renan Santana Desiderio
	https://github.com/Doc-McCoy
"""

export var hit_animation_scene : PackedScene
export var capsule_scene : PackedScene
export var fire_point_path : NodePath
export var capsule_ejector_path : NodePath
export var fire_sound_path : NodePath
export var empty_bullets_sound_path : NodePath
export var reload_sound_path : NodePath
export var parent_node : NodePath

export(int, 1, 1000) var missile_damage
export(float, 0, 5) var recoil_time
export(int, 1, 1000) var max_bullets
export(float, 0, 10) var reload_time
export(bool) var auto_reload = false
export var eject_capsule : bool

var can_fire : bool = true
var reloading : bool = false
var bullets : int
var recoil_timer : Timer
var reload_timer : Timer
var fire_point : Position2D
var capsule_ejector : Position2D
var fire_sound : AudioStreamPlayer2D
var reload_sound : AudioStreamPlayer2D
var empty_bullets_sound : AudioStreamPlayer2D

signal shoot
signal reloading
signal reloaded
signal hit_enemy
signal no_bullets
signal ready_to_fire
signal update_bullets(how_many)
signal cause_damage(how_much)


func _ready():
	bullets = max_bullets
	fire_point = get_node(fire_point_path)
	fire_sound = get_node(fire_sound_path)
	if eject_capsule:
		capsule_ejector = get_node(capsule_ejector_path)
	empty_bullets_sound = get_node(empty_bullets_sound_path)
	reload_sound = get_node(reload_sound_path)
	recoil_timer = create_timer(recoil_time, "on_recoil_time_end")
	reload_timer = create_timer(reload_time, "on_reload_time_end")


func _process(delta):
	# Fire ------------------------------------------------
	if can_fire and Input.is_action_just_pressed("alternative_fire"):
		if bullets > 0:
			shoot()
		else:
			empty_bullets()

	# Reload ----------------------------------------------
	if Input.is_action_just_pressed("reload") and not auto_reload and not reloading:
			reload_start()


func create_timer(time : float,  callback : String) -> Timer:
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = time
	timer.connect("timeout", self, callback)
	add_child(timer)
	return timer


func shoot() -> void:
	fire_sound.play()
	emit_signal("shoot")
	emit_signal("update_bullets", bullets)
	bullets -= 1
	can_fire = false
	recoil_timer.start()
	if eject_capsule:
		eject_capsule()
#	if hit_something:
#		var collision_point = raycast.get_collision_point()
#		var collide_with = raycast.get_collider()
#		var collider_groups = collide_with.get_groups()
#		create_trail(raycast.get_global_position(), collision_point)
#		if "enemy" in collider_groups:
#			emit_signal("hit_enemy")
#			emit_signal("cause_damage", bullet_damage)
#		create_hit_animation(collision_point)


func empty_bullets() -> void:
	empty_bullets_sound.play()
	emit_signal("no_bullets")


func reload_start() -> void:
	reloading = true
	can_fire = false
	reload_timer.start()
	reload_sound.play()
	emit_signal("reloading")


func eject_capsule() -> void:
	var capsule = capsule_scene.instance()
	# Variável que auxilia a correção do ângulo caso o
	# braço esteja com a escala invertida
	var looking_to_right = get_parent().get_parent().scale.y
	capsule.global_position = capsule_ejector.global_position
	capsule.rotation = capsule_ejector.global_rotation * looking_to_right
	# Aplicar impulso e rotação na capsula, sempre usando o
	# 'looking_to_right' para corrigir a inversão de scale
	capsule.apply_impulse(Vector2(0,0), Vector2(-100 * looking_to_right,-200))
	capsule.add_torque(-500 * looking_to_right)
	get_node(parent_node).get_owner().add_child(capsule)


func on_recoil_time_end():
	can_fire = true
	emit_signal("ready_to_fire")


func on_reload_time_end():
	reloading = false
	bullets = max_bullets
	can_fire = true
	emit_signal("reloaded")
	emit_signal("update_bullets", bullets)