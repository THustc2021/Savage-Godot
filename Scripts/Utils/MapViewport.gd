extends SubViewport

func _unhandled_input(event):
	$"../../GlobalEventManager"._unhandled_input(event)
