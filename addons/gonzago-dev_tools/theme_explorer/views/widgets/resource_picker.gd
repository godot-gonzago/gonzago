@tool
extends HBoxContainer

# https://docs.godotengine.org/en/stable/classes/class_editorresourcepicker.html
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.h
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp

signal resource_changed(resource: Resource)
signal resource_selected(resource: Resource, inspect: bool)

@export var base_type := ""
@export var editable := true
@export var toggle_mode := false

var edited_resource : Resource = null

var _dropping := false
var _inheritors_array: PackedStringArray = []
var _allowed_types_without_convert: Array[StringName] = []
var _allowed_types_with_convert: Array[StringName] = []

var _assign_button: Button
var _preview_rect: TextureRect
var _edit_button: Button
var _file_dialog: EditorFileDialog
var _duplicate_resources_dialog: ConfirmationDialog
var _duplicate_resources_tree: Tree

var _assign_button_min_size := Vector2i(1, 1)

enum MenuOption {
    OBJ_MENU_LOAD,
    OBJ_MENU_QUICKLOAD,
    OBJ_MENU_INSPECT,
    OBJ_MENU_CLEAR,
    OBJ_MENU_MAKE_UNIQUE,
    OBJ_MENU_MAKE_UNIQUE_RECURSIVE,
    OBJ_MENU_SAVE,
    OBJ_MENU_SAVE_AS,
    OBJ_MENU_COPY,
    OBJ_MENU_PASTE,
    OBJ_MENU_SHOW_IN_FILE_SYSTEM,

    TYPE_BASE_ID = 100,
    CONVERT_BASE_ID = 1000,
}

var _resource_owner: Object

var _edit_menu: PopupMenu


func _init(hide_assign_button_controls := false) -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L1103


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L850


func _update_resource() -> void:
    var resource_path: String
    if edited_resource and edited_resource.resource_path.is_valid_filename():
        resource_path = edited_resource.resource_path
    var cls_name := _get_resource_type(edited_resource)

    if _preview_rect:
        _preview_rect.set_texture(null)
        _assign_button.custom_minimum_size = _assign_button_min_size
        if not edited_resource:
            _assign_button.icon = null
            _assign_button.text = tr("<empty>")
            _assign_button.tooltip_text = ""
        else:
            _assign_button.icon = null
            if Engine.is_editor_hint():
                var editor_theme := EditorInterface.get_editor_theme()
                if editor_theme.has_icon(edited_resource.get_class(), &"EditorIcons"):
                    _assign_button.icon = editor_theme.get_icon(edited_resource.get_class(), &"EditorIcons")

            if not edited_resource.resource_name.is_empty():
                _assign_button.text = edited_resource.resource_name
            elif edited_resource.resource_path.is_valid_filename():
                _assign_button.text = edited_resource.resource_path.get_file()
            else:
                _assign_button.text = cls_name

            if edited_resource.resource_path.is_valid_filename():
                resource_path = edited_resource.resource_path
            _assign_button.tooltip_text = "%s\n%s %s" % [resource_path, tr("Type:"), cls_name]

            # Preview will override the above, so called at the end.
            if Engine.is_editor_hint():
                var previewer := EditorInterface.get_resource_previewer()
                previewer.queue_edited_resource_preview(edited_resource, self, &"_update_resource_preview", edited_resource.get_instance_id())
    elif is_instance_valid(edited_resource):
        _assign_button.tooltip_text = "%s\n%s %s" % [resource_path, tr("Type:"), edited_resource.get_class()]

    _assign_button.disabled = not editable and not edited_resource


