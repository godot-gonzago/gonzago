@tool
extends VBoxContainer

const DataTypeGroup := preload("./data_type_group.gd")

func inspect(t: Theme, type: StringName, base_type: StringName) -> void:
    # TODO: Get icon for type
    #var types_fallback_icon := get_theme_icon("NodeDisabled", "EditorIcons")
    #var type_icon := types_fallback_icon
    #if has_theme_icon(type, "EditorIcons"):
        #type_icon = get_theme_icon(type, "EditorIcons")
    
    var icon := get_node("%Icon") as TextureRect
    icon.texture = ThemeDB.fallback_icon
    
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
