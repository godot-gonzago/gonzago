@tool
extends HBoxContainer

const Item := preload("./item.gd")

@export
var icon: Texture2D:
    get:
        var icon_node := get_node("%Icon") as TextureRect
        return icon_node.texture
    set(value):
        var icon_node := get_node("%Icon") as TextureRect
        icon_node.texture = value

@export
var data_type: Theme.DataType

@export
var item_scene: PackedScene

func inspect(t: Theme, type: StringName) -> void:
    var items_container := get_node("%ItemsContainer") as HFlowContainer
    var items := t.get_theme_item_list(data_type, type)
    items.sort()
    
    var child_count := items_container.get_child_count()
    var items_count := items.size()
    
    var set_end_count := min(child_count, items_count)
    for idx in set_end_count:
        var item := items_container.get_child(idx) as Item
        item.inspect(t, type, items[idx])
    
    var needs_to_add := child_count < items_count
    if needs_to_add:
        for idx in range(set_end_count, items_count):
            var item := item_scene.instantiate() as Item
            items_container.add_child(item)
            item.inspect(t, type, items[idx])
    
    var needs_to_remove := child_count > items_count
    if needs_to_remove:
        for idx in range(set_end_count, child_count):
            var child := items_container.get_child(idx) as Item
            child.queue_free()
            
    queue_sort()


func _notification(what: int) -> void:
    if NodeUtil.is_node_being_edited(self):
        return
        
    match what:
        NOTIFICATION_SORT_CHILDREN:
            if NodeUtil.is_node_being_edited(self):
                return
                
            var items_container := get_node("%ItemsContainer") as HFlowContainer
            var has_visible_children := false
            for idx in range(0, items_container.get_child_count()):
                var child := items_container.get_child(idx) as Item
                if child and child.visible:
                    has_visible_children = true
                    break
            visible = has_visible_children