func _update_resource_preview(path: String, preview: Texture2D, small_preview: Texture2D, user_data: Variant) -> void:
    if not edited_resource or edited_resource.get_instance_id() != user_data:
        return

    if _preview_rect:
        var scr := edited_resource.get_script() as Script
        if scr:
            _assign_button.text = scr.resource_path.get_file()
            return

        if preview:
            _preview_rect.offset_left = _assign_button.icon.get_width() + _assign_button.get_theme_stylebox(&"normal").content_margin_left + get_theme_constant(&"h_separation", &"Button")

            # Resource-specific stretching.
            if edited_resource is GradientTexture1D or edited_resource is Gradient:
                _preview_rect.stretch_mode = TextureRect.STRETCH_SCALE
                _assign_button.custom_minimum_size = _assign_button_min_size
            else:
                _preview_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                var thumbnail_size := 1
                if Engine.is_editor_hint():
                    thumbnail_size = EditorInterface.get_editor_settings().get_setting("filesystem/file_dialog/thumbnail_size")
                    thumbnail_size *= EditorInterface.get_editor_scale()
                _assign_button.custom_minimum_size = _assign_button_min_size.max(Vector2i(1, thumbnail_size))

            _preview_rect.texture = preview
            _assign_button.text = ""


func _resource_selected() -> void:
    if not edited_resource:
        _edit_button.button_pressed = true
        _update_menu()
        return
    resource_selected.emit(edited_resource, false)


func _resource_changed() -> void:
    resource_changed.emit(edited_resource)
    _update_resource()


func _file_selected(path: String) -> void:
    var loaded_resource := ResourceLoader.load(path)
    if not loaded_resource:
        push_error("Cannot load resource from path '%s'." % path)
        return

    if not base_type.is_empty():
        var any_type_matches := false
        var res_type := loaded_resource.get_class()
        var res_script := loaded_resource.get_script() as Script
        var is_global_class := false
        if res_script:
            var script_type := res_script.get_global_name()
            if not script_type.is_empty():
                is_global_class = true
                res_type = script_type

        for i in base_type.get_slice_count(","):
            var base := base_type.get_slicec(",".unicode_at(0), i)
            any_type_matches = ClassDB.is_parent_class(res_type, base) if is_global_class else loaded_resource.is_class(base)
            if any_type_matches:
                break

        if not any_type_matches:
            push_warning("The selected resource (%s) does not match any type expected for this property (%s)." % [res_type, base_type])
            return

    edited_resource = loaded_resource
    _resource_changed()


func _resource_saved(resource: Object) -> void:
    if edited_resource and resource == edited_resource:
        resource_changed.emit(edited_resource)
        _update_resource()


func _update_menu() -> void:
    if _edit_menu and _edit_menu.visible:
        _edit_button.button_pressed = false
        _edit_menu.hide()
        return

    _update_menu_items()

    var screen_transform := _edit_button.get_screen_transform()
    var gt := screen_transform * _edit_button.get_rect()
    _edit_menu.reset_size()
    var ms := _edit_menu.get_contents_minimum_size().x
    var popup_pos := gt.end - Vector2(ms, 0)
    _edit_menu.position = popup_pos
    _edit_menu.popup()


