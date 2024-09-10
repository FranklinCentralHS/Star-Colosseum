extends Control

#Export variables for enemy slots
@export var enOne: Resource = null


# Called when the node enters the scene tree for the first time.]
func _ready() -> void:
	#Set Value Bars for all HP, IM, and EM
	set_bar($En1/En1Tex/En1HP, enOne.health, enOne.health)
	set_bar($AviStats/AviHP, Stats.curAviHealth, Stats.maxAviHealth)
	set_bar($AviStats/AviHP/AviIM, Stats.curAviIM, Stats.maxAviIM)
	set_bar($AstStats/AstHP/AstIM, Stats.curAstIM, Stats.maxAstIM)
	set_bar($AstStats/AstHP, Stats.curAstHealth, Stats.maxAstHealth)
	set_bar($BroStats/BroHP, Stats.curBroHealth, Stats.maxBroHealth)
	set_bar($BroStats/BroHP/BroIM, Stats.curBroIM, Stats.maxBroIM)
	set_bar($EMStats/EM, Stats.curEM, Stats.maxEM)

	#Set the enemies' texture to the assigned enemies
	$En1/En1Tex.texture = enOne.texture

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

#Set Value Bars
func set_bar(progressBar,curValue,maxValue) -> void:
	progressBar.value = curValue
	progressBar.max_value = maxValue
	if curValue < 0:
		curValue = 0 
	#Check if a Value Bar has an on-screen counter, and set it if it does
	if progressBar.has_node("Value"):
		progressBar.get_node("Value").text = "%d/%d" % [curValue,maxValue]
