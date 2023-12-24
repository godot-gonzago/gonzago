@tool
extends EditorScript


func _run() -> void:
    var theme := EditorInterface.get_editor_theme()
    if not theme:
        push_error("Failed to load editor theme!")
        return

    var window := AcceptDialog.new()
    window.close_requested.connect(
        func() -> void:
            window.queue_free()
    )
    var tree := TypesTree.new()
    window.add_child(tree)
    tree.inspect(theme)

    EditorInterface.get_base_control().add_child(window)
    window.popup_centered_ratio()

class TypesTree extends Tree:
    var _theme: Theme

    var _tags_regex := RegEx.create_from_string(
        r"([A-Z]?[a-z]+|[A-Z]+(?![a-z]+)|\d+[a-zA-Z]?(?![a-z]+))"
    )
    var _tags: Dictionary = {}

    func _init() -> void:
        hide_root = true
        columns = Theme.DATA_TYPE_MAX + 1
        for data_type in Theme.DATA_TYPE_MAX:
            set_column_expand(data_type + 1, false)

    func _notification(what: int) -> void:
        match what:
            NOTIFICATION_THEME_CHANGED:
                _update_icons()

    func inspect(t: Theme) -> void:
        if _theme == t:
            push_warning("Already inspecting theme!")
            return

        _theme = t
        clear()
        _tags.clear()
        if not _theme:
            push_error("Theme was null!")
            return

        var root := create_item()
        var types := _theme.get_type_list()
        _build_types(root, types)
        print(_tags.keys())

    func _build_types(root: TreeItem, types: PackedStringArray) -> void:


        types.sort()
        for type in types:
            var item := root.create_child()
            item.set_text(0, type)
            for data_type in Theme.DATA_TYPE_MAX:
                var data_type_entries := _theme.get_theme_item_list(data_type, type)
                # TODO: Build searchable StringName? eg. tags
                # https://gist.github.com/SuppieRK/a6fb471cf600271230c8c7e532bdae4b
                # Normalize to lower case separated by space?
                # Use theme item path as StringName: eg: icon/EditorIcons/Search?
                # Indexing by list of words that has list of paths? already excluded etc. can be ignored...
                # This should work
                # (?<word>[A-Z]{2,}|[A-Z]?[a-z]+|\d+)

                #var type_path := StringName("%d/%s" % [data_type, type])
                for regex_match in _tags_regex.search_all(type):
                    var tag := StringName(regex_match.get_string().to_lower())
                    if not _tags.has(tag):
                        _tags[tag] = PackedStringArray()
                    #var tag_holders: PackedStringArray = _tags.get(tag)
                    #tag_holders.append(type_path)
                for data_type_entry in data_type_entries:
                    #print(data_type_entry) # Used to get list of names to test regex
                    #var data_type_entry_path := StringName("%d/%s/%s" % [data_type, type, data_type_entry])
                    for regex_match in _tags_regex.search_all(data_type_entry):
                        var tag := StringName(regex_match.get_string().to_lower())
                        if not _tags.has(tag):
                            _tags[tag] = PackedStringArray()
                        #var tag_holders: PackedStringArray = _tags.get(tag)
                        #tag_holders.append(data_type_entry_path)

                var count := data_type_entries.size()
                item.set_text(data_type + 1, str(count))
            var variations := _theme.get_type_variation_list(type)
            _build_types(item, variations)


    func _update_icons() -> void:
        if not is_inside_tree():
            push_error("Can't update icons when not inside SceneTree!")
            return
        var root := get_root()
        if not root:
            push_error("Tree has not been built!")
            return
        var data_type_icons: Array[Texture2D] = [
            get_theme_icon("Color", "EditorIcons"),
            get_theme_icon("MemberConstant", "EditorIcons"),
            get_theme_icon("Font", "EditorIcons"),
            get_theme_icon("FontSize", "EditorIcons"),
            get_theme_icon("Image", "EditorIcons"),
            get_theme_icon("StyleBoxFlat", "EditorIcons")
        ]
        var root_icon := get_theme_icon("NodeDisabled", "EditorIcons")
        _update_item_icons(root, root_icon, data_type_icons)

    func _update_item_icons(root: TreeItem, root_icon: Texture2D, data_type_icons: Array[Texture2D]) -> void:
        for item in root.get_children():
            var type := item.get_text(0)
            var icon := root_icon
            if has_theme_icon(type, "EditorIcons"):
                icon = get_theme_icon(type, "EditorIcons")
            item.set_icon(0, icon)
            for data_type in Theme.DATA_TYPE_MAX:
                item.set_icon(data_type + 1, data_type_icons[data_type])
            _update_item_icons(item, icon, data_type_icons)
