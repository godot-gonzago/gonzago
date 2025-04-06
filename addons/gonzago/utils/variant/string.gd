@tool
@static_unload
extends RefCounted

# TODO: case conversion.
#       https://stringcase.org/
#       https://stringcase.org/cases/

enum Delimiter {
    NONE = 0, SPACE = 1, UNDERSCORE = 2, HYPHEN = 3
}

enum Pattern {
    LOWER = 0, UPPER = 1, CAPITAL = 2, CAMEL = 3
}

#enum Case {
    #PASCAL_CASE,    # PascalCaseExample
    #CAMEL_CASE,     # camelCaseExample
    #SNAKE_CASE,     # snake_case_example, SCREAMING_SNAKE_CASE_EXAMPLE, CONSTANT_CASE_EXAMPLE
    #KEBAB_CASE,     # kebab-case-example, KEBAB-CASE-EXAMPLE
    #TRAIN_CASE      # Train-Case-Example, HTTP-Header-Case
#}

# TODO: RegEx stuff. Email, Url etc.
#       Email:  https://regex101.com/r/SxCdMO/1
#       Url:    https://regex101.com/r/ibVctF/2

# TODO: String searching.
#       https://github.com/godotengine/godot/blob/master/core/string/fuzzy_search.cpp
