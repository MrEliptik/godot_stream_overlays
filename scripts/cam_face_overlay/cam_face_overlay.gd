extends Control

export(float, 0.0, 1.0) var input_threshold: = 0.005
export(float, 0.0, 1.0) var speak_threshold: = 0.05

export var open: StreamTexture = preload("res://visuals/mouth_open.png")
export var closed: StreamTexture = preload("res://visuals/mouth_closed.png")
export var window_title: String = "Cam face overlay"

var effect_record = null
var effect_capture = null
var recording = null
var should_close = false
var speaking = false

func _ready() -> void:
	OS.set_window_title(window_title)
	get_tree().get_root().set_transparent_background(true)
	# We get the index of the "Record" bus.
	var idx = AudioServer.get_bus_index("Microphone")
	# And use it to retrieve its first effect, which has been defined
	# as an "AudioEffectRecord" resource.
	effect_capture = AudioServer.get_bus_effect(idx, 0)
	
	print(AudioServer.capture_get_device())
	print(AudioServer.capture_get_device_list())
	print(AudioServer.capture_set_device("Microphone (Maono AU-PM401)"))
	print(AudioServer.capture_get_device())

func _process(delta: float) -> void:
	var value = process_mic()
	if value > speak_threshold:
		should_close = false
		speaking = true
		$Timer.start()
		if !$AnimationPlayer.is_playing():
			$AnimationPlayer.play("speaking")
	elif should_close:
		speaking = false
		$AnimationPlayer.stop()
		$FaceTexture.texture = closed

func process_mic() -> float:
	var frames = effect_capture.get_buffer(effect_capture.get_frames_available())
	
	var data = PoolRealArray()
	data.resize(frames.size())

	var max_value := 0.0
	for i in range(frames.size()):
		var value: float = (frames[i].x + frames[i].y) / 2.0
		max_value = max(value, max_value)
		data[i] = value
		
	if max_value < input_threshold:
		return 0.0
	
#	print(max_value)
	$ProgressBar.value = max_value
	return max_value

func _on_Timer_timeout() -> void:
	should_close = true

func _on_SpeakingTimer_timeout() -> void:
	pass
