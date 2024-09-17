extends Control

#Export variables for enemy slots
@export var enOne: Resource = null

var en1SelMat = preload("res://materialshader/en1.tres")
var disableChara = " "
var rng = RandomNumberGenerator.new()
var curChara:Dictionary = {"avi":true, "ast":false, "bro":false}
var movedChara:Dictionary = {"avi":false,"ast":true,"bro":true}

# Called when the node enters the scene tree for the first time.]
func _ready() -> void:
	#Set Value Bars for all HP, IM, and EM
	set_bar($En1/En1Tex/En1HP, enOne.curHealth, enOne.maxHealth)
	set_bar($AviStats/AviHP, Stats.curAviHealth, Stats.maxAviHealth)
	set_bar($AviStats/AviHP/AviIM, Stats.curAviIM, Stats.maxAviIM)
	set_bar($AstStats/AstHP/AstIM, Stats.curAstIM, Stats.maxAstIM)
	set_bar($AstStats/AstHP, Stats.curAstHealth, Stats.maxAstHealth)
	set_bar($BroStats/BroHP, Stats.curBroHealth, Stats.maxBroHealth)
	set_bar($BroStats/BroHP/BroIM, Stats.curBroIM, Stats.maxBroIM)
	set_bar($EMStats/EM, Stats.curEM, Stats.maxEM)
	menu_manager()

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

#Manage character's turns
func change_turn() -> void: 
	if movedChara["avi"] == true: 
		curChara["avi"] = false
		en_attack()
		curChara["avi"] = true
		movedChara["avi"] = false
		menu_manager()
		

#All enemies attack
func en_attack() -> void: 
	var enOneTarg = rng.randi_range(1,3)
	if enOneTarg == 1:
		Stats.curAviHealth -= roundi(enOne.atk/Stats.aviDef)
		set_bar($AviStats/AviHP, Stats.curAviHealth, Stats.maxAviHealth)

	elif enOneTarg == 2: 
		Stats.curAstHealth -= roundi(enOne.atk/Stats.astDef)
		set_bar($AstStats/AstHP, Stats.curAstHealth, Stats.maxAstHealth)
	
	elif enOneTarg == 3: 
		Stats.curBroHealth -= roundi(enOne.atk/Stats.aviDef)
		set_bar($BroStats/BroHP, Stats.curBroHealth, Stats.maxBroHealth)
	


# Show enemy selection
func _on_en_1_sel_mouse_entered() -> void:
	$En1/En1Tex.material = en1SelMat
func _on_en_1_sel_mouse_exited() -> void:
	$En1/En1Tex.material = null

#Do the funny basic attack
func _on_en_1_sel_pressed() -> void:
	enOne.curHealth -= Stats.get(curChara.find_key(true)+"Atk")
	set_bar($En1/En1Tex/En1HP, enOne.curHealth, enOne.maxHealth)
	$BasicAttack.play("En1Damaged")
	await $BasicAttack.animation_finished 
	var turnOff = curChara.find_key(true)
	movedChara[turnOff] = true
	change_turn()


func _on_skills_pressed(id) -> void:
	pass # Replace with function body.
	var skillName = $Aviaunanim/Skills.getpopup().get_item_text(id)
	if skillName == "Defend":
		defense_manager(curChara.find_key(true))


func menu_manager() -> void: 
	for i in range(Stats.get(curChara.find_key(true)+"Skills")):
		$Aviaunanim/Skills.get_popup().add_item(Stats.get(curChara.find_key(true)+"Skills")[i])
	$Aviaunanim/Skills.getpopup().connect("id_pressed",self,"_on_skills_pressed")

func defense_manager(target): 
	var defenseStat = Stats.get(target + "Def")
	defenseStat = defenseStat * 2 
	return defenseStat
	 

