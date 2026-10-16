extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

@export var speed: float = 220.0
@export var max_health: int = 100
@export var attack_damage: int = 25
@export var attack_cooldown: float = 0.5

@onready var health_bar: ProgressBar = $ProgressBar
@onready var attack_area: Area2D = $AttackArea

var health: int
var is_dead: bool = false
var attack_timer: float = 0.0

func _ready() -> void:
	add_to_group("player")
	health = max_health
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	
	health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return
	
	# Manejo del temporizador de ataque
	if attack_timer > 0.0:
		attack_timer = maxf(attack_timer - delta, 0.0)
	
	# Tecla de ataque
	if Input.is_action_just_pressed("attack"):
		attack()

	# Movimiento por teclado del jugador
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed
	move_and_slide()

func attack() -> void:
	if attack_timer > 0.0:
		return
		
	attack_timer = attack_cooldown
	
	if attack_area:
		for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("enemies"):
				if body.has_method("take_damage"):
					body.take_damage(attack_damage)

func take_damage(amount: int) -> void:
	if is_dead:
		return

	health = maxi(health - amount, 0)
	
	if health_bar:
		health_bar.value = health

	health_changed.emit(health, max_health)

	if health == 0:
		is_dead = true
		velocity = Vector2.ZERO
		died.emit()
