@tool
extends HBoxContainer

const Item := preload("./item.gd")

# TODO: Consolidate into one view where data types are draw automaticall (without nodes)
#       Only children should be items (or a context menu)

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


#var _scale_factors := {
    #Theme.DATA_TYPE_COLOR: 3,
    #Theme.DATA_TYPE_CONSTANT: 2,
    #Theme.DATA_TYPE_FONT: 1,
    #Theme.DATA_TYPE_FONT_SIZE: 1,
    #Theme.DATA_TYPE_ICON: 3,
    #Theme.DATA_TYPE_STYLEBOX: 2,
#}
#
#func _ready() -> void:
    #var items_container := get_node("%ItemsContainer") as GridContainer
    #items_container.resized.connect(
        #func():
            #var h_separation := items_container.get_theme_constant("h_separatation")
            #var items_container_width := items_container.get_rect().size.x + h_separation
            #var min_width := 288 * EditorInterface.get_editor_scale() + h_separation
            #var columns := maxi(floori(items_container.get_rect().size.x / min_width), 1)
            #columns = columns * _scale_factors[data_type]
            #items_container.set_deferred("columns", columns),
        #CONNECT_DEFERRED
    #)


func inspect(t: Theme, type: StringName) -> void:
    var items_container := get_node("%ItemsContainer") as HFlowContainer # GridContainer
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
                
            var items_container := get_node("%ItemsContainer") as HFlowContainer # GridContainer
            var has_visible_children := false
            for idx in range(0, items_container.get_child_count()):
                var child := items_container.get_child(idx) as Item
                if child and child.visible:
                    has_visible_children = true
                    break
            visible = has_visible_children