func _update_menu_items() -> void:
    _ensure_resource_menu();
    _edit_menu.clear()

    # Add options for creating specific subtypes of the base resource type.
    if is_editable():
        set_create_options(_edit_menu)

        # Add an option to load a resource from a file using the QuickOpen dialog.
        _edit_menu.add_icon_item(get_theme_icon(&"Load", &"EditorIcons"), tr("Quick Load..."), MenuOption.OBJ_MENU_QUICKLOAD)
        _edit_menu.set_item_tooltip(-1, tr("Opens a quick menu to select from a list of allowed Resource files."))

        # Add an option to load a resource from a file using the regular file dialog.
        _edit_menu.add_icon_item(get_theme_icon(&"Load", &"EditorIcons"), tr("Load..."), MenuOption.OBJ_MENU_LOAD)

    # Add options for changing existing value of the resource.
    if edited_resource:
        # Determine if the edited resource is part of another scene (foreign) which was imported
        # bool is_edited_resource_foreign_import = EditorNode::get_singleton()->is_resource_read_only(edited_resource, true);
        var is_edited_resource_foreign_import := edited_resource.is_built_in()

        # If the resource is determined to be foreign and imported, change the menu entry's description to 'inspect' rather than 'edit'
        # since will only be able to view its properties in read-only mode.
        if is_edited_resource_foreign_import:
            # The 'Search' icon is a magnifying glass, which seems appropriate, but maybe a bespoke icon is preferred here.
            _edit_menu.add_icon_item(get_theme_icon(&"Search", &"EditorIcons"), tr("Inspect"), MenuOption.OBJ_MENU_INSPECT)
        else:
            _edit_menu.add_icon_item(get_theme_icon(&"Edit", &"EditorIcons"), tr("Edit"), MenuOption.OBJ_MENU_INSPECT)

        if is_editable():
            if not _is_custom_type_script():
                _edit_menu.add_icon_item(get_theme_icon(&"Clear", &"EditorIcons"), tr("Clear"), MenuOption.OBJ_MENU_CLEAR)
            _edit_menu.add_icon_item(get_theme_icon(&"Duplicate", &"EditorIcons"), tr("Make Unique"), MenuOption.OBJ_MENU_MAKE_UNIQUE)

            # Check whether the resource has subresources.
            var property_list := edited_resource.get_property_list()
            var has_subresources := false
            for p in property_list:
                if p.type == TYPE_OBJECT and p.hint == PROPERTY_HINT_RESOURCE_TYPE and p.name != "script" and edited_resource.get(p.name):
                    has_subresources = true
                    break

            if has_subresources:
                _edit_menu.add_icon_item(get_theme_icon(&"Duplicate", &"EditorIcons"), tr("Make Unique (Recursive)"), MenuOption.OBJ_MENU_MAKE_UNIQUE_RECURSIVE)

            _edit_menu.add_icon_item(get_theme_icon(&"Save", &"EditorIcons"), tr("Save"), MenuOption.OBJ_MENU_SAVE)
            _edit_menu.add_icon_item(get_theme_icon(&"Save", &"EditorIcons"), tr("Save As..."), MenuOption.OBJ_MENU_SAVE_AS)

        if edited_resource.resource_path.is_valid_filename():
            _edit_menu.add_separator()
            _edit_menu.add_icon_item(get_theme_icon(&"ShowInFileSystem", &"EditorIcons"), tr("Show in FileSystem"), MenuOption.OBJ_MENU_SHOW_IN_FILE_SYSTEM)

    # Add options to copy/paste resource.
    # https://docs.godotengine.org/en/stable/classes/class_displayserver.html#class-displayserver-method-clipboard-set
    # Ref<Resource> cb = EditorSettings::get_singleton()->get_resource_clipboard();
    var cb: Resource = null
    var paste_valid := false

    if is_editable() and cb:
        if base_type.is_empty():
            paste_valid = true
        else:
            var res_type := _get_resource_type(cb)
            for i in base_type.get_slice_count(","):
                var base := base_type.get_slicec(",".unicode_at(0), i)
                paste_valid = ClassDB.is_parent_class(res_type, base)
                if paste_valid:
                    break

    if edited_resource or paste_valid:
        _edit_menu.add_separator()
        if edited_resource:
            _edit_menu.add_item(tr("Copy"), MenuOption.OBJ_MENU_COPY)
        if paste_valid:
            _edit_menu.add_item(tr("Paste"), MenuOption.OBJ_MENU_PASTE)

    # Add options to convert existing resource to another type of resource.
    #if is_editable and edited_resource:
    #    var conversions: Array[EditorResourceConversionPlugin] = [] # Not available
    #    if not conversions.is_empty():
    #        _edit_menu.add_separator()
    #    var relative_id := 0
    #    for conversion in conversions:
    #        var what := conversion._converts_to()
    #        var icon: Texture2D
    #        if has_theme_icon(what, &"EditorIcons"):
    #            icon = get_theme_icon(what, &"EditorIcons")
    #        else:
    #            icon = get_theme_icon(&"Object", &"EditorIcons")
    #        _edit_menu.add_icon_item(icon, tr("Convert to %s" % what), MenuOption.CONVERT_BASE_ID + relative_id)
    #        relative_id += 1


