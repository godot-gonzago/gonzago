@tool
@static_unload
class_name Version
extends Resource
## Version info based on [url=https://semver.org]Semantic Versioning[/url].
##
## The description of the script, what it can do,
## and any further detail.
## Compliant with Godot [url=https://docs.godotengine.org/en/stable/about/release_policy.html#godot-versioning]release policy[/url].

# https://docs.godotengine.org/en/stable/classes/class_engine.html#class-engine-method-get-version-info
# https://semver.org/
# https://regex101.com/r/Ly7O1x/3/

# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

static var _version_regex := RegEx.create_from_string(
    r"(?(DEFINE)(?P<n>0|[1-9]\d*)(?P<s>\d*[a-zA-Z_-][\w-]*|(?P>n))(?P<b>[\w-]+))" + \
    r"^(?P<major>(?P>n))(?:\.(?P<minor>(?P>n)))?(?:\.(?P<patch>(?P>n)))?" + \
    r"(?:-(?P<status>(?P>s)(?:\.(?P>s))*))?" + \
    r"(?:\+(?P<build>(?P>b)(?:\.(?P>b))*))?$"
)


static var _status_regex := RegEx.create_from_string(
    r"(?(DEFINE)(?P<n>0|[1-9]\d*)(?P<s>\d*[a-zA-Z_-][\w-]*|(?P>n)))" + \
    r"^(?P>s)(?:\.(?P>s))*$"
)


static var _build_regex := RegEx.create_from_string(
    r"(?(DEFINE)(?P<b>[\w-]+))" + \
    r"^(?P>b)(?:\.(?P>b))*$"
)

var major: int:
    get:
        return (hex & 0xff0000) >> 16
    set(value):
        hex = (hex & ~0xff0000) ^ (clampi(value, 0, 255) << 16)


var minor: int:
    get:
        return (hex & 0x00ff00) >> 8
    set(value):
        hex = (hex & ~0x00ff00) ^ (clampi(value, 0, 255) << 8)


var patch: int:
    get:
        return (hex & 0x0000ff) >> 0
    set(value):
        hex = (hex & ~0x0000ff) ^ (clampi(value, 0, 255) << 0)


var hex := 0:
    set(value):
        value = clampi(value, 0, 0xffffff)
        if hex != value:
            hex = value
            emit_changed()


var status := "":
    set(value):
        if not value.is_empty():
            var regex_match := _status_regex.search(value)
            if not is_instance_valid(regex_match):
                push_error("%s is not a valid status string!" % value)
                return
        if status != value:
            status = value
            emit_changed()


# TODO: Use feature tags?
# https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html
var build := "":
    set(value):
        if not value.is_empty():
            var regex_match := _build_regex.search(value)
            if not is_instance_valid(regex_match):
                push_error("%s is not a valid build string!" % value)
                return
        if build != value:
            build = value
            emit_changed()


@warning_ignore("shadowed_variable")
func _init(
    major := 0, minor := 0, patch := 0,
    status := "", build := ""
) -> void:
    hex = (
        clampi(major, 0, 255) << 16 |
        clampi(minor, 0, 255) << 8 |
        clampi(patch, 0, 255)
    )
    self.status = status
    self.build = build


func _property_can_revert(_property: StringName) -> bool:
    return true


func _property_get_revert(property: StringName) -> Variant:
    match property:
        "major", "minor", "patch", "hex":
            return 0
        "status", "build":
            return ""
        _:
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


## Compare this versions order in relation to the specified [param other] version.
## Precedence follows the [url=https://semver.org/#spec-item-11]SemVer specification[/url].
## Returns [code]1[/code] if [param other] takes precedent,
## [code]0[/code] if both are equal, [code]-1[/code] if this takes precedent
## and [code]-2[/code] on error.
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


func to_dict() -> Dictionary:
    return {
        "major": major,
        "minor": minor,
        "patch": patch,
        "hex": hex,
        "status": status,
        "build": build
    }


func to_bytes() -> PackedByteArray:
    var bytes := PackedByteArray()
    bytes.encode_u32(0, hex)
    var status_buffer := status.to_ascii_buffer()
    var build_buffer := build.to_ascii_buffer()
    bytes.encode_u32(4, status_buffer.size())
    bytes.encode_u32(8, build_buffer.size())
    bytes.append_array(status_buffer)
    bytes.append_array(build_buffer)
    return bytes


