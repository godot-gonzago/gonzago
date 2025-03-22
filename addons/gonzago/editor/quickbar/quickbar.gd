@tool
class_name GonzagoEditorQuickbar
extends PanelContainer


#var _items: HBoxContainer


#func _init() -> void:
#    _items = HBoxContainer.new()


func _notification(what: int) -> void:
    match what:
#        NOTIFICATION_THEME_CHANGED:
#            add_theme_stylebox_override("panel", get_theme_stylebox("LaunchPadNormal", "EditorStyles"))
        NOTIFICATION_SORT_CHILDREN:
            var has_visible_children := false
            var items = get_node("Items") as Control
            for child in items.get_children():
                if child is Control and not child is Separator and child.visible:
                    has_visible_children = true
                    break
            visible = has_visible_children


func add_item(item: Control) -> void:
    var items = get_node("Items") as Control
    items.add_child(item)


func remove_item(item: Control) -> void:
    var items = get_node("Items") as Control
    items.remove_child(item)


func add_separator() -> VSeparator:
    var separator := VSeparator.new()
    add_item(separator)
    return separator


func add_icon_button() -> Button:
    var button := Button.new()
    button.flat = true
    button.focus_mode = Control.FOCUS_NONE
    add_item(button)
    return button


func add_menu_button() -> MenuButton:
    var menu_button := MenuButton.new()
    add_item(menu_button)
    return menu_button


func add_option_button() -> OptionButton:
    var option_button := OptionButton.new()
    option_button.flat = true
    option_button.focus_mode = Control.FOCUS_NONE
    add_item(option_button)
    return option_button
