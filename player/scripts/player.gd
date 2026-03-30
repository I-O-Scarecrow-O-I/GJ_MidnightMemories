class_name Player
extends CharacterBody2D

const DEBUG_INDICATOR = preload("uid://bmpy4d450acr4")

@export var move_speed: float = 200.0
@export var gravity: float = 980.0

# attack
@export var attack_damage: int = 1
@export var attack_knockback: float = 240.0

# player health/feedback
@export var max_health: int = 10
@export var hurt_invincible_time: float = 0.5
@export var hurt_knockback: float = 260.0
@export var hurt_lock_time: float = 0.16

var states: Array[PlayerState]
var current_state: PlayerState:
	get: return states.front()
var previous_state: PlayerState:
	get: return states[1]

var direction: Vector2 = Vector2.ZERO
var is_in_ladder_area: bool = false
var is_on_ladder: bool = false

var _inv_timer := 0.0
var _hurt_lock := 0.0

@onready var hitbox: HitBox = $HitBox
@onready var health: Health = $Health
@onready var hurtbox: HurtBox = $HurtBox
@onready var hp_bar: ProgressBar = $HPBar

@onready var ladder_sensor: Area2D = $LadderSensor
@onready var interaction_sensor: Area2D = $InteractionSensor

var _interactables_in_range: Array[Interactable] = []

func _ready() -> void:
	# configure combat
	hitbox.damage = attack_damage
	hitbox.knockback = attack_knockback
	hitbox.set_active(false)

	# configure health
	health.max_health = max_health
	health._ready() # 强制初始化（如果你不喜欢可改成把 max_health 写在 Health 里）
	health.changed.connect(_on_health_changed)
	health.died.connect(_on_player_died)
	_on_health_changed(health.current_health, health.max_health)

	hurtbox.hit_received.connect(_on_player_hurt)

	# ladder & interaction
	ladder_sensor.area_entered.connect(_on_ladder_area_entered)
	ladder_sensor.area_exited.connect(_on_ladder_area_exited)
	interaction_sensor.area_entered.connect(_on_interaction_area_entered)
	interaction_sensor.area_exited.connect(_on_interaction_area_exited)

	initialize_states()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		_try_interact()
	change_state(current_state.handle_input(event))

func _process(delta: float) -> void:
	update_direction()
	change_state(current_state.process(delta))

func _physics_process(delta: float) -> void:
	if _inv_timer > 0.0:
		_inv_timer -= delta

	if not is_on_ladder:
		velocity.y += gravity * delta

	# 受伤硬直期，不允许状态机覆盖水平速度（这里先用简单做法）
	if _hurt_lock > 0.0:
		_hurt_lock -= delta

	move_and_slide()
	change_state(current_state.physics_process(delta))

func initialize_states() -> void:
	states = []
	for c in $States.get_children():
		if c is PlayerState:
			states.append(c)
			c.player = self

	for state in states:
		state.init()

	change_state(current_state)
	current_state.enter()
	$Label.text = current_state.name

func change_state(new_state: PlayerState) -> void:
	if new_state == null or new_state == current_state:
		return
	if current_state:
		current_state.exit()
	states.push_front(new_state)
	current_state.enter()
	states.resize(3)
	$Label.text = current_state.name

func update_direction() -> void:
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)

func start_attack() -> void:
	hitbox.set_active(true)

func end_attack() -> void:
	hitbox.set_active(false)

func _try_interact() -> void:
	if _interactables_in_range.is_empty():
		return
	var it: Interactable = _interactables_in_range[_interactables_in_range.size() - 1]
	if is_instance_valid(it):
		it.interact(self)

func _on_ladder_area_entered(a: Area2D) -> void:
	if a is LadderArea:
		is_in_ladder_area = true

func _on_ladder_area_exited(a: Area2D) -> void:
	if a is LadderArea:
		is_in_ladder_area = false

func _on_interaction_area_entered(a: Area2D) -> void:
	if a is Interactable:
		_interactables_in_range.append(a)

func _on_interaction_area_exited(a: Area2D) -> void:
	if a is Interactable:
		_interactables_in_range.erase(a)

func _on_player_hurt(enemy_hitbox: HitBox) -> void:
	# 这里假设敌人的攻击也用 HitBox，或你先用同一个 HitBox 做接触伤害
	if _inv_timer > 0.0:
		return

	_inv_timer = hurt_invincible_time
	_hurt_lock = hurt_lock_time

	health.take_damage(enemy_hitbox.damage)

	var dir :int= sign(global_position.x - enemy_hitbox.global_position.x)
	if dir == 0:
		dir = 1
	velocity.x = dir * hurt_knockback
	velocity.y = -120.0

	modulate = Color(1, 0.7, 0.7)
	await get_tree().create_timer(0.08).timeout
	modulate = Color(1, 1, 1)

func _on_health_changed(cur: int, maxv: int) -> void:
	if hp_bar:
		hp_bar.max_value = maxv
		hp_bar.value = cur

func _on_player_died() -> void:
	print("Player died")
	# TODO: respawn / game over

func add_debug_indicator(color: Color = Color.RED) -> void:
	var d: Node2D = DEBUG_INDICATOR.instantiate()
	get_tree().root.add_child(d)
	d.global_position = global_position
	d.modulate = color
	await get_tree().create_timer(3.0).timeout
	d.queue_free()
