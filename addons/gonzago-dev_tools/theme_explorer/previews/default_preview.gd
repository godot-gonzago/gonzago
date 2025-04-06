@tool
extends Control


func _ready() -> void:
    if Gonzago.NodeUtil.is_node_being_edited(self):
        return
        
    var menu_button := get_node("%MenuButton") as MenuButton
    var sub_menu := PopupMenu.new()
    sub_menu.add_item("SubItem 1")
    sub_menu.add_item("SubItem 2")
    menu_button.get_popup().add_submenu_node_item("Submenu", sub_menu)
    
    var tab_container := get_node("%TabContainer") as TabContainer
    tab_container.set_tab_disabled(2, true)
    
    var tree := get_node("%Tree") as Tree
    var root := tree.create_item()
    root.set_text(0, "Tree")
    var item = root.create_child()
    item.set_text(0, "Item")
    var editable_item = root.create_child()
    editable_item.set_text(0, "Editable Item")
    editable_item.set_editable(0, true)
    var subtree = root.create_child()
    subtree.set_text(0, "Subtree")
    var check_item = subtree.create_child()
    check_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
    check_item.set_text(0, "Check Item")
    check_item.set_editable(0, true)
    var range_item = subtree.create_child()
    range_item.set_cell_mode(0, TreeItem.CELL_MODE_RANGE)
    range_item.set_range(0, 2.0)
    range_item.set_range_config(0, 0.0, 20.0, 0.1)
    range_item.set_editable(0, true)
    var options_item = subtree.create_child()
    options_item.set_cell_mode(0, TreeItem.CELL_MODE_RANGE)
    options_item.set_text(0, "Has,Many,Options")
    options_item.set_editable(0, true)
