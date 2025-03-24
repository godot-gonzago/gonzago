@tool
extends VBoxContainer


const ThemeTree := preload("./views/theme_tree.gd")
const TypeGroup := preload("./views/type_group.gd")

# TODO: Create central theme cache where every ui can reference an instance of an object
#       Filtering can be done through this. Nodes/Controls can be linked to the cache objects
#       instead of doing everything on their own?
#       Rebuild cache when resource changed outside of plugin

# TODO: Create detail view for theme entries
# TODO: Handle readonly (editor, default) and mutable themes differently (give export, merge options)

@export
var type_group_scene: PackedScene


func _enter_tree() -> void:
    if NodeUtil.is_node_being_edited(self):
        return

    inspect_editor_theme()


func _draw() -> void:
    var rect := Rect2(Vector2.ZERO, size)
    var bg := get_theme_stylebox("BottomPanelDebuggerOverride", "EditorStyles")
    draw_style_box(bg, rect)


func inspect_editor_theme() -> void:
    var editor_theme := EditorInterface.get_editor_theme()
    inspect(editor_theme)


func inspect(t: Theme) -> void:
    var tree := get_node("%ThemeTree") as ThemeTree
    tree.inspect(t)

    var item_list := get_node("%ItemList") as VBoxContainer
    #var types := PackedStringArray()

    #var root_types := PackedStringArray()
    #for type in t.get_type_list():
        #if t.get_type_variation_base(type).is_empty():
            #root_types.append(type)

    # TODO: Sort correctly
    #var types_stack := []
    #types_stack.push_back(root_types)
    #while not types_stack.is_empty():
        #var types_list: PackedStringArray = types_stack.pop_back() as PackedStringArray
        #types_list.sort()
        #types.append_array(types_list)
        #for type in types_list:
            #var variations := t.get_type_variation_list(type)
            #types_stack.push_back(variations)

    var types := t.get_type_list()
    types.sort()

    var child_count := item_list.get_child_count()
    var types_count := types.size()

    var set_end_count := min(child_count, types_count)
    for idx in set_end_count:
        var type := types[idx]
        var item := item_list.get_child(idx) as TypeGroup
        item.inspect(t, type, t.get_type_variation_base(type))

    var needs_to_add := child_count < types_count
    if needs_to_add:
        for idx in range(set_end_count, types_count):
            var type := types[idx]
            var item := type_group_scene.instantiate() as TypeGroup
            item_list.add_child(item)
            item.inspect(t, type, t.get_type_variation_base(type))

    var needs_to_remove := child_count > types_count
    if needs_to_remove:
        for idx in range(set_end_count, child_count):
            var child := item_list.get_child(idx) as TypeGroup
            child.queue_free()

    item_list.queue_sort()



class ThemeCache extends Object:
    var _tags := {}
    var _data_types := [
        DataTypeCache.new(), # Colors
        DataTypeCache.new(), # Constants
        DataTypeCache.new(), # Fonts
        DataTypeCache.new(), # Font sizes
        DataTypeCache.new(), # Icons
        DataTypeCache.new()  # Styleboxes
    ]
    var _types: Dictionary = {}
    var _items: Dictionary = {}
    var _base: ThemeCache = null

    func get_types() -> Array[StringName]:
        # can now be joined with base theme?
        return []

    func get_type_base_info() -> void:
        # can now be joined with base theme?
        return

class TagCache extends Object:
    var tag: StringName
    var matching: bool = true

    var types: Array[StringName] = []
    var items: Array[StringName] = []

class DataTypeCache extends Object:
    var matching: bool = true

    var types: Array[StringName] = []
    var items: Array[StringName] = []

class ThemeTypeCache extends Object:
    var matching: bool = true

    var variations: Array[StringName] = []
    var base_type: StringName

class ThemeItemCache extends Object:
    var data_type: int
    var theme_type: StringName
    var name: StringName

    var matching: bool = true
