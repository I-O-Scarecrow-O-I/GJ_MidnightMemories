class_name EnemyManager extends Node

signal all_enemies_defeated

var _enemies: Array = []

func _ready() -> void:
	add_to_group("enemy_manager")

func register_enemy(enemy: Node) -> void:
	if not _enemies.has(enemy):
		_enemies.append(enemy)

func unregister_enemy(enemy: Node) -> void:
	_enemies.erase(enemy)
	if _enemies.is_empty():
		all_enemies_defeated.emit()
