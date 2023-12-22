@tool
@static_unload
class_name Version
extends Resource

# https://docs.godotengine.org/en/stable/classes/class_engine.html#class-engine-method-get-version-info
# https://semver.org/
# https://regex101.com/r/Ly7O1x/3/

# https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html
# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

# Make Godot compliant: https://docs.godotengine.org/en/stable/about/release_policy.html#godot-versioning

static var version_regex := RegEx.create_from_string(
    "(?(DEFINE)(?P<n>0|[1-9]\\d*)(?P<s>\\d*[a-zA-Z_-][\\w-]*|(?P>n))(?P<b>[\\w-]+))" + \
    "^(?P<major>(?P>n))(?:\\.(?P<minor>(?P>n)))(?:\\.(?P<patch>(?P>n)))?" + \
    "(?:-(?P<status>(?P>s)(?:\\.(?P>s))*))?" + \
    "(?:\\+(?P<build>(?P>b)(?:\\.(?P>b))*))?$"
)
static var status_regex := RegEx.create_from_string(
    "(?(DEFINE)(?P<n>0|[1-9]\\d*)(?P<s>\\d*[a-zA-Z_-][\\w-]*|(?P>n)))" + \
    "^(?P>s)(?:\\.(?P>s))*$"
)
static var build_regex := RegEx.create_from_string(
    "(?(DEFINE)(?P<b>[\\w-]+))" + \
    "^(?P>b)(?:\\.(?P>b))*$"
)

var major: int:
    get = get_major, set = set_major
var minor: int:
    get = get_minor, set = set_minor
var patch: int:
    get = get_patch, set = set_patch
var hex: int = 0:
    get = get_hex, set = set_hex
var status: String = "":
    get = get_status, set = set_status
var build: String = "":
    get = get_build, set = set_build

func get_major() -> int:
    return (hex & 0xFF0000) >> 16
func set_major(value: int) -> void:
    hex = (hex & ~0xFF0000) ^ (clampi(value, 0, 255) << 16)
func bump_major() -> void:
    # TODO: reset others
    major += 1

func get_minor() -> int:
    return (hex & 0x00FF00) >> 8
func set_minor(value: int) -> void:
    hex = (hex & ~0x00FF00) ^ (clampi(value, 0, 255) << 8)
func bump_minor() -> void:
    # TODO: reset others
    minor += 1

func get_patch() -> int:
    return (hex & 0x0000FF) >> 0
func set_patch(value: int) -> void:
    hex = (hex & ~0x0000FF) ^ (clampi(value, 0, 255) << 0)
func bump_patch() -> void:
    # TODO: reset others
    patch += 1

func get_hex() -> int:
    return hex
func set_hex(value: int) -> void:
    value = clampi(value, 0, 0xFFFFFF)
    if hex != value:
        hex = value
        emit_changed()

func get_status() -> String:
    return status
func set_status(value: String) -> void:
    if not value.is_empty():
        var regex_match := status_regex.search(value)
        if not is_instance_valid(regex_match):
            push_error("%s is not a valid status string!" % value)
            return
    if status != value:
        status = value
        emit_changed()
func bump_status_num() -> void:
    # TODO: Check number and increase
    pass
func bump_status() -> void:
    # TODO: Check status and increase (dev (means no release) > alpha > beta > rc > stable (empty) > hotfix?)
    pass

# TODO: Use feature tags?
func get_build() -> String:
    return build
func set_build(value: String) -> void:
    if not value.is_empty():
        var regex_match := build_regex.search(value)
        if not is_instance_valid(regex_match):
            push_error("%s is not a valid build string!" % value)
            return
    if build != value:
        build = value
        emit_changed()


func _property_can_revert(property: StringName) -> bool:
    return true
func _property_get_revert(property: StringName) -> Variant:
    match property:
        "major": return 0
        "minor": return 0
        "patch": return 0
        "hex": return 0
        "status": return ""
        "build": return ""
    return null
func _get_property_list() -> Array[Dictionary]:
    return [
        {
            "name": "major",
              "type": TYPE_INT,
              "usage": PROPERTY_USAGE_EDITOR,
              "hint": PROPERTY_HINT_RANGE,
              "hint_string": "0,255"
        },
        {
            "name": "minor",
              "type": TYPE_INT,
              "usage": PROPERTY_USAGE_EDITOR,
              "hint": PROPERTY_HINT_RANGE,
              "hint_string": "0,255"
        },
        {
            "name": "patch",
              "type": TYPE_INT,
              "usage": PROPERTY_USAGE_EDITOR,
              "hint": PROPERTY_HINT_RANGE,
              "hint_string": "0,255"
        },
        {
            "name": "hex",
              "type": TYPE_INT,
              "usage": PROPERTY_USAGE_NO_EDITOR
        },
        {
            "name": "status",
              "type": TYPE_STRING
        },
        {
            "name": "build",
              "type": TYPE_STRING
        }
    ]


