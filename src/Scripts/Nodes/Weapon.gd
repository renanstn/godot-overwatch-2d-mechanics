extends Node2D

class_name Weapon

export var explosion_scene : PackedScene
export var trail_scene : PackedScene
export var fire_point_path : NodePath

var can_fire : bool = true
var raycast : RayCast2D
var timer : Timer

signal shoot
signal reloading
signal hit_enemy


func _ready():
	create_raycast()
	create_timer()
	adjust_raycast_size()
	
func _process(delta):
	if Input.is_action_just_pressed("fire"):
		if can_fire:
			shoot()
		else:
			cant_shoot()

func adjust_raycast_size() -> void:
	var size_screen : Vector2 = get_viewport().get_visible_rect().size
	raycast.set_cast_to(Vector2(0, size_screen.x))
	
func create_raycast() -> void:
	var fire_point : Position2D = get_node(fire_point_path)
	raycast = RayCast2D.new()
	raycast.position = fire_point.position
	add_child(raycast)

func create_timer() -> void:
	timer = Timer.new()
	timer.wait_time = 1
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	
func shoot() -> void:
	can_fire = false
	timer.start()
	var hit_something = raycast.get_collider()
	if hit_something:
		var collision_point = raycast.get_collision_point()
		var collide_with = raycast.get_collider()
		var collider_groups = collide_with.get_groups()
		create_trail(raycast.get_global_position(), collision_point)
		if "enemy" in collider_groups:
			emit_signal("hit_enemy")
		create_hit_animation(collision_point)
	
func cant_shoot():
	pass

func create_trail(to : Vector2, from : Vector2):
	pass

func create_hit_animation(collision_point : Vector2):
	pass

func _on_timer_timeout():
	can_fire = true