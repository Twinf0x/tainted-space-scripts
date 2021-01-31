class_name Projectile
extends Area

var damage_on_hit = 0
var speed = 0
var direction = Vector3()
var lifetime = 0

func initialize(damage_on_hit, speed, direction, lifetime):
	self.damage_on_hit = damage_on_hit
	self.speed = speed
	self.direction = direction
	self.lifetime = lifetime

func _physics_process(delta):
	global_translate(direction * speed * delta)
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func on_hit(other):
	if other.name == "Player":
		return
	
	if other.has_method("take_damage"):
		other.take_damage(damage_on_hit, global_transform.origin)
	
	queue_free()
