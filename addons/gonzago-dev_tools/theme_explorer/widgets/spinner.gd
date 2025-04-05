@tool
extends TextureRect

@export
var _frames: Array[Texture2D] = []
@export_range(0.05, 1.0, 0.05, "or_greater")
var _interval := 0.2:
    get = get_interval, set = set_interval

var _current_frame := -1
var _last_tick := -1


func get_interval() -> float:
    return _interval


func set_interval(value: float) -> void:
     _interval = maxf(0.05, value)


func clear_frames() -> void:
    _frames.clear()


func get_frame_count() -> int:
    if not _frames.is_empty():
        return _frames.size()
    if Engine.is_editor_hint() and not NodeUtil.is_node_being_edited(self):
        return 8
    return 0


func get_frame(idx: int) -> Texture2D:
    if not _frames.is_empty():
        return _frames[clampi(idx, 0, _frames.size() - 1)]
    if Engine.is_editor_hint() and not NodeUtil.is_node_being_edited(self):
        var editor_theme := EditorInterface.get_editor_theme()
        var theme_item := "Progress%d" % clampi(idx + 1, 1, 8)
        return editor_theme.get_icon(theme_item, &"EditorIcons")
    return null 


func add_frame(frame: Texture2D) -> void:
    _frames.append(frame)
    
    
func remove_frame(idx: int) -> void:
    if idx >= 0 and idx < _frames.size():
        _frames.remove_at(idx)


func _notification(what: int) -> void:
    if NodeUtil.is_node_being_edited(self):
        return
    
    match what:
        NOTIFICATION_VISIBILITY_CHANGED, \
        NOTIFICATION_ENTER_CANVAS, \
        NOTIFICATION_EXIT_CANVAS:
            if visible:
                _last_tick = Time.get_ticks_msec()
                _current_frame = 0
                texture = get_frame(_current_frame)
                set_process(true)
            else:
                set_process(false)
        NOTIFICATION_PROCESS:
            var current_tick := Time.get_ticks_msec()
            var next_tick := _last_tick + roundi(_interval * 1000.0)
            if current_tick >= next_tick:
                var tick_delta := current_tick - next_tick
                _last_tick = current_tick - tick_delta
                _current_frame = wrapi(_current_frame + 1, 0, get_frame_count())
                texture = get_frame(_current_frame)
