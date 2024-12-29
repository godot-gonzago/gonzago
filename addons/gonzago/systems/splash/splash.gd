@tool
class_name GonzagoSplash
extends CanvasLayer

var screens := PackedStringArray()
var fade_in_time := 0.5
var pause_time := 1.0
var fade_out_time := 0.5

func _ready() -> void:
    screens = ProjectSettings.get_setting_with_override("application/boot_splash/screens")
    print(screens)

    var bg_color := ProjectSettings.get_setting_with_override("application/boot_splash/bg_color") as Color
    %BackgroundColor.color = bg_color

    for screen in screens:
        var image := ResourceLoader.load(screen) as Texture2D
        %Screen.texture = image

        %Screen.modulate.a = 0.0
        var tween := create_tween()
        tween.tween_property(%Screen, "modulate:a", 1.0, fade_in_time)
        tween.tween_interval(pause_time)
        tween.tween_property(%Screen, "modulate:a", 0.0, fade_out_time)
        tween.tween_interval(pause_time)
        await tween.finished

    print("Done!")
