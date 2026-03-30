extends Node

@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var door: Door = $Door

func _ready() -> void:
	enemy_manager.all_enemies_defeated.connect(_on_all_enemies_defeated)

func _on_all_enemies_defeated() -> void:
	door.unlock()