static func is_valid(value: Variant) -> bool:
    match typeof(value):
        TYPE_OBJECT when value is Version:
            return true
        TYPE_INT:
            var h := value as int
            return h >= 0 and h <= 0xffffff
        TYPE_STRING:
            var s := value as String
            var regex_match := _version_regex.search(s)
            return is_instance_valid(regex_match)
        TYPE_DICTIONARY:
            var d := value as Dictionary
            return (
                d.has("hex") or
                d.has("major") or
                d.has("minor") or
                d.has("patch")
            )
        TYPE_PACKED_BYTE_ARRAY:
            var b := value as PackedByteArray
            return b.size() >= 12
    return false


static func create(value: Variant) -> Version:
    match typeof(value):
        TYPE_OBJECT when value is Version:
            return value
        TYPE_INT:
            return from_hex(value)
        TYPE_STRING:
            return from_string(value)
        TYPE_DICTIONARY:
            return from_dict(value)
        TYPE_PACKED_BYTE_ARRAY:
            return from_bytes(value)
    return Version.new()


static func is_valid_hex(value: int) -> bool:
    return value >= 0 and value <= 0xffffff


static func from_hex(value: int) -> Version:
    var version := Version.new()
    version.hex = value
    return version


static func is_valid_string(value: String) -> bool:
    var regex_match := _version_regex.search(value)
    return is_instance_valid(regex_match)


static func from_string(value: String) -> Version:
    var version := Version.new()
    var regex_match := _version_regex.search(value)
    if is_instance_valid(regex_match):
        version.major = int(regex_match.get_string("major"))
        version.minor = int(regex_match.get_string("minor"))
        version.patch = int(regex_match.get_string("patch"))
        version.status = regex_match.get_string("status")
        version.build = regex_match.get_string("build")
    return version


static func is_valid_dict(value: Dictionary) -> bool:
    return (
        value.has("hex") or
        value.has("major") or
        value.has("minor") or
        value.has("patch")
    )


static func from_dict(value: Dictionary) -> Version:
    var version := Version.new()
    if value.has("hex"):
        version.hex = value.get("hex", 0)
    else:
        version.major = value.get("major", 0)
        version.minor = value.get("minor", 0)
        version.patch = value.get("patch", 0)
    version.status = value.get("status", "")
    version.build = value.get("build", "")
    return version


static func from_bytes(value: PackedByteArray) -> Version:
    var version := Version.new()
    version.hex = value.decode_u32(0)
    var status_length := value.decode_u32(4)
    var build_length := value.decode_u32(8)
    var start := 12
    var end := start + status_length
    version.status = value.slice(start, end).get_string_from_ascii()
    start = end
    end = start + build_length
    version.build = value.slice(start, end).get_string_from_ascii()
    return version


static func get_application_version() -> Version:
    var version_info := str(ProjectSettings.get_setting("application/config/version"), "1.0.0")
    return from_string(version_info)


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
    var version_info := Engine.get_version_info()
    return from_dict(version_info)


# add static direct conversion methods (string to dict and vice versa)

# TODO: Don't make this util a resource. Make more util style.
# Let other stuff handle this.
class VersionInfo extends RefCounted:
    pass


# TODO:
# Dependancy matching https://python-poetry.org/docs/dependency-specification/
# https://docs.godotengine.org/en/latest/classes/class_engine.html#class-engine-method-get-version-info
# https://getcomposer.org/doc/articles/versions.md
class DependancyInfo extends RefCounted:
    var operator := Operator.EQUAL
    var major := 0
    var minor := -1
    var patch := -1

enum Operator {
    EQUAL = OP_EQUAL,
    NOT_EQUAL = OP_NOT_EQUAL,
    GREATER = OP_GREATER,
    GREATER_EQUAL = OP_GREATER_EQUAL,
    LESS = OP_LESS,
    LESS_EQUAL = OP_LESS_EQUAL,
    MIN = OP_BIT_NEGATE # Tilde, min until last specified segment
}