func _edit_menu_cbk(which: int) -> void:
    match which:
        MenuOption.OBJ_MENU_LOAD:
            var extensions: PackedStringArray = []
            for i in base_type.get_slice_count(","):
                var base := base_type.get_slicec(",".unicode_at(0), i)
                extensions.append_array(ResourceLoader.get_recognized_extensions_for_type(base))
                if ClassDB.class_exists(base):
                    extensions.append_array(ResourceLoader.get_recognized_extensions_for_type(ClassDB.get_parent_class(base)))

            var valid_extensions: Array[String] = []
            valid_extensions.append_array(extensions)

            if not _file_dialog:
                _file_dialog = EditorFileDialog.new()
                _file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
                add_child(_file_dialog)
                _file_dialog.file_selected.connect(_file_selected)

            _file_dialog.clear_filters()
            for e in valid_extensions:
                _file_dialog.add_filter("*.%s" % e, e.to_upper())

            _file_dialog.popup_file_dialog()
        MenuOption.OBJ_MENU_QUICKLOAD:
            var base_types_string := base_type.split(",")
            var base_types: PackedStringArray = []
            for type in base_types_string:
                base_types.push_back(type)
            if Engine.is_editor_hint():
                EditorInterface.popup_quick_open(_file_selected, base_types)
        MenuOption.OBJ_MENU_INSPECT:
            if edited_resource:
                resource_selected.emit(edited_resource, true)
        MenuOption.OBJ_MENU_CLEAR:
            edited_resource = null
            _resource_changed()
        MenuOption.OBJ_MENU_MAKE_UNIQUE:
            if not edited_resource:
                return
            var unique_resource := edited_resource.duplicate()
            if not unique_resource: # duplicate() may fail.
                push_error("Failed to duplicate resource!")
                return
            edited_resource = unique_resource
            _resource_changed()
        MenuOption.OBJ_MENU_MAKE_UNIQUE_RECURSIVE:
            if not edited_resource:
                return
            if not _duplicate_resources_dialog:
                _duplicate_resources_dialog = ConfirmationDialog.new()
                add_child(_duplicate_resources_dialog)
                _duplicate_resources_dialog.title = tr("Make Unique (Recursive)")
                _duplicate_resources_dialog.confirmed.connect(_duplicate_selected_resources)

                var vb := VBoxContainer.new()
                _duplicate_resources_dialog.add_child(vb)
                var label := Label.new()
                label.text = tr("Select resources to make unique:")
                vb.add_child(label)

                _duplicate_resources_tree = Tree.new()
                #duplicate_resources_tree->set_accessibility_name(TTRC("Duplicate resources"));
                _duplicate_resources_tree.auto_translate = AUTO_TRANSLATE_MODE_DISABLED
                vb.add_child(_duplicate_resources_tree)
                _duplicate_resources_tree.columns = 2
                _duplicate_resources_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL

            _duplicate_resources_tree.clear()
            var root := _duplicate_resources_tree.create_item()
            _gather_resources_to_duplicate(edited_resource, root)

            _duplicate_resources_dialog.reset_size()
            _duplicate_resources_dialog.popup_centered(Vector2(500, 400) * EditorInterface.get_editor_scale())
        MenuOption.OBJ_MENU_SAVE:
            if not edited_resource:
                return
            #EditorNode::get_singleton()->save_resource(edited_resource);
        MenuOption.OBJ_MENU_SAVE_AS:
            if not edited_resource:
                return
            var resource_saved := _resource_saved
            #if (!EditorNode::get_singleton()->is_connected("resource_saved", resource_saved)) {
            #    EditorNode::get_singleton()->connect("resource_saved", resource_saved);
            #}
            #EditorNode::get_singleton()->save_resource_as(edited_resource);
        MenuOption.OBJ_MENU_COPY:
            #EditorSettings::get_singleton()->set_resource_clipboard(edited_resource);
            pass
        MenuOption.OBJ_MENU_PASTE:
            #edited_resource = EditorSettings::get_singleton()->get_resource_clipboard();
            #if edited_resource.is_built_in() and EditorInterface.get_edited_scene_root() and \
            #    edited_resource.resource_path.get_slice("::", 0) != EditorInterface.get_edited_scene()->get_scene_file_path():
            #    # Automatically make resource unique if it belongs to another scene.
            #    _edit_menu_cbk(MenuOption.OBJ_MENU_MAKE_UNIQUE)
            #    return
            #_resource_changed()
            pass
        MenuOption.OBJ_MENU_SHOW_IN_FILE_SYSTEM:
            EditorInterface.get_file_system_dock().navigate_to_path(edited_resource.resource_path)
        _:
            # Allow subclasses to handle their own options first, only then fallback on the default branch logic.
            if handle_menu_selected(which):
                return

            if which >= MenuOption.CONVERT_BASE_ID:
                var to_type := which - MenuOption.CONVERT_BASE_ID
                var conversions: Array[EditorResourceConversionPlugin] = [] # EditorNode::get_singleton()->find_resource_conversion_plugin_for_resource(edited_resource);
                if to_type <= conversions.size():
                    push_error("Index out of range for EditorResourceConversionPlugin.")
                    return

                #edited_resource = conversions[to_type].convert(edited_resource)
                _resource_changed()

            if _inheritors_array.is_empty():
                push_error("No inheritors!")
                return

            var intype = _inheritors_array[which - MenuOption.TYPE_BASE_ID]
            var obj: Variant

            if ClassDB.is_class_enabled(intype):
                obj = ClassDB.instantiate(intype) # EditorNode::get_editor_data().script_class_instance(intype);
            else:
                obj = ClassDB.instantiate(intype)

            if not obj:
                obj = ClassDB.instantiate(intype) # EditorNode::get_editor_data().instantiate_custom_type(intype, "Resource");

            var resp: Resource = null
            #Resource *resp = Object::cast_to<Resource>(obj);
            if not resp:
                push_error("Failed to convert resource!")
                return

            #EditorNode::get_editor_data().instantiate_object_properties(obj);

            # Prevent freeing of the object until the end of the update of the resource (GH-88286).
            var old_edited_resource := edited_resource
            edited_resource = resp
            _resource_changed()


