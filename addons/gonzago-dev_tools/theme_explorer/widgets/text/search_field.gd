@tool
extends LineEdit

var auto_clear : bool = true
var auto_focus : bool = true
var capture_clear_input : bool = true

func _init() -> void:
    clear_button_enabled = true
    caret_blink = true
    size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_THEME_CHANGED:
            right_icon = get_theme_icon("Search", "EditorIcons")
        NOTIFICATION_TRANSLATION_CHANGED:
            placeholder_text = tr("Filter")
        NOTIFICATION_VISIBILITY_CHANGED:
            if visible:
                if auto_clear:
                    text = ""
                if auto_focus:
                    call_deferred("grab_focus")

func _gui_input(event: InputEvent) -> void:
    if not capture_clear_input or text.is_empty():
        return

    if event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed() and not event.is_echo():
        text = ""
        accept_event()
