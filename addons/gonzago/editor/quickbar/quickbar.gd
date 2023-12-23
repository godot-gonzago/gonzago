@tool
class_name GonzagoEditorQuickbar
extends PanelContainer


func add_icon_button() -> Button:
    var button := Button.new()
    button.flat = true
    button.focus_mode = Control.FOCUS_NONE
    return button


func add_menu_button() -> MenuButton:
    var menu_button := MenuButton.new()
    return menu_button


func add_option_button() -> OptionButton:
    var option_button := OptionButton.new()
    option_button.flat = true
    option_button.focus_mode = Control.FOCUS_NONE
    return option_button
