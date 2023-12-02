@tool
class_name SubtitleSettingsBroker
extends GonzagoSettingsBroker


## Keeps track of subtitle related project settings.


enum Mode {
    NONE,
    SUBTITLES,
    CLOSED_CAPTIONS
}

enum SpeakerIndicationFlags {
    NONE = 0,
    COLORS = 1 << 0,
    NAMES = 1 << 1
}

enum FontType {
    DEFAULT,
    SANS_SERIF,
    EASY_READ
}

# public readonly Setting<float> FontSize;

enum EdgeEffectFlags {
    NONE = 0,
    OUTLINE = 1 << 0,
    DROP_SHADOW = 1 << 1
}

enum LetterboxingMode {
    NONE,
    NON_INTRUSIVE,
    FULL_RECT
}

# public readonly Setting<float> LetterboxingTransparency;
