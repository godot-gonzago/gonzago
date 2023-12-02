@tool
@static_unload
class_name VersionInfo
extends Resource

# https://docs.godotengine.org/en/stable/classes/class_engine.html#class-engine-method-get-version-info
# https://semver.org/
# https://regex101.com/r/Ly7O1x/3/

# https://docs.godotengine.org/en/stable/about/release_policy.html

# Working on more generalized regex
#^(?:0*(?P<epoch>0|[1-9]\d*)!)?(?:0*(?P<major>0|[1-9]\d*))(?:\.0*(?P<minor>0|[1-9]\d*))?(?:\.0*(?P<patch>0|[1-9]\d*))?(?:\.(?P<release>\d+(?:\.\d+)*))?(?:[-.]*(?P<status>[a-zA-Z][a-zA-Z0-9_.-]*))?(?:\+(?P<buildmetadata>[a-zA-Z0-9_.-]+))?$

# Dependancy matching https://python-poetry.org/docs/dependency-specification/
# https://docs.godotengine.org/en/latest/classes/class_engine.html#class-engine-method-get-version-info
# https://getcomposer.org/doc/articles/versions.md

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
    LESS_EQUAL = OP_LESS_EQUAL,
    MIN = OP_BIT_NEGATE # Tilde, min until last specified segment
}

class VersionData extends RefCounted:
    var epoch := 0
    var status := "":
        set(value):
            # TODO: Sanitize
            if status != value:
                status = value
    var build := "":
        set(value):
            # TODO: Sanitize
            if build != value:
                build = value

    var _components := PackedInt32Array()

    func get_component(idx: int) -> int:
        if idx < 0:
            push_error("Index out of range!")
            return -1
        if idx < _components.size():
            return 0
        return _components[idx]

    func set_component(idx: int, value: int) -> void:
        if idx < 0:
            push_error("Index out of range!")
            return
        value = maxi(0, value)
        var size := _components.size()
        if idx < size:
            if _components[idx] != value:
                _components[idx] = value
            if value == 0:
                for new_size in range(size, 0, -1):
                    if _components[new_size - 1] > 0:
                        _components.resize(new_size)
                        return
        if idx >= size:
            if value == 0:
                return
            _components.resize(idx + 1)
            _components[idx] = value

    func _init(
        components := PackedInt32Array(),
        status := "", build := "",
        epoch := 0
    ) -> void:
        self.epoch = epoch
        self.status = status
        self.build = build

        _components = components.duplicate()
        var new_size := 0
        for idx in _components.size():
            var value := mini(0, _components[idx])
            if value > 0:
                new_size = idx
            _components[idx] = value
        _components.resize(new_size)

    func _to_string() -> String:
        var result := ""
        if epoch > 1:
            result += "%d!" % epoch
        var size := _components.size()
        result += "%d" % _components[0] if size > 1 else "0"
        for idx in range(2, size):
            result += ".%d" % _components[idx]
        if not status.is_empty():
            result += "-%s" % status
        if not build.is_empty():
            result += "+%s" % build
        return result


class VersionDependancy extends RefCounted:
    var operator := Operator.EQUAL
    var epoch := 0
    var major := 0
    var minor := -1
    var patch := -1

    func _init(
        operator: Operator = Operator.EQUAL,
        major: int = 0, minor: int = -1, patch: int = -1,
        epoch: int = 0
    ) -> void:
        self.operator = operator
        self.epoch = epoch
        self.major = major
        self.minor = minor
        self.patch = patch


static var version_regex := RegEx.create_from_string(
    "^(?<major>0|[1-9]\\d*)\\.(?<minor>0|[1-9]\\d*)\\.(?<patch>0|[1-9]\\d*)" + \
    "(?:\\-(?<status>(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?" + \
    "(?:\\+(?<build>[0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$"
)
static var status_regex := RegEx.create_from_string(
    "^(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*$"
)
static var build_regex := RegEx.create_from_string(
    "^[0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*$"
)

