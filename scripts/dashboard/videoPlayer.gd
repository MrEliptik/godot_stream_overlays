extends VideoPlayer

export var timeout = -1
export var loop = true

func _ready() -> void:
	visible = false
	
func play_video():
	visible = true
	play()
	if timeout == -1: return
	$Timer.start(timeout)
	
func stop_video():
	visible = false
	stop()

func _on_ShockedPenguin_finished() -> void:
	if !loop: return
	play()

func _on_Timer_timeout() -> void:
	stop_video()
