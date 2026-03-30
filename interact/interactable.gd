class_name Interactable extends Area2D

signal interacted(interactor: Node)

func _ready() -> void:
	add_to_group("interactable")

func interact(interactor: Node) -> void:
	interacted.emit(interactor)
