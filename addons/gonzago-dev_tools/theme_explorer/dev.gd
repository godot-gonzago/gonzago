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
        if not _theme:
            push_error("Theme was null!")
            return

        var root := create_item()
        var types := _theme.get_type_list()
        _build_types(root, types)

    func _build_types(root: TreeItem, types: PackedStringArray) -> void:
        var words_regex := RegEx.create_from_string(
            r"([A-Z]?[a-z]+|[A-Z]+(?![a-z]+)|\d+[a-zA-Z]?)"
        )

        types.sort()
        for type in types:
            var item := root.create_child()
            item.set_text(0, type)
            for data_type in Theme.DATA_TYPE_MAX:
                var data_type_entries := _theme.get_theme_item_list(data_type, type)
                # TODO: Build searchable StringName?
                # https://gist.github.com/SuppieRK/a6fb471cf600271230c8c7e532bdae4b
                # Normalize to lower case separated by space?
                # Use theme item path as StringName: eg: icon/EditorIcons/Search?
                # Indexing by list of words that has list of paths?
                # https://docs.godotengine.org/en/stable/classes/class_stringname.html#class-stringname-method-capitalize
                # https://docs.godotengine.org/en/stable/classes/class_stringname.html#class-stringname-method-contains
                # https://docs.godotengine.org/en/stable/classes/class_stringname.html#class-stringname-method-split
                # https://docs.godotengine.org/en/stable/classes/class_regex.html#class-regex-method-search-all
                # This should work
                # (?<word>[A-Z]{2,}|[A-Z]?[a-z]+|\d+)
                # flatcase
                # UPPERCASE, SCREAMINGCAMELCASE
                # (lower) camelCase, dromedaryCase
                # PascalCase, UpperCamelCase, StudlyCase
                # snake_case, snail_case, pothole_case
                # ALL_CAPS, SCREAMING_SNAKE_CASE,[16] MACRO_CASE, CONSTANT_CASE
                # camel_Snake_Case
                # Pascal_Snake_Case, Title_Case
                # kebab-case, dash-case, lisp-case, spinal-case
                # TRAIN-CASE, COBOL-CASE, SCREAMING-KEBAB-CASE
                # Train-Case,[13] HTTP-Header-Case[17]
                var words := PackedStringArray()
                for regex_match in words_regex.search_all(type):
                    var word := StringName(regex_match.get_string().to_lower())
                    if not word in words:
                        words.append(word)
                for data_type_entry in data_type_entries:
                    #print(data_type_entry)
                    for regex_match in words_regex.search_all(data_type_entry):
                        var word := StringName(regex_match.get_string().to_lower())
                        if not word in words:
                            words.append(word)
                print(words)

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
