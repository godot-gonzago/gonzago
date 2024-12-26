@tool
class_name GonzagoCursor
extends CanvasLayer


@export var position: Node2D


func _ready() -> void:
    if Engine.is_editor_hint():
        return

    position.global_position = position.get_global_mouse_position()


func _input(event: InputEvent) -> void:
    if Engine.is_editor_hint():
        return

    var mouse := event as InputEventMouseMotion
    if mouse:
        position.global_position = mouse.global_position