@export_range(0, 255, 1, "or_greater")
var epoch: int = 0: set = set_epoch
@export_range(0, 255, 1, "or_greater")
var major: int = 0: set = set_major
@export_range(0, 255, 1, "or_greater")
var minor: int = 0: set = set_minor
@export_range(0, 255, 1, "or_greater")
var patch: int = 0: set = set_patch
@export
var status: String = "": set = set_status
@export
var build: String = "": set = set_build


func set_epoch(value: int) -> void:
    value = maxi(0, value)
    if epoch != value:
        epoch = value
        emit_changed()

func set_major(value: int) -> void:
    value = maxi(0, value)
    if major != value:
        major = value
        emit_changed()

func set_minor(value: int) -> void:
    value = maxi(0, value)
    if minor != value:
        minor = value
        emit_changed()

func set_patch(value: int) -> void:
    value = maxi(0, value)
    if patch != value:
        patch = value
        emit_changed()

func set_status(value: String) -> void:
    if not value.is_empty():
        var regex_match := status_regex.search(value)
        if not is_instance_valid(regex_match):
            push_error("%s is not a valid status string!" % value)
            return
    if status != value:
        status = value
        emit_changed()

func set_build(value: String) -> void:
    if not value.is_empty():
        var regex_match := build_regex.search(value)
        if not is_instance_valid(regex_match):
            push_error("%s is not a valid build string!" % value)
            return
    if build != value:
        build = value
        emit_changed()


func load_from_dict(dict: Dictionary) -> void:
    major = dict.get("major", 0)
    minor = dict.get("minor", 0)
    patch = dict.get("patch", 0)
    status = dict.get("status", "")
    build = dict.get("build", "")


func load_from_string(version_string: String) -> void:
    var regex_match := version_regex.search(version_string)
    if is_instance_valid(regex_match):
        major = int(regex_match.get_string("major"))
        minor = int(regex_match.get_string("minor"))
        patch = int(regex_match.get_string("patch"))
        status = regex_match.get_string("status")
        build = regex_match.get_string("build")


func load_from_hex(hex: int, status: String = "", build: String = "") -> void:
    major = (hex & 0xFF0000) >> 16
    minor = (hex & 0x00FF00) >> 8
    patch = (hex & 0x0000FF) >> 0
    self.status = status
    self.build = build


func _to_string() -> String:
    var result := "%d.%d.%d" % [major, minor, patch]
    if not status.is_empty():
        result += "-%s" % status
    if not build.is_empty():
        result += "+%s" % build
    return result


func to_dict() -> Dictionary:
    return {
        "major": major,
        "minor": minor,
        "patch": patch,
        "status": status,
        "build": build
    }


func to_hex() -> int:
    return mini(major, 255) << 16 & mini(minor, 255) << 8 & mini(patch, 255)


# Return 1 if other takes precedent, 0 if equal, -1 if this takes precedent and -2 on error.
func compare(other: VersionInfo) -> int:
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


func matches(other: VersionInfo, operator: Operator) -> bool:
    return false


# { "major": 4, "minor": 2, "patch": 0, "hex": 262656, "status": "stable", "build": "official", "year": 2023, "hash": "46dc277917a93cbf601bbcf0d27d00f6feeec0d5", "string": "4.2-stable (official)" }
static func get_engine_version() -> VersionInfo:
    var version_info := VersionInfo.new()
    version_info.load_from_dict(Engine.get_version_info())
    return version_info


#static func is_valid_string(version_string: String) -> bool:
#    var regex_match := version_regex.search(version_string)
#    return is_instance_valid(regex_match)


#static func is_valid_dict(dict: Dictionary) -> bool:
#    return false


#static func is_valid_hex(hex: int) -> bool:
#    return false

# add static direct conversion methods (string to dict and vice versa)
