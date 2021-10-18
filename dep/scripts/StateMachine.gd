# Queue overly complicated save system, where var2str or store_* would have sufficed...

extends Resource
class_name StateMachine

static func callSave():
	var SAVEFILE = "user://app_state.res"
	var SAVE:appState = appState.new()

	SAVE.state.count = GlobalFile.count
	ResourceSaver.save(SAVEFILE, SAVE)

static func callLoad():
	if ResourceLoader.exists("user://app_state.res"):
		var SAVEFILE = ResourceLoader.load("user://app_state.res")
		GlobalFile.count = SAVEFILE.state.count
	else:
		GlobalFile.count = 0
