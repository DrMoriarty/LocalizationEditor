# Autotranslate Yandex (https://translate.yandex.com/) for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _data: LocalizationData
var _locales_google: Array = []


onready var _from_language_ui = $Panel/VBox/HBox/FromLanguage
onready var _to_language_ui = $Panel/VBox/HBox/ToLanguage
onready var _translate_ui = $Panel/VBox/HBox/Translate
onready var _progress_ui = $Panel/VBox/Progress

const Locales = preload("res://addons/localization_editor/model/LocalizationLocalesList.gd")
const GoogleLocales = preload("res://addons/localization_editor/scenes/auto_translate/google/LocalizationAutoTranslateGoogleLocalesList.gd")

func set_data(data: LocalizationData) -> void:
	_data = data
	_init_from_language_ui()
	_init_to_language_ui()
	_init_connections()

func _init_from_language_ui() -> void:
	_from_language_ui.clear()
	for locale in _data.locales():
		var from_language_label = Locales.label_by_code(locale)
		_from_language_ui.add_item(from_language_label)

func _init_to_language_ui() -> void:
	_to_language_ui.clear()
	_locales_google.clear()
	for locale in GoogleLocales.LOCALES:
		if not _data.locales().has(locale.code):
			_locales_google.append(locale.code)
			var to_language_label = GoogleLocales.label_by_code(locale.code)
			_to_language_ui.add_item(to_language_label)

func _init_connections() -> void:
	_translate_ui.connect("pressed", self, "_on_translate_pressed")

func _on_translate_pressed() -> void:
	var from_language_code = _data.locales()[_from_language_ui.selected]
	var to_language_code = _locales_google[_to_language_ui.selected]
	_translate(from_language_code, to_language_code)
#_progress_ui.max_value 

func _translate(from_code: String, to_code: String) -> void:
	if not _data.locales().has(to_code):
		_data.add_locale(to_code, false)
	for key in _data.keys():
		var from_translation_value = _data.translation_value_by_locale(key, from_code)
		if not from_translation_value.empty():
			var to_translation = _data.translation_by_locale(key, to_code)
			if to_translation.value == null or to_translation.value.empty(): 
				print("REQUEST ", from_translation_value, " -> ", to_translation)
	_data.emit_signal_data_changed()

#var http_request: HTTPRequest

#func _ready() -> void:
#	var http_request = HTTPRequest.new()
#	http_request.timeout = 5
#	add_child(http_request)
#	http_request.connect("request_completed", self, "http_request_completed", [http_request])
#	var URL = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=de&tl=ru&dt=t&q=Spielen"
#
#	#="Spielen".http_escape()
#	http_request.request(URL, [], false, HTTPClient.METHOD_GET)
#
#func http_request_completed(result, response_code, headers, body, http_request):
#	print(body.get_string_from_utf8())
#	remove_child(http_request)
