class_name EnemyBase
extends CharacterBody2D

@export var move_speed: float = 60.0
@export var gravity: float = 980.0
@export var patrol_direction: int = -1
@export var turn_on_wall: bool = true

@export var hurt_knockback_scale: float = 1.0
@export var knockback_lock_time: float = 0.18
@export var hit_flash_time: float = 0.10

@onready var health: Health = $Health
@onready var hurtbox: HurtBox = $HurtBox
@onready var hp_bar: ProgressBar = get_node_or_null("HPBar")
@onready var hitbox: HitBox = get_node_or_null("HitBox")

var _dead := false
var _knockback_lock := 0.0
var _flash := 0.0
var _enemy_manager: EnemyManager = null

func _ready() -> void:
	health.changed.connect(_on_health_changed)
	health.died.connect(_die)
	hurtbox.hit_received.connect(_on_hurt)

	# Enable contact damage hitbox if present
	if hitbox:
		hitbox.set_active(true)

	# 血条初始化
	_on_health_changed(health.current_health, health.max_health)
	_enemy_manager = get_tree().get_first_node_in_group("enemy_manager") as EnemyManager
	if _enemy_manager:
		_enemy_manager.register_enemy(self)
	
	
func _exit_tree() -> void:
	if _enemy_manager:
		_enemy_manager.unregister_enemy(self)
		_enemy_manager = null

func _physics_process(delta: float) -> void:
	if _dead:
		return

	velocity.y += gravity * delta

	# 击退锁定期间不要覆盖 velocity.x
	if _knockback_lock > 0.0:
		_knockback_lock -= delta
	else:
		velocity.x = patrol_direction * move_speed

	move_and_slide()

	if turn_on_wall and is_on_wall():
		patrol_direction *= -1

	# 受击闪烁
	if _flash > 0.0:
		_flash -= delta
		modulate = Color(1, 0.6, 0.6)
	else:
		modulate = Color(1, 1, 1)

func _on_hurt(hitbox: HitBox) -> void:
	print("Enemy hurt by hitbox damage=", hitbox.damage)
	if _dead:
		return
	_flash = hit_flash_time
	_knockback_lock = knockback_lock_time

	health.take_damage(hitbox.damage)

	# 击退方向：远离 hitbox
	var dir :int= sign(global_position.x - hitbox.global_position.x)
	if dir == 0:
		dir = 1
	velocity.x = dir * hitbox.knockback * hurt_knockback_scale
	velocity.y = -80.0  # 给一点向上的反馈（可调）

func _die() -> void:
	if _dead:
		return
	_dead = true
	# 先注销再 free
	if _enemy_manager:
		_enemy_manager.unregister_enemy(self)
		_enemy_manager = null
	queue_free()

func _on_health_changed(cur: int, maxv: int) -> void:
	if hp_bar:
		hp_bar.max_value = maxv
		hp_bar.value = cur
