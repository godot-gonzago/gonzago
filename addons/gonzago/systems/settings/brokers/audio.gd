@tool
class_name AudioSettingsBroker
extends GonzagoSettingsBroker


## Keeps track of audio related project settings.
## Volumes are based on default audio bus.


var mute := false
var volumes := {}

func _init() -> void:
    for i : int in AudioServer.bus_count:
        var bus_name := AudioServer.get_bus_name(i)
        volumes[bus_name] = AudioServer.get_bus_volume_db(i)

func load(config : ConfigFile) -> void:
    mute = config.get_value("audio", "mute", false)
    for bus_name : String in volumes.keys():
        var bus_key := "volumes/%s" % bus_name.to_lower()
        volumes[bus_name] = config.get_value("audio", bus_key, 0.0)

func save(config : ConfigFile) -> void:
    config.set_value("audio", "mute", mute)
    for bus_name : String in volumes.keys():
        var bus_key : String = "volumes/" + bus_name.to_lower()
        config.set_value("audio", bus_key, volumes[bus_name])

func apply() -> void:
    AudioServer.set_bus_mute(0, mute)
    for bus_name : String in volumes.keys():
        var bus_index : int = AudioServer.get_bus_index(bus_name)
        AudioServer.set_bus_volume_db(bus_index, volumes[bus_name])
