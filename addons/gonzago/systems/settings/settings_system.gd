@tool
class_name GonzagoSettingsSystem
extends GonzagoSystem


#func _enter_tree() -> void:
#    var toggle_fullscreen_event := InputEventKey.new()
#    toggle_fullscreen_event.physical_keycode = KEY_ENTER
#    toggle_fullscreen_event.alt_pressed = true
#    _add_input_action("toggle_fullscreen", [toggle_fullscreen_event])
#
#func _exit_tree() -> void:
#    _remove_input_action("toggle_fullscreen")

# Editor isn't updated for some reason
func _add_input_action(action: String, events: Array[InputEvent], deadzone: float = 0.5) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action, deadzone)
        for event: InputEvent in events:
            InputMap.action_add_event(action, event)
        #InputMap.notify_property_list_changed()

    var setting_name := "input/%s" % action
    if not ProjectSettings.has_setting(setting_name):
        var events_array := []
        events_array.append_array(events)
        var setting_value := { "deadzone": deadzone, "events": events_array }
        ProjectSettings.set_setting(setting_name, setting_value)
#        ProjectSettings.add_property_info({
#            "name": setting_name,
#            "type": TYPE_DICTIONARY,
#            "hint": PROPERTY_HINT_NONE,
#            "hint_string": ""
#        })
#        ProjectSettings.set_initial_value(setting_name, setting_value)

func _remove_input_action(action: String) -> void:
    if InputMap.has_action(action):
        InputMap.erase_action(action)
        #InputMap.notify_property_list_changed()

    var setting_name := "input/%s" % action
    if ProjectSettings.has_setting(setting_name):
        ProjectSettings.set_setting("input/toggle_fullscreen", null)
