@tool
extends HBoxContainer


var _stylebox: StyleBox
var _menu: MenuButton


func _init() -> void:
    _menu = MenuButton.new()
    _menu.tooltip_text = "Gonzago"
    _menu.icon = load("res://addons/gonzago/editor/icons/gonzago.svg") as Texture2D
    _menu.flat = false
    add_child(_menu, false, Node.INTERNAL_MODE_BACK)
    
    var popup := _menu.get_popup()
    popup.menu_changed.connect(
        func() -> void:
            _menu.visible = _menu.item_count > 0
    )


func _get_minimum_size() -> Vector2:
    var min := get_combined_minimum_size()
    min += _stylebox.get_minimum_size()
    return min


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_THEME_CHANGED:
            _stylebox = get_theme_stylebox("LaunchPadNormal", "EditorStyles")
            update_minimum_size()
        NOTIFICATION_DRAW:
            _stylebox.draw(
                get_canvas_item(),
                Rect2(Vector2.ZERO, size)
            )
        NOTIFICATION_SORT_CHILDREN:
            var has_visible_children := false
            
            for child in get_children(true):
                var control := child as Control
                if control and not control.top_level and control.visible:
                    has_visible_children = true
                    break
            
            visible = has_visible_children


func get_gonzago_popup() -> PopupMenu:
    return _menu.get_popup()


func add_item(item: Control, group := "") -> void:
    item.focus_mode = Control.FOCUS_NONE
    var button := item as Button
    if button:
        button.flat = false
    add_child(item)


func remove_item(item: Control, group := "") -> void:
    remove_child(item)
