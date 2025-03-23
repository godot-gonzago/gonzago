@tool
extends Container

func inspect(t: Theme, type: StringName, name: StringName) -> void:
    var label := get_node("%BottomLabel") as Label
    label.text = name
    tooltip_text = name


var _is_hovered := false

var _normal_stylebox: StyleBox
var _hover_stylebox: StyleBox
var _focus_stylebox: StyleBox
var _pressed_stylebox: StyleBox

# https://docs.godotengine.org/en/latest/tutorials/ui/custom_gui_controls.html

func _notification(what):
    match what:
        NOTIFICATION_MOUSE_ENTER:
            _is_hovered = true
            queue_redraw()
            pass # Mouse entered the area of this control.
        NOTIFICATION_MOUSE_EXIT:
            _is_hovered = false
            queue_redraw()
            pass # Mouse exited the area of this control.
        NOTIFICATION_FOCUS_ENTER:
            pass # Control gained focus.
        NOTIFICATION_FOCUS_EXIT:
            pass # Control lost focus.
        NOTIFICATION_THEME_CHANGED:
            _normal_stylebox = get_theme_stylebox(&"normal", &"Button")
            _hover_stylebox = get_theme_stylebox(&"hover", &"Button")
            _focus_stylebox = get_theme_stylebox(&"focus", &"Button")
            _pressed_stylebox = get_theme_stylebox(&"pressed", &"Button")
            pass # Theme used to draw the control changed; update and redraw is recommended if using a theme.
        NOTIFICATION_VISIBILITY_CHANGED:
            pass # Control became visible/invisible; check new status with is_visible().
        NOTIFICATION_RESIZED:
            pass # Control changed size; check new size with get_size().
        NOTIFICATION_DRAW:
            if _is_hovered:
                _hover_stylebox.draw(
                    get_canvas_item(),
                    Rect2(Vector2.ZERO, size)
                )
            if has_focus():
                _focus_stylebox.draw(
                    get_canvas_item(),
                    Rect2(Vector2.ZERO, size)
                )


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            print("I've been clicked")
            accept_event()
            

#https://docs.godotengine.org/en/stable/classes/class_control.html#class-control-private-method-make-custom-tooltip
#func _make_custom_tooltip(for_text: String) -> Object:
#    pass
