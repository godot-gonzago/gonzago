@tool
extends VBoxContainer

const NodeUtil := Gonzago.NodeUtil
const DataTypeGroup := preload("uid://b12t18ypjfwyh")

# TODO: Consolidate into one view where data types are draw automaticall (without nodes)
#       Only children should be items (or a context menu)

func inspect(t: Theme, type: StringName, base_type: StringName) -> void:
    # TODO: Get icon for type in a better way
    var editor_theme := EditorInterface.get_editor_theme()
    var types_fallback_icon := editor_theme.get_icon("NodeDisabled", "EditorIcons")
    var type_icon := types_fallback_icon
    if editor_theme.has_icon(type, "EditorIcons"):
        type_icon = editor_theme.get_icon(type, "EditorIcons")
    
    var icon := get_node("%Icon") as TextureRect
    icon.texture = type_icon
    
    var label := get_node("%Label") as Label
    label.text = type
    
    var variation_icon := get_node("%VariationIcon") as TextureRect
    var variation_label := get_node("%VariationLabel") as Label
    if base_type.is_empty():
        variation_icon.visible = false
        variation_label.visible = false
    else:
        variation_icon.visible = true
        variation_label.visible = true
        variation_label.text = base_type
    
    for idx in range(1, get_child_count()):
        var child := get_child(idx) as DataTypeGroup
        child.inspect(t, type)
        
    queue_sort()


func _notification(what: int) -> void:
    if NodeUtil.is_node_being_edited(self):
        return
            
    match what:
        NOTIFICATION_SORT_CHILDREN:
            var has_visible_children := false
            for idx in range(1, get_child_count()):
                var child := get_child(idx) as DataTypeGroup
                if child and child.visible:
                    has_visible_children = true
                    break
            visible = has_visible_children
