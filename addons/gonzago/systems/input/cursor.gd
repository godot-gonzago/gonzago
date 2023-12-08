@tool
class_name GonzagoCursor
extends CanvasLayer


@export var position: Node2D


func _ready() -> void:
    if Engine.is_editor_hint():
        return

    position.position = position.get_global_mouse_position()


func _input(event: InputEvent) -> void:
    if Engine.is_editor_hint():
        return

    if event is InputEventMouseMotion:
        position.position = event.position
