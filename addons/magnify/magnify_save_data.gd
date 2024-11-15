@tool
class_name MagnifySaveData
extends Resource

var zoom_in_key: Key
var zoom_out_key: Key
@export var current_zoom_in_key: String
@export var current_zoom_out_key: String
@export var current_ratio: String
@export var current_size: float
@export var keys_enabled: bool

const options: Dictionary = {
	"None": KEY_NONE,

	"Plus": KEY_PLUS,
	"Minus": KEY_MINUS,
	"Keypad Plus": KEY_KP_ADD,
	"Keypad Minus": KEY_KP_SUBTRACT,
	"Keypad Multiply": KEY_KP_MULTIPLY,
	"Keypad Divide": KEY_KP_DIVIDE,

	"Left Sqr Bracket": KEY_BRACKETLEFT,
	"Right Sqr Bracket": KEY_BRACKETRIGHT,
	"Back Slash": KEY_BACKSLASH,

	"Comma": KEY_COMMA,
	"Full Stop/Period": KEY_PERIOD,
	"Forward Slash": KEY_SLASH,

	"Home": KEY_HOME,
	"End": KEY_END,
	"Page Up": KEY_PAGEUP,
	"Page Down": KEY_PAGEDOWN,

	"F1": KEY_F1,
	"F2": KEY_F2,
	"F3": KEY_F3,
	"F4": KEY_F4,
	"F5": KEY_F5,
	"F6": KEY_F6,
	"F7": KEY_F7,
	"F8": KEY_F8,
	"F9": KEY_F9,
	"F10": KEY_F10,
	"F11": KEY_F11,
	"F12": KEY_F12,
	}

func update():
	zoom_in_key = options[current_zoom_in_key]
	zoom_out_key = options[current_zoom_out_key]
