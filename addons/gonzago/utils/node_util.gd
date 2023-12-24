@tool
class_name NodeUtil
extends RefCounted


static func is_node_being_edited(node: Node) -> bool:
    if not Engine.is_editor_hint() or not node.is_inside_tree():
        return false
    var root := node.get_tree().edited_scene_root
    return root and (root.is_ancestor_of(node) or root == node)
