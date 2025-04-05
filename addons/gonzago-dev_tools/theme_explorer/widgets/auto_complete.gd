@tool
extends LineEdit

# https://forum.godotengine.org/t/how-to-dynamically-show-search-results-of-lineedit/42058/5

var _popup: PopupMenu

var _selected_idx := -1
var _filtered_list = []

func _init() -> void:
    _popup = PopupMenu.new()
    add_child(_popup, false, Node.INTERNAL_MODE_FRONT)


func _ready() -> void:
    if NodeUtil.is_node_being_edited(self):
        return
    
    # Grab focus when ready
    grab_focus()
    # When the text_changed signal is fired, filter the list
    text_changed.connect(_filter_list_and_popup)
    # start with the popup not being able to grab focus
    _popup.unfocusable = true
    
    # When the popup menu is about to popup make it focusable so we can control it with the mouse
    # connect it in a deferred way so it does it at the end of the frame and does not steal the focus
    _popup.about_to_popup.connect(
        func(): _popup.unfocusable = false,
        CONNECT_DEFERRED
    )
    # When the popup menu is going to hide make it unfocusable again
    _popup.popup_hide.connect(
        func(): _popup.unfocusable = true
    )

    # Connect the index_pressed to update_text
    _popup.index_pressed.connect(_update_text)


func _gui_input(event: InputEvent) -> void:
    if NodeUtil.is_node_being_edited(self):
        return
    
    # If popup isn't visible, keep the normal behavior
    if not _popup.visible:
        return

    # if it's visible we check if the action is ui_up or ui_down
    # and act accordingly

    if event.is_action_pressed("ui_up", true):
        # wrap the selected_idx up, focus the item in the popup and accept the event
        _selected_idx = wrapi(_selected_idx - 1, 0, _filtered_list.size())
        _popup.set_focused_item(_selected_idx)
        accept_event()
    if event.is_action_pressed("ui_down", true):
        # wrap the selected_idx down, focus the item in the popup and accept the event
        _selected_idx = wrapi(_selected_idx + 1, 0, _filtered_list.size())
        _popup.set_focused_item(_selected_idx)
        accept_event()
    if event.is_action_pressed("ui_accept"):
        # update the text to the selected index, hide the popup and accept the event
        _update_text(_selected_idx)
        _popup.hide()
        accept_event()


func _update_text(index: int) -> void:
    # set the text to the filtered list value and se the caret column to the end of the text
    text = _filtered_list[index]
    caret_column = text.length()


func _filter_list_and_popup(input_text: String) -> void:
    if input_text.length() < 2:
        # if input_text is less than 2 characters hide the popup and set the selected index to -1
        _popup.hide()
        _selected_idx = -1
        return

    # generate the filtered list by sorting the FRUITS list checking their similarity with the input_text
    _filtered_list = FRUITS.duplicate()
    _filtered_list.sort_custom(func(a:String, b:String): return a.similarity(input_text) > b.similarity(input_text))

    # Resize it to the first 10 values
    _filtered_list.resize(10)

    # clear the popup list and fill it
    _popup.clear()
    for value in _filtered_list:
        _popup.add_item(value)

    if not _popup.visible:
        # if the popup is not visible, make it popup at the bottom of the line edit
        _popup.popup(Rect2(position + Vector2(0, size.y + 2), size))

    # select the first value and focus it
    _selected_idx = 0
    _popup.set_focused_item(_selected_idx)


const FRUITS = [
 "apple", "apricot", "avocado", "banana", "bell pepper", "bilberry", "blackberry", "blackcurrant", "blood orange", "blueberry", "boysenberry", "breadfruit", "canary melon", "cantaloupe", "cherimoya", "cherry",
 "chili pepper", "clementine", "cloudberry", "coconut", "cranberry", "cucumber", "currant", "damson", "date", "dragonfruit", "durian", "eggplant", "elderberry", "feijoa", "fig", "goji berry", "gooseberry", "grape", "grapefruit", "guava", "honeydew", "huckleberry", "jackfruit", "jambul", "jujube", "kiwi fruit", "kumquat", "lemon", "lime", "loquat", "lychee", "mandarine", "mango", "mulberry", "nectarine", "nut", "olive", "orange",
 "papaya", "passionfruit", "peach", "pear", "persimmon", "physalis", "pineapple", "plum", "pomegranate", "pomelo", "purple mangosteen", "quince", "raisin", "rambutan", "raspberry",
 "redcurrant", "rock melon", "salal berry", "satsuma", "star fruit", "strawberry", "tamarillo", "tangerine", "tomato", "ugli fruit", "watermelon"
]
