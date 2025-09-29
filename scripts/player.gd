extends RigidBody2D

@export var engine_power = 500
@export var spin_power = 8000
@export var bullet_scene : PackedScene
@export var fire_rate = 0.25

var can_shoot = true
var screensize = Vector2.ZERO
var thrust = Vector2.ZERO
var rotation_dir = 0
var radius

enum {
	INIT,
	ALIVE,
	INVURNELABLE,
	DEAD
}

var state = INIT

func _ready() -> void:
	change_state(ALIVE)
	screensize = get_viewport_rect().size
	radius = int($Sprite2D.texture.get_size().x)
	$GunCooldown.wait_time = fire_rate
	

func _process(delta: float) -> void:
	get_input()

func _physics_process(delta: float) -> void:
	constant_force = thrust
	constant_torque = rotation_dir * spin_power

func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0 - radius, screensize.x + radius)
	xform.origin.y = wrapf(xform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = xform

func change_state(new_state) -> void:
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
		INVURNELABLE:
			$CollisionShape2D.set_deferred("disabled", true)
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
	state = new_state

func get_input() ->void:
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot() -> void:
	if state == INVURNELABLE:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)


func _on_gun_cooldown_timeout() -> void:
	can_shoot = true