func set_create_options(menu_node: Object) -> void:
    _ensure_resource_menu()
    # If a subclass implements this method, use it to replace all create items.
    if menu_node.call_v(&"_set_create_options"):
        return

    # By default provide generic "New ..." options.
    if not base_type.is_empty():
        var idx := 0
        _ensure_allowed_types()
        var allowed_types := _allowed_types_without_convert
        if not allowed_types.is_empty():
            _edit_menu.add_separator(tr("New"))
        for e in allowed_types:
            if not ClassDB.can_instantiate(e):
                continue
            _inheritors_array.push_back(e)
            var icon := ThemeDB.fallback_icon # EditorNode::get_singleton()->get_class_icon(t, "Object");
            var id := MenuOption.TYPE_BASE_ID + idx
            _edit_menu.add_icon_item(icon, e, id)
            #edit_menu->set_item_auto_translate_mode(-1, AUTO_TRANSLATE_MODE_DISABLED);
            #HashMap<String, DocData::ClassDoc>::Iterator class_doc = EditorHelp::get_doc_data()->class_list.find(t);
            #if (class_doc) {
            #    edit_menu->set_item_tooltip(-1, DTR(class_doc->value.brief_description));
            #}
            idx += 1
        if _edit_menu.item_count:
            _edit_menu.add_separator()


func handle_menu_selected(which: int) -> bool:
    return callv(&"_handle_menu_selected", [which])


func _button_draw() -> void:
    if _dropping:
        var color := get_theme_color(&"accent_color", &"Editor")
        _assign_button.draw_rect(Rect2(Vector2.ZERO, _assign_button.size), color, false)


