@tool
extends PopupMenu

@export var line_edit: LineEdit:
    set = set_line_edit, get = get_line_edit

func set_line_edit(new_line_edit: LineEdit) -> void:
    if line_edit == new_line_edit: return
    if line_edit:
        if line_edit.focus_entered.is_connected(_focus_entered):
            line_edit.focus_entered.disconnect(_focus_entered)
        if line_edit.text_changed.is_connected(_text_changed):
            line_edit.text_changed.disconnect(_text_changed)
    if new_line_edit:
        if not new_line_edit.focus_entered.is_connected(_focus_entered):
            new_line_edit.focus_entered.connect(_focus_entered)
        if not new_line_edit.text_changed.is_connected(_text_changed):
            new_line_edit.text_changed.connect(_text_changed)
    line_edit = new_line_edit


func get_line_edit() -> LineEdit:
    return line_edit

@export_range(1, 10, 1, "or_greater")
var max_lines := 10:
    set = set_max_lines, get = get_max_lines

func set_max_lines(new_max_lines: int) -> void:
    new_max_lines = maxi(new_max_lines, 1)
    if max_lines != new_max_lines:
        max_lines = new_max_lines
        if is_node_ready():
            _recalculate_max_size()

func get_max_lines() -> int:
    return max_lines


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            _recalculate_max_size()
        NOTIFICATION_THEME_CHANGED:
            if is_node_ready():
                _recalculate_max_size()


func _unhandled_key_input(event: InputEvent) -> void:
    pass


func _get_contents_minimum_size() -> Vector2:
    var min_size := get_theme_stylebox("panel").get_minimum_size()

    var font := get_theme_font("font")
    var font_size := get_theme_font_size("font_size")
    var font_height := font.get_height(font_size)
    var v_separation := get_theme_constant("v_separation")
    var item_height := font_height + v_separation

    var lines_count := mini(item_count, max_lines)
    min_size.y += item_height * lines_count

    return min_size


func _recalculate_max_size() -> void:
    if is_inside_tree():
        var panel_height := get_theme_stylebox("panel").get_minimum_size().y
        var font := get_theme_font("font")
        var font_size := get_theme_font_size("font_size")
        var font_height := font.get_height(font_size)
        var v_separation := get_theme_constant("v_separation")
        var item_height := font_height + v_separation
        var max_height := panel_height + item_height * max_lines
        #max_height -= v_separation
        max_size.y = max_height


func _focus_entered() -> void:
    pass


func _text_changed(new_text: String) -> void:
    var line_edit_rect := line_edit.get_global_rect()
    var min_size := get_contents_minimum_size()
    var rect := Rect2i(
        line_edit_rect.position.x,
        line_edit_rect.end.y,
        line_edit_rect.size.x,
        min_size.y
    )

    var window := line_edit.get_last_exclusive_window()
    var screen := window.current_screen
    var screen_rect := DisplayServer.screen_get_usable_rect(screen)

    #print(rect)
    #print(screen_rect)

    #if screen_rect.end.y < rect.end.y:
    #    max_size.y = screen_rect.end.y - rect.position.y
    #    rect.end.y = screen_rect.end.y

    popup(rect)
