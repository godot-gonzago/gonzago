@tool
@static_unload
class_name Version
extends Resource

# https://docs.godotengine.org/en/stable/classes/class_engine.html#class-engine-method-get-version-info
# https://semver.org/
# https://regex101.com/r/Ly7O1x/3/

# https://docs.godotengine.org/en/stable/about/release_policy.html

# Working on more generalized regex
#^(?:0*(?P<epoch>0|[1-9]\d*)!)?(?:0*(?P<major>0|[1-9]\d*))(?:\.0*(?P<minor>0|[1-9]\d*))?(?:\.0*(?P<patch>0|[1-9]\d*))?(?:\.(?P<release>\d+(?:\.\d+)*))?(?:[-.]*(?P<status>[a-zA-Z][a-zA-Z0-9_.-]*))?(?:\+(?P<buildmetadata>[a-zA-Z0-9_.-]+))?$
#^[vV]?[ ]*(?:(?P<epoch>0|[1-9]\d*)!)?(?P<components>(?:0|[1-9]\d*)(?:[.](?:0|[1-9]\d*))*)(?:(?:[-]+|[.])?(?P<status>[a-zA-Z]+[a-zA-Z0-9_-]*(?:[.][a-zA-Z0-9_-]+)*))?(?:(?:[+]|[ ]*[(]?)(?P<build>[a-zA-Z0-9_-]+(?:\.[a-zA-Z0-9_-]+)*)(?:[)]?))?$

#^[vV]?[ ]*
#(?:(?P<epoch>0|[1-9]\d*)!)?
#(?P<components>(?:0|[1-9]\d*)(?:[.](?:0|[1-9]\d*))*)(?:[-.]?(?P<status>[a-zA-Z]+(?:0|[1-9]\d*)?))?
#(?:(?:[+]|(?:[ ]*[(]))(?P<build>[a-zA-Z0-9_-]+(?:\.[a-zA-Z0-9_-]+)*)(?:[)])?)?$

#^[vV]?[ ]*
#(?:(?P<epoch>0|[1-9]\d*)!)?
#(?P<components>(?:0|[1-9]\d*)(?:[.](?:0|[1-9]\d*))*)(?:[-.]?
#(?P<status>[a-zA-Z]+)
#(?:[.]?(?P<status_number>0|[1-9]\d*))?
#)?
#(?:(?:[+]|(?:[ ]*[(]))
#(?P<build>[a-zA-Z0-9_-]+(?:[.][a-zA-Z0-9_-]+)*)
#(?:[)])?)?$

#(?(DEFINE)
#(?'n'0|[1-9]\d*)
#(?'b'[a-zA-Z0-9_-]+)
#)
#^[vV]?[ ]*
#(?:(?P<epoch>(?P>n))!)?
#(?P<components>(?P>n)(?:[.](?P>n))*)
#(?:[-.]?
#(?P<status>[a-zA-Z]+)
#(?:[.]?(?P<status_number>(?P>n)))?
#)?
#(?:(?:[+]|(?:[ ]*[(]))
#(?P<build>(?P>b)(?:[.](?P>b))*)
#(?:[)])?)?$

#(?(DEFINE)
#(?P<number>0|[1-9]\d*)
#(?P<status_segment_number>\d*[a-zA-Z-][\w-]*|(?P>number))
#(?P<status_segment>[a-zA-Z][\w-]*)
#(?P<build_segment>[\w-]+)
#(?P<build_pattern>(?P>build_segment)(?:\.(?P>build_segment))*)
#)
#^[vV]?
#(?P<major>(?P>number))
#(?:\.(?P<minor>(?P>number)))?
#(?:\.(?P<patch>(?P>number)))?
#(?:(?:(?P<status_segment_allow_number>\-)?|(?:\.?))
#(?P<status>
#(?(status_segment_allow_number)(?P>status_segment_number)|(?P>status_segment))(?:\.(?P>status_segment_number))*
#)
#)?
#(?:
#(?:(?P<build_needs_closer>[ ][(])?|\+)
#(?P<build>(?P>build_pattern))
#(?(build_needs_closer)[)])
#)?
#$

#(?(DEFINE)
#(?P<n>0|[1-9]\d*)
#(?P<s>\d*[a-zA-Z_-][\w-]*|(?P>n))
#(?P<b>[\w-]+)
#)
#^
#(?P<major>(?P>n))
#(?:\.(?P<minor>(?P>n)))
#(?:\.(?P<patch>(?P>n)))?
#(?:-(?P<status>(?P>s)(?:\.(?P>s))*))?
#(?:\+(?P<build>(?P>b)(?:\.(?P>b))*))?
#$

# https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html
# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

# https://en.wikipedia.org/wiki/Software_versioning#Schemes
# https://peps.python.org/pep-0440/
# https://packaging.python.org/en/latest/specifications/version-specifiers/#version-specifiers
# https://packaging.python.org/en/latest/specifications/dependency-specifiers/

# Make Godot compliant: https://docs.godotengine.org/en/stable/about/release_policy.html#godot-versioning

enum Operator {
    EQUAL = OP_EQUAL,
    NOT_EQUAL = OP_NOT_EQUAL,
    GREATER = OP_GREATER,
    GREATER_EQUAL = OP_GREATER_EQUAL,
    LESS = OP_LESS,
    LESS_EQUAL = OP_LESS_EQUAL
}


