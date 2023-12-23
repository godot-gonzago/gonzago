@tool
class_name GonzagoEditorQuickbar
extends PanelContainer


var _items: Control


func _ready() -> void:
    _items = get_node("Items") as Control


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_SORT_CHILDREN:
            var has_visible_children := false
            for child in _items.get_children():
                if child is Control and child.visible:
                    has_visible_children = true
                    break
            visible = has_visible_children


func add_icon_button() -> Button:
    var button := Button.new()
    button.flat = true
    button.focus_mode = Control.FOCUS_NONE
    return button


func add_menu_button() -> MenuButton:
    var menu_button := MenuButton.new()
    return menu_button


func add_option_button() -> OptionButton:
    var option_button := OptionButton.new()
    option_button.flat = true
    option_button.focus_mode = Control.FOCUS_NONE
    return option_button
