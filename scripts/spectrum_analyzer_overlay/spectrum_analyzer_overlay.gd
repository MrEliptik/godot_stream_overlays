extends Control

export var max_color: Color = Color.red
export var min_color: Color = Color.green
export var window_title: String = "Sepctrum analyzer overlay"

var effect_capture = null
var effect_spectrum = null

const VU_COUNT = 16
const FREQ_MAX = 6000.0

const WIDTH = 400
const HEIGHT = 100

const MIN_DB = 60

func _ready() -> void:
	OS.set_window_title(window_title)
	get_tree().get_root().set_transparent_background(true)
	# We get the index of the "Record" bus.
	var idx = AudioServer.get_bus_index("Microphone")
	# And use it to retrieve its first effect, which has been defined
	# as an "AudioEffectRecord" resource.
	effect_capture = AudioServer.get_bus_effect(idx, 0)
	# Get the bus effect instance, otherwise, get_magnitude function is not here
	effect_spectrum = AudioServer.get_bus_effect_instance(idx, 1)
	
	print(AudioServer.capture_get_device())
	print(AudioServer.capture_get_device_list())
	print(AudioServer.capture_set_device("Microphone (Maono AU-PM401)"))
	print(AudioServer.capture_get_device())
	
func _process(delta: float) -> void:
#	if !effect_spectrum: return
	var res: Array = analyze_spectrum()

	for i in range(res.size()-1):
		var curr_child = $HBoxContainer.get_child(i)
		curr_child.rect_scale.y = lerp(curr_child.rect_scale.y, res[i], 0.1)
		curr_child.modulate = lerp(min_color, max_color, res[i])
	
func analyze_spectrum() -> Array:
	#warning-ignore:integer_division
	var w = WIDTH / VU_COUNT
	var prev_hz = 0
	var res = []
	for i in range(1, VU_COUNT+1):
		var hz = i * FREQ_MAX / VU_COUNT;
		var magnitude: float = effect_spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1)
		var height = energy * HEIGHT
		prev_hz = hz
		res.append(energy)
	return res
