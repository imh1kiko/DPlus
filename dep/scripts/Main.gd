extends Control
signal changeDetected
onready var textNode = $Inner/Rows/GUI_Elems/Margin/Container/Items/RichTextLabel
var processEnabled:bool = false
var pos:Vector2
var thisSession:int = 0

func _ready() -> void:
	# Anything emitting signal will trigger this.
	connect("changeDetected", self, "change")

	# Load prior state
	StateMachine.callLoad()
	textNode.bbcode_text = "[center]"+String(GlobalFile.count)+"[/center]"

	# The bg of app by default ain't transparent. This makes it so.
	get_tree().get_root().transparent_bg = true

	# Current Session counter
	thisSession = 0

func _process(delta: float) -> void:
	#If being dragged by BG, negate the position wherever the user is dragging from.
	if processEnabled:
		OS.set_window_position(OS.window_position + get_global_mouse_position() - pos)

func _on_Minus() -> void:
	if GlobalFile.count > 0:
		GlobalFile.count -=1
		thisSession -= 1
		emit_signal("changeDetected")

func _on_Plus() -> void:
	GlobalFile.count += 1
	thisSession += 1
	emit_signal("changeDetected")

func _on_Reset() -> void:
	GlobalFile.count = 0
	thisSession = 0
	emit_signal("changeDetected")

func _on_quit() -> void:
	get_tree().quit()

func change():
	# This originally had BB code effects, but realizing it keeps re-rendering,
	# I opted to remove it. Now it runs a solid 0% CPU and GPU on idle.
	# 26-11-2021 -- Adding session counter and switching this with string formatting.
	if thisSession == 0:
		textNode.bbcode_text = "[center]%s[/center]" % GlobalFile.count
	else:
		textNode.bbcode_text = "[center]%s [color=red](%s)[/color][/center]" % [GlobalFile.count, thisSession]

	# I've honestly no idea which is better. One way, it writes to disk every change,
	# The other would be to call it on quit, but would lose all progress on random crash.
	# The obvious choice would be to make a settings tab and let the user choose,
	# But if that were true, you wouldn't be here, reading this, would you?
	# Just do what ya want. I only made this for myself.
	StateMachine.callSave()

func _on_BG_gui_input(e: InputEvent) -> void:
	# Basically, if held by BG, allow processing and get position relative to window
	if e is InputEventMouseButton:
		if e.get_button_index() == 1:
			processEnabled = !processEnabled
			pos = get_local_mouse_position()

func _input(event: InputEvent) -> void:
	# Self explanatory. Binds key inputs to actions.
	# FYI -- A/<- = minus, D/-> = plus, R = reset, Q/Esc = Quit
	# Too lazy to add a button for information.

	if event.is_action_pressed("add"):
		_on_Plus()
	elif event.is_action_pressed("remove"):
		_on_Minus()
	elif event.is_action_pressed("reset"):
		_on_Reset()
	elif event.is_action_pressed("quit"):
		get_tree().quit()
