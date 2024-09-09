extends Control


# Called when the node enters the scene tree for the first time.]
func _ready() -> void:
	#Hide any menus that pop up later
	$TacticsPanel.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Go to main menu when running
func _on_run_pressed() -> void:
	get_tree().change_scene_to_file("res://src/mainmenu.tscn")

#Show the tactics menu when the tactics button is pressed
func _on_tactics_pressed() -> void:
	$TacticsPanel.show()

#Hide menus when the back button is pressed
func _on_back_pressed() -> void:
	$TacticsPanel.hide()


func set_health(progress_bar,curHealth,maxHealth) -> void:
	progress_bar.value = curHealth
	progress_bar.max_value = maxHealth
	progress_bar.get_node("Value").text = "%d/%d" % [curHealth,maxHealth]