static var version_regex := RegEx.create_from_string(
    "(?(DEFINE)(?P<n>0|[1-9]\\d*)(?P<s>\\d*[a-zA-Z_-][\\w-]*|(?P>n))(?P<b>[\\w-]+))" + \
    "^(?:(?P<epoch>(?P>n))!)?(?P<major>(?P>n))(?:\\.(?P<minor>(?P>n)))(?:\\.(?P<patch>(?P>n)))?" + \
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

@export_range(0, 255)
var major: int = 0:
    get = get_major, set = set_major
@export_range(0, 255)
var minor: int = 0:
    get = get_minor, set = set_minor
@export_range(0, 255)
var patch: int = 0:
    get = get_patch, set = set_patch
@export
var status: String = "":
    get = get_status, set = set_status
@export
var build: String = "":
    get = get_build, set = set_build

func get_major() -> int:
    return major
func set_major(value: int) -> void:
    value = maxi(0, value)
    if major != value:
        major = value
        emit_changed()
func bump_major() -> void:
    # TODO: reset others
    major += 1

func get_minor() -> int:
    return minor
func set_minor(value: int) -> void:
    value = maxi(0, value)
    if minor != value:
        minor = value
        emit_changed()
func bump_minor() -> void:
    # TODO: reset others
    minor += 1

func get_patch() -> int:
    return patch
func set_patch(value: int) -> void:
    value = maxi(0, value)
    if patch != value:
        patch = value
        emit_changed()
func bump_patch() -> void:
    # TODO: reset others
    patch += 1

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


func _init(
    major: int = 0,
    minor: int = 0,
    patch: int = 0,
    status: String = "",
    build: String = ""
) -> void:
    self.major = major
    self.minor = minor
    self.patch = patch
    self.status = status
    self.build = build


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
        "status": status,
        "build": build,
        "hex": to_hex(),
        "string": to_pretty_string()
    }


func to_hex() -> int:
    return mini(major, 255) << 16 & mini(minor, 255) << 8 & mini(patch, 255)


func to_bytes() -> PackedByteArray:
    var bytes := PackedByteArray()
    bytes.encode_u32(0, major)
    bytes.encode_u32(4, minor)
    bytes.encode_u32(8, patch)
    var status_buffer := status.to_ascii_buffer()
    bytes.encode_u32(12, status_buffer.size())
    bytes.append_array(status_buffer)
    var build_buffer := build.to_ascii_buffer()
    bytes.encode_u32(bytes.size(), build_buffer.size())
    bytes.append_array(build_buffer)
    return bytes


# Return 1 if other takes precedent, 0 if equal, -1 if this takes precedent and -2 on error.
func compare(other: Version) -> int:
    # Precedence MUST be calculated by separating the version into major, minor, patch
    # and pre-release identifiers in that order (Build metadata does not figure into precedence).

    # Precedence is determined by the first difference when comparing each of these identifiers
    # from left to right as follows: Major, minor, and patch versions are always compared
    # numerically. Example: 1.0.0 < 2.0.0 < 2.1.0 < 2.1.1.
    var result := signi(other.major - major)
    if result != 0:
        return result
    result = signi(other.minor - minor)
    if result != 0:
        return result
    result = signi(other.patch - patch)
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


func matches(other: Version, operator: Operator) -> bool:
    return false




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
static func from_dict(dict: Dictionary) -> Version:
    if not dict.has("major"):
        if dict.has("string"):
            return from_string(dict.get("string"))
        if dict.has("hex"):
            return from_hex(dict.get("hex"))
        return Version.new()
    return Version.new(
        dict.get("major", 0),
        dict.get("minor", 0),
        dict.get("patch", 0),
        dict.get("status", ""),
        dict.get("build", "")
    )


static func from_string(str: String) -> Version:
    var regex_match := version_regex.search(str)
    if is_instance_valid(regex_match):
        return Version.new(
            int(regex_match.get_string("major")),
            int(regex_match.get_string("minor")),
            int(regex_match.get_string("patch")),
            regex_match.get_string("status"),
            regex_match.get_string("build")
        )
    return Version.new()


static func from_hex(hex: int) -> Version:
    return Version.new(
        (hex & 0xFF0000) >> 16,
        (hex & 0x00FF00) >> 8,
        (hex & 0x0000FF) >> 0
    )


static func from_bytes(bytes: PackedByteArray) -> Version:
    var major := bytes.decode_u32(0)
    var minor := bytes.decode_u32(4)
    var patch := bytes.decode_u32(8)
    var status_length := bytes.decode_u32(12)
    var status := bytes.slice(16, status_length).get_string_from_ascii()
    var build_length := bytes.decode_u32(20 + status_length)
    var build := bytes.slice(24 + status_length).get_string_from_ascii()
    return Version.new(
        major,
        minor,
        patch,
        status,
        build
    )


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


#static func is_valid_string(version_string: String) -> bool:
#    var regex_match := version_regex.search(version_string)
#    return is_instance_valid(regex_match)


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
#static func is_valid_dict(dict: Dictionary) -> bool:
#    return false


#static func is_valid_hex(hex: int) -> bool:
#    return false

# add static direct conversion methods (string to dict and vice versa)
