@tool
extends RefCounted
## Bitmask utility.
##
## Bitmask utility with functionality for bitmasks,
## enumerations and flags.


## Returns [code]true[/code] if the given value has all given flags,
## otherwise [code]false[/code].
static func has_flags(value: int, flags: int) -> bool:
    return (value & flags) == flags


## Returns the new value with the given flags added.
static func add_flags(value: int, flags: int) -> int:
    return value | flags


## Returns the new value with the given flags removed.
static func remove_flags(value: int, flags: int) -> int:
    return value & ~flags


## Returns the new value with the given flags inverted.
static func toggle_flags(value: int, flags: int) -> int:
    return value ^ flags


# Try to find the string representation of the given value in the given values.
# If a dictionary is passed as values it must contain string-integer pairs (enums work by default).
# If a script is passed a Dictionary is created using its constants (Script.get_script_constant_map()).
# If an array of strings is passed a dictionary is created using the index as value.
# Order is important as the first match will be returned!.
static func build_value_string(value: int, values: Variant) -> String:
    match typeof(values):
        TYPE_DICTIONARY:
            for name in values:
                if values[name] == value:
                    return name
        TYPE_OBJECT:
            var script: Script = values if values is Script else values.get_script()
            if is_instance_valid(script):
                var map := script.get_script_constant_map()
                for name in map:
                    if map[name] == value:
                        return name
        TYPE_ARRAY, TYPE_PACKED_STRING_ARRAY:
            if value >= 0 and value < values.size():
                return str(values[value])
    return str(value)


# Try to build a string representation of the bitmask value using the names in the given flags.
# If a dictionary is passed as values it must contain string-integer pairs (enums work by default).
# If a script is passed a dictionary is created using its constants (Script.get_script_constant_map()).
# If an array of strings is passed a dictionary is created using the index as flag value (pow(2, index)).
# Order is important as early matches will take precedent!.
static func build_flags_string(value: int, flags: Variant, delimiter: String = " | ") -> String:
    var map: Dictionary
    match typeof(flags):
        TYPE_DICTIONARY:
            map = flags
        TYPE_OBJECT:
            var script: Script = flags if flags is Script else flags.get_script()
            if not is_instance_valid(script):
                return str(value)
            map = script.get_script_constant_map()
        TYPE_ARRAY, TYPE_PACKED_STRING_ARRAY:
            map = Dictionary()
            for i in flags.size():
                map[str(flags[i])] = pow(2, i)
        _:
            return str(value)

    var result := PackedStringArray()
    for name in map:
        var map_value: int = int(map[name])
        if has_flags(value, map_value):
            value = remove_flags(value, map_value)
            result.push_back(name)
    if value != 0 or result.is_empty():
        result.push_back(str(value))
    return delimiter.join(result)