# Return 1 if other takes precedent, 0 if equal, -1 if this takes precedent and -2 on error.
func compare(other: Version) -> int:
    # Precedence MUST be calculated by separating the version into major, minor, patch
    # and pre-release identifiers in that order (Build metadata does not figure into precedence).

    # Precedence is determined by the first difference when comparing each of these identifiers
    # from left to right as follows: Major, minor, and patch versions are always compared
    # numerically. Example: 1.0.0 < 2.0.0 < 2.1.0 < 2.1.1.
    var result := signi(other.hex - hex)
    if result != 0:
        return result

    # When major, minor, and patch are equal, a pre-release version has lower precedence than a
    # normal version: Example: 1.0.0-alpha < 1.0.0.
    if other.status.is_empty():
        result += 1
    if status.is_empty():
        result -= 1
    if result != 0:
        return result

    # Precedence for two pre-release versions with the same
    # major, minor, and patch version MUST be determined by comparing each dot
    # separated identifier from left to right until a difference is found.
    # Example: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 <
    #          1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0.
    var status_list := status.split(".")
    var other_status_list := status.split(".")
    var count := mini(status_list.size(), other_status_list.size())

    for i in count:
        var status_identifier := status_list[i]
        var other_status_identifier := other_status_list[i]

        if status_identifier.is_valid_int():
            # Numeric identifiers always have lower precedence than non-numeric identifiers.
            if !other_status_identifier.is_valid_int():
                return 1

            # Identifiers consisting of only digits are compared numerically.
            var status_int := absi(int(status_identifier))
            var other_status_int := absi(int(other_status_identifier))
            result = signi(other_status_int - status_int)
            if result != 0:
                return result
        else:
            # Numeric identifiers always have lower precedence than non-numeric identifiers.
            if other_status_identifier.is_valid_int():
                return -1

            # Identifiers with letters or hyphens are compared lexically in ASCII sort order.
            result = status_identifier.casecmp_to(other_status_identifier) # TEST?
            if result != 0:
                return result

    # A larger set of pre-release fields has a higher precedence than a smaller set,
    # if all of the preceding identifiers are equal.
    result = signi(other_status_list.size() - status_list.size())
    return result


func _to_string() -> String:
    var result := "%d.%d.%d" % [major, minor, patch]
    if not status.is_empty():
        result += "-%s" % status
    if not build.is_empty():
        result += "+%s" % build
    return result


func to_pretty_string() -> String:
    var result := "v"
    result += "%d.%d" % [major, minor]
    if patch > 0:
        result += ".%d" % patch
    if not status.is_empty():
        result += "-%s" % status
    if not build.is_empty():
        result += " (%s)" % build
    return result


# {
#   "major": 4,
#   "minor": 2,
#   "patch": 0,
#   "hex": 262656,
#   "status": "stable",
#   "build": "official",
#   "string": "4.2-stable (official)"
# }
func to_dict() -> Dictionary:
    return {
        "major": major,
        "minor": minor,
        "patch": patch,
        "hex": hex,
        "status": status,
        "build": build,
        "string": to_pretty_string()
    }


func to_bytes() -> PackedByteArray:
    var bytes := PackedByteArray()
    bytes.encode_u32(0, hex)
    var status_buffer := status.to_ascii_buffer()
    bytes.encode_u32(4, status_buffer.size())
    bytes.append_array(status_buffer)
    var build_buffer := build.to_ascii_buffer()
    bytes.encode_u32(bytes.size(), build_buffer.size())
    bytes.append_array(build_buffer)
    return bytes


static func is_valid_hex(hex: int) -> bool:
    return hex >= 0 and hex <= 0xFFFFFF


static func from_hex(hex: int) -> Version:
    var version := Version.new()
    version.hex = hex
    return version


static func is_valid_string(str: String) -> bool:
    var regex_match := version_regex.search(str)
    return is_instance_valid(regex_match)


static func from_string(str: String) -> Version:
    var version := Version.new()
    var regex_match := version_regex.search(str)
    if is_instance_valid(regex_match):
        version.major = int(regex_match.get_string("major"))
        version.minor = int(regex_match.get_string("minor"))
        version.patch = int(regex_match.get_string("patch"))
        version.status = regex_match.get_string("status")
        version.build = regex_match.get_string("build")
    return version


static func is_valid_dict(dict: Dictionary) -> bool:
    return (
        dict.has("hex") or
        dict.has("major") or
        dict.has("minor") or
        dict.has("patch")
    )


static func from_dict(dict: Dictionary) -> Version:
    var version := Version.new()
    if dict.has("hex"):
        version.hex = dict.get("hex", 0)
    else:
        version.major = dict.get("major", 0)
        version.minor = dict.get("minor", 0)
        version.patch = dict.get("patch", 0)
    version.status = dict.get("status", "")
    version.build = dict.get("build", "")
    return version


static func from_bytes(bytes: PackedByteArray) -> Version:
    var version := Version.new()
    version.hex = bytes.decode_u32(0)
    var status_length := bytes.decode_u32(4)
    version.status = bytes.slice(8, status_length).get_string_from_ascii()
    var build_length := bytes.decode_u32(12 + status_length)
    version.build = bytes.slice(16 + status_length).get_string_from_ascii()
    return version


static func get_application_version() -> Version:
    var str := str(ProjectSettings.get_setting("application/config/version"), "1.0.0")
    return from_string(str)


# {
#   "major": 4,
#   "minor": 2,
#   "patch": 0,
#   "hex": 262656,
#   "status": "stable",
#   "build": "official",
#   "year": 2023,
#   "hash": "46dc277917a93cbf601bbcf0d27d00f6feeec0d5",
#   "string": "4.2-stable (official)"
# }
static func get_engine_version() -> Version:
    var dict := Engine.get_version_info()
    return from_dict(dict)


# add static direct conversion methods (string to dict and vice versa)
