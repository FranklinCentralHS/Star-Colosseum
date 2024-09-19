extends Control

#Export variables for enemy slots
@export var enOne: Resource = null

var en1SelMat = preload("res://materialshader/en1.tres")
var disableChara = " "
var rng = RandomNumberGenerator.new()
var curChara:Dictionary = {"avi":true, "ast":false, "bro":false}
var movedChara:Dictionary = {"avi":false,"ast":true,"bro":true}
var attacking = false

var defBoosted = []
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
		defense_manager("clear")
		clear_menus()
		menu_manager()
		

#All enemies attack
func en_attack() -> void: 
	var enOneTarg = rng.randi_range(1,3)
	if enOneTarg == 1:
		Stats.curAviHealth -= roundi(enOne.atk/Stats.aviDef + 1)
		set_bar($AviStats/AviHP, Stats.curAviHealth, Stats.maxAviHealth)

	elif enOneTarg == 2: 
		Stats.curAstHealth -= roundi(enOne.atk/Stats.astDef + 1)
		set_bar($AstStats/AstHP, Stats.curAstHealth, Stats.maxAstHealth)
	
	elif enOneTarg == 3: 
		Stats.curBroHealth -= roundi(enOne.atk/Stats.aviDef + 1)
		set_bar($BroStats/BroHP, Stats.curBroHealth, Stats.maxBroHealth)
	


# Show enemy selection
func _on_en_1_sel_mouse_entered() -> void:
	if attacking == true:
		$En1/En1Tex.material = en1SelMat
func _on_en_1_sel_mouse_exited() -> void:
	if attacking == true:
		$En1/En1Tex.material = null

#Do the funny basic attack
func _on_en_1_sel_pressed() -> void:
	if attacking == true:
		attacking = false
		enOne.curHealth -= Stats.get(curChara.find_key(true)+"Atk")
		set_bar($En1/En1Tex/En1HP, enOne.curHealth, enOne.maxHealth)
		$BasicAttack.play("En1Damaged")
		await $BasicAttack.animation_finished 
		var turnOff = curChara.find_key(true)
		movedChara[turnOff] = true
		change_turn()


func _on_skills_pressed(index_pressed):
	var skillName = $ActiveCharacter/Skills.get_popup().get_item_text(index_pressed)
	if skillName != "Back": 
		if skillName == "Defend": 
			defense_manager(curChara.find_key(true))
		var turnOff = curChara.find_key(true)
		movedChara[turnOff] = true
		change_turn()


func menu_manager() -> void: 
	for i in range(Stats.get(curChara.find_key(true)+"Skills").size()):
		$ActiveCharacter/Skills.get_popup().add_item(Stats.get(curChara.find_key(true)+"Skills")[i])
	$ActiveCharacter/Skills.get_popup().connect("id_pressed", _on_skills_pressed)

func clear_menus(): 
	$ActiveCharacter/Skills.get_popup().disconnect("id_pressed",_on_skills_pressed)
	$ActiveCharacter/Skills.get_popup().clear()


#Defense changing insanity
func defense_manager(target): 
	# party = all characters
	# enemies = all enemies
	if target == "avi" or "party":
		Stats.aviDef = Stats.aviDef * 2 
		defBoosted.append("avi")
	if target == "ast" or "party":
		Stats.astDef = Stats.astDef * 2 
		defBoosted.append("ast")
	if target == "bro" or "party":
		Stats.broDef = Stats.broDef * 2 
		defBoosted.append("bro")
	if target == "clear":
		for i in range(defBoosted.size()):
			if defBoosted[i] == "avi":
				Stats.aviDef = Stats.aviDef / 2
			if defBoosted[i] == "ast":
				Stats.astDef = Stats.astDef / 2 
			if defBoosted[i] == "bro":
				Stats.broDef = Stats.broDef / 2
		defBoosted.clear()

func _on_attack_pressed() -> void:
	if attacking == true: 
		attacking = false
		$ActiveCharacter/Attack.text = "Attack"
		$En1/En1Tex.material = null
	elif attacking == false: 
		attacking = true
		$ActiveCharacter/Attack.text = "Back"