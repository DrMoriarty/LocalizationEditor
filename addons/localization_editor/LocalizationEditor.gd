# LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends Control

var _editor: EditorPlugin
var _data:= LocalizationData.new()

const MENU_FILE_OPEN = 0
const MENU_FILE_SAVE = 1
const MENU_FILE_EXTRACT = 6

const ExtractorDialog = preload("./scenes/extractor/extractor_dialog.gd")
const ExtractorDialogScene = preload("./scenes/extractor/extractor_dialog.tscn")

onready var _save_ui = $VBox/Margin/HBox/Save
onready var _open_ui = $VBox/Margin/HBox/Open
onready var _file_ui = $VBox/Margin/HBox/File
onready var _locales_ui = $VBox/Tabs/Locales
onready var _remaps_ui = $VBox/Tabs/Remaps
onready var _translations_ui = $VBox/Tabs/Translations
onready var _auto_translate_ui = $VBox/Tabs/AutoTranslate
onready var _file_menu : MenuButton = $VBox/Margin/HBox/FileMenu
var _extractor_dialog : ExtractorDialog = null

const LocalizationEditorDialogFile = preload("res://addons/localization_editor/LocalizationEditorDialogFile.tscn")

func _ready() -> void:
    pass

func set_editor(editor: EditorPlugin) -> void:
    _editor = editor
    _init_connections()
    _load_data()
    _data.set_editor(editor)
    _data_to_childs()
    _update_view()
    if _extractor_dialog == null:
        _extractor_dialog = ExtractorDialogScene.instance()
        _extractor_dialog.set_registered_string_filter(funcref(self, "_is_string_registered"))
        _extractor_dialog.connect("import_selected", self, "_on_ExtractorDialog_import_selected")
        add_child(_extractor_dialog)
    #_file_menu.get_popup().add_item("Open...", MENU_FILE_OPEN)
    #_file_menu.get_popup().add_item("Save", MENU_FILE_SAVE)
    #_file_menu.get_popup().add_separator()
    #_file_menu.get_popup().add_item("Extractor", MENU_FILE_EXTRACT)

func _init_connections() -> void:
    if not _data.is_connected("settings_changed", self, "_update_view"):
        _data.connect("settings_changed", self, "_update_view")
    if not _save_ui.is_connected("pressed", self, "save_data"):
        _save_ui.connect("pressed", self, "save_data")
    if not _open_ui.is_connected("pressed", self, "_open_file"):
        _open_ui.connect("pressed", self, "_open_file")
    if not _file_menu.is_connected("id_pressed", self, "_on_FileMenu_id_pressed"):
        _file_menu.get_popup().connect("id_pressed", self, "_on_FileMenu_id_pressed")

func _on_FileMenu_id_pressed(id: int):
    match id:
        MENU_FILE_OPEN:
            _open_file()
        MENU_FILE_SAVE:
            save_data()
        MENU_FILE_EXTRACT:
            _extractor_dialog.popup_centered_minsize()

func _load_data() -> void:
    _data.init_data_translations()
    _data.init_data_remaps()

func _data_to_childs() -> void:
    _translations_ui.set_data(_data)
    _remaps_ui.set_data(_data)
    _locales_ui.set_data(_data)
    _auto_translate_ui.set_data(_data)

func _update_view() -> void:
    _file_ui.text = _data.setting_path_to_file()

func save_data() -> void:
    _data.save_data_translations()
    _data.save_data_remaps()

func _open_file() -> void:
    var file_dialog = LocalizationEditorDialogFile.instance()
    var root = get_tree().get_root()
    root.add_child(file_dialog)
    file_dialog.connect("file_selected", self, "_path_to_file_changed")
    file_dialog.connect("popup_hide", self, "_on_popup_hide", [root, file_dialog])
    file_dialog.popup_centered()

func _on_popup_hide(root, dialog) -> void:
    root.remove_child(dialog)
    dialog.queue_free()

func _path_to_file_changed(new_path) -> void:
    _data.setting_path_to_file_put(new_path)
    var file = File.new()
    if file.file_exists(new_path):
        _load_data()
        _data_to_childs()
        _update_view()

# Used as callback for filtering
func _is_string_registered(text: String) -> bool:
    for key in _data.keys():
        if key.value == text:
            return true
    return false

func _on_ExtractorDialog_import_selected(results: Dictionary):
    for text in results:
        if not _is_string_registered(text):
            _data.add_key(text)
    _data.emit_signal_data_changed()
