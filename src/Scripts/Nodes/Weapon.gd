extends Node2D

class_name Weapon

export var hit_animation_scene : PackedScene
export var bullet_trail_scene : PackedScene
export var fire_point_path : NodePath
export var fire_sound_path : NodePath
export var parent_node : NodePath

export (int, "Automatic", "SemiAutomatic", "Projectile") var gun_type
export (float, 0, 5) var recoil_time

var can_fire : bool = true
var raycast : RayCast2D
var timer : Timer
var fire_point : Position2D
var fire_sound : AudioStreamPlayer2D

signal shoot
signal reloading
signal hit_enemy


func _ready():
	fire_point = get_node(fire_point_path)
	fire_point = get_node(fire_point_path)
	fire_sound = get_node(fire_sound_path)
	create_raycast()
	create_timer()
	adjust_raycast_size()
	
func _process(delta):
	if Input.is_action_just_pressed("fire"):
		if can_fire:
			shoot()
		else:
			can_not_shoot()

func adjust_raycast_size() -> void:
	var size_screen : Vector2 = get_viewport().get_visible_rect().size
	raycast.set_cast_to(Vector2(0, size_screen.x))

func create_raycast() -> void:
	raycast = RayCast2D.new()
	raycast.position = fire_point.position
	raycast.rotation_degrees = -90
	raycast.enabled = true
	add_child(raycast)

func create_timer() -> void:
	timer = Timer.new()
	timer.wait_time = recoil_time
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	
func shoot() -> void:
	fire_sound.play()
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

func can_not_shoot():
	pass

func create_trail(to : Vector2, from : Vector2):
	var trail = bullet_trail_scene.instance()
	trail.setup(to, from)
	get_node(parent_node).get_owner().add_child(trail)

func create_hit_animation(collision_point : Vector2):
	var hit_animation = hit_animation_scene.instance()
	hit_animation.global_position = collision_point
	hit_animation.rotation_degrees = rand_range(0, 360)
	get_node(parent_node).get_owner().add_child(hit_animation)

func _on_timer_timeout():
	can_fire = true