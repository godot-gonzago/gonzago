@tool
class_name GonzagoSaveGame
extends RefCounted

# TODO: Handle versioning somehow (project settings and auto increment (same for all platforms or separate per platform)?)
# https://docs.godotengine.org/en/stable/classes/class_editorexportplugin.html to save verion_info file?
# or handle in project settings?

# TODO: Handle validation of safe files

const MAGIC_BYTES: PackedByteArray = [71, 83, 65, 86] # "GSAV".to_ascii_buffer()

const ERR_PRODUCT_ID_MISMATCH: int = 1
const ERR_PLATFORM_MISMATCH: int = 2
const ERR_NEWER_VERSION: int = 3
const ERR_OLDER_VERSION: int = 4

# TODO: Get directory data/save game format pattern from ProjectSettings
# TODO: Magic number file handling

class SaveFileSignature extends RefCounted:
    var product_id: String
    var platform: String

    # major, minor, patch (one byte each)
    var product_version_hex: int
    # major, minor, patch (one byte each)
    var godot_version_hex: int
    # major, minor, patch (one byte each)
    var gonzago_version_hex: int

class SaveFileHeader extends RefCounted:
    var name: String
    var description: String
    var unix_time: int
    var meta: Dictionary = {}
    # TODO: Checksum handling to check file integrity?

# TODO: Already collect header data?
static func get_save_files() -> PackedStringArray:
    var paths := PackedStringArray()
    var directory := DirAccess.open("user://saves")
    if DirAccess.get_open_error() != OK:
        return paths

    directory.include_hidden = true
    directory.include_navigational = false
    directory.list_dir_begin()
    var element: String = directory.get_next()
    while not element.is_empty():
        if not directory.current_is_dir() and element.get_extension() == "sav":
            var path := directory.get_current_dir().path_join(element)
            # TODO: Check magic bytes?
            paths.append(path)
        element = directory.get_next()

    return paths

static func get_temp_file_path() -> String:
    return "user://saves/temp.sav"

static func get_next_available_save_file_path() -> String:
    var pattern: String = "user://saves/%d.sav"
    var counter: int = 0
    var path: String = pattern % counter

    while FileAccess.file_exists(path):
        counter += 1
        path = pattern % counter

    return path

static func save(path: String, signature: SaveFileSignature, header: SaveFileHeader, data: Dictionary) -> int:
    # Setup
    # TODO: Create temporary file and override original only if everthing went fine.
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file.get_open_error() != OK:
        return file.get_open_error()

    # Write signature
    #var magic_number_buffer: PacketByteArray = signature.magic_number.to_ascii_buffer()
    var product_id_buffer: PackedByteArray = signature.product_id.to_utf8_buffer()
    var platform_buffer: PackedByteArray = signature.platform.to_utf8_buffer()

    var block_length: int = 16 + product_id_buffer.size() + 16 + platform_buffer.size() + 32 + 32
    file.store_16(block_length)

    file.store_16(product_id_buffer.size())
    file.store_buffer(product_id_buffer)

    file.store_16(platform_buffer.size())
    file.store_buffer(platform_buffer)

    file.store_32(signature.product_version_hex)
    file.store_32(signature.godot_version_hex)

    # Write header
    var name_buffer: PackedByteArray = header.name.to_utf8_buffer()
    var description_buffer: PackedByteArray = header.description.to_utf8_buffer()
    var meta_buffer: PackedByteArray = var_to_bytes(header.meta)

    block_length = 16 + name_buffer.size() + 16 + description_buffer.size() + 32 + 16 + meta_buffer.size()
    file.store_16(block_length)

    file.store_16(name_buffer.size())
    file.store_buffer(name_buffer)

    file.store_16(description_buffer.size())
    file.store_buffer(description_buffer)

    file.store_32(header.unix_time)

    file.store_16(meta_buffer.size())
    file.store_buffer(meta_buffer)

    # Write data
    file.store_var(data)

    # Cleanup
    file.close()
    return OK

static func load_signature(path: String) -> SaveFileSignature:
    # Open file
    var file := FileAccess.open(path, FileAccess.READ)
    if file.get_open_error() != OK:
        return null

    # Skip block size
    file.seek(file.get_position() + 16)

    # Read product info from file
    var result: SaveFileSignature = SaveFileSignature.new()
    # TODO: PackedByteArray.get_string_from_ascii()
    #var magic_number_buffer_length: int = file.get_16()
    #result.magic_number = file.get_buffer(magic_number_buffer_length).get_string_from_ascii()
    var product_id_buffer_length: int = file.get_16()
    result.product_id = file.get_buffer(product_id_buffer_length).get_string_from_utf8()

    var platform_buffer_length : int = file.get_16()
    result.platform = file.get_buffer(platform_buffer_length).get_string_from_utf8()

    result.product_version_hex = file.get_32()
    result.godot_version_hex = file.get_32()

    # Close file
    file.close()
    return result

static func load_header(path : String) -> SaveFileHeader:
    # Open file
    var file := FileAccess.open(path, FileAccess.READ)
    if file.get_open_error() != OK:
        return null

    # Skip product info
    var block_length : int = file.get_16()
    file.seek(file.get_position() + block_length)

    # Read header from file
    var result : SaveFileHeader = SaveFileHeader.new()

    var name_buffer_length : int = file.get_16()
    result.name = file.get_buffer(name_buffer_length).get_string_from_utf8()

    var description_buffer_length : int = file.get_16()
    result.description = file.get_buffer(description_buffer_length).get_string_from_utf8()

    result.unix_time = file.get_32()

    var meta_buffer_length : int = file.get_16()
    result.meta = bytes_to_var(file.get_buffer(name_buffer_length)) as Dictionary

    # Close file
    file.close()
    return result

static func load_data(path: String) -> Dictionary:
    # Open file
    var file := FileAccess.open(path, FileAccess.READ)
    if file.get_open_error() != OK:
        return {}

    # Skip product info and header
    var block_length: int = file.get_16()
    file.seek(file.get_position() + block_length)
    block_length = file.get_16()
    file.seek(file.get_position() + block_length)

    # Read data from file
    var result: Dictionary = file.get_var() as Dictionary

    # Close file
    file.close()
    return result

static func get_current_signature() -> SaveFileSignature:
    var current := SaveFileSignature.new()

    current.product_id = ProjectSettings.get_setting("application/config/name") as String
    current.platform = OS.get_name()

    # TODO: Gather from settings
    # TODO https://godotengine.org/qa/35693/getting-the-product-version however this should work
    var major : int = 0;
    var minor : int = 0;
    var patch : int = 0;
    current.product_version_hex = major << 16 | minor << 8 | patch << 0;

    current.godot_version = Engine.get_version_info()["hex"] as int

    return current

static func is_compatible(a: SaveFileSignature, b: SaveFileSignature, platform_is_relevant: bool = false) -> int:
    if a.product_id != b.product_id:
        return ERR_PRODUCT_ID_MISMATCH
    if platform_is_relevant and a.platform != b.platform:
        return ERR_PLATFORM_MISMATCH
    if a.product_version_hex < b.product_version_hex:
        return ERR_NEWER_VERSION
    if a.product_version_hex > b.product_version_hex:
        return ERR_OLDER_VERSION
    return OK