func _button_input(event: InputEvent) -> void:
    var mb := event as InputEventMouseButton
    if mb and mb.is_pressed() and mb.button_index == MOUSE_BUTTON_RIGHT:
        # Only attempt to update and show the menu if we have
        # a valid resource or the Picker is editable, as
        # there will otherwise be nothing to display.
        if edited_resource or is_editable():
            if _edit_menu and _edit_menu.visible:
                _edit_button.set_pressed_no_signal(false)
                _edit_menu.hide()
                return

            _update_menu_items()

            var pos := get_screen_position() + mb.position
            _edit_menu.reset_size()
            _edit_menu.position = pos
            _edit_menu.popup()


func _get_resource_type(resource: Resource) -> String:
    if not resource:
        return ""
    var res_type := resource.get_class()
    var res_script := resource.get_script() as Script
    if not res_script:
        return res_type

    # TODO: Replace with EditorFileSystem when PR #60606 is merged to use cached resource type.
    var script_type := res_script.get_global_name()
    if not script_type.is_empty():
        res_type = script_type

    return res_type


static func _add_allowed_types(type: StringName, vector: Array[StringName]) -> void:
    if vector.find(type):
        # Already added.
        return

    if ClassDB.class_exists(type):
        # Engine class
        if ClassDB.can_instantiate(type):
            vector.push_back(type)
        var inheriters := ClassDB.get_inheriters_from_class(type)
        for s in inheriters:
            _add_allowed_types(s, vector)
    else:
        # Script class
        vector.push_back(type)

    #List<StringName> inheriters;
    #ScriptServer::get_inheriters_list(p_type, &inheriters);
    #for (const StringName &S : inheriters) {
    #    _add_allowed_type(S, p_vector);
    #}


func _ensure_allowed_types() -> void:
    if not _allowed_types_without_convert.is_empty():
        return
    var final_allowed: Array[StringName] = []
    var allowed_types: PackedStringArray = base_type.split(",")
    var size := allowed_types.size()
    for s in allowed_types:
        var base := s.strip_edges()
        if base.begins_with("-"):
            final_allowed.erase(base.right(-1))
            continue
        _add_allowed_types(base, final_allowed)

    for s in final_allowed:
        _allowed_types_without_convert.append(s)
    _allowed_types_with_convert = Array(_allowed_types_without_convert)
    for i in size:
        var base := allowed_types[i].strip_edges()
        if base == "BaseMaterial3D":
            _allowed_types_with_convert.append("Texture2D")
        elif ClassDB.is_parent_class("ShaderMaterial", base):
            _allowed_types_with_convert.append("Shader")
        elif ClassDB.is_parent_class("ImageTexture", base):
            _allowed_types_with_convert.append("Image")


func _is_drop_valid(drag_data: Dictionary) -> bool:
    return false
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L665


func _is_type_valid(type_name: String, allowed_types: Array[StringName]) -> bool:
    return false
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L717


func _is_custom_type_script() -> bool:
    return false
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L728


func _get_drag_data(at_position: Vector2) -> Variant:
    return null
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L738


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
    return false
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L748


func _drop_data(at_position: Vector2, data: Variant) -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L752

# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L824

func set_assign_button_min_size(size: Vector2i) -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L893

func set_base_type(base_type: String) -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L898


func get_base_type() -> String:
    return base_type
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L921


func get_allowed_types() -> PackedStringArray:
    return []
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L925


func set_edited_resource(resource: Resource) -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L942

func set_edited_resource_no_check(resource: Resource) -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L968

func get_edited_resource() -> Resource:
    return edited_resource
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L973

func set_toggle_mode(enable: bool) -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L977

func is_toggle_mode() -> bool:
    return false
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L981

func set_toggle_pressed(pressed: bool) -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L985

func is_toggle_pressed() -> bool:
    return false
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L981

func set_resource_owner(object: Object) -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L997

func set_editable(editable: bool) -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L1001

func is_editable() -> bool:
    return false
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L1007

func _ensure_resource_menu() -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L1011

func _gather_resources_to_duplicate(resource: Resource, item: TreeItem, property_name := "") -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L1022

func _duplicate_selected_resources() -> void:
    pass
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp#L1080

func get_assign_button() -> Button:
    return _assign_button
