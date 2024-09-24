extends Control

#Export variables for enemy slots
@export var enOne: Resource = null
@export var enTwo: Resource = null
@export var enThree: Resource = null

var en1SelMat = preload("res://materialshader/en1.tres")
var disableChara = " "
var rng = RandomNumberGenerator.new()
var curChara:Dictionary = {"avi":true, "ast":false, "bro":false}
var movedChara:Dictionary = {"avi":false,"ast":true,"bro":true}
var attacking = false
var charaSpots:Dictionary = {"avi":"ActiveChara", "ast": "BackChara2", "bro": "BackChara1"}

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
	$En2/En2Tex.texture = enTwo.texture
	$En3/En3Tex.texture = enThree.texture

	#Set up the Tactics Menu which is universally the same
	$ActiveCharacter/Tactics.get_popup().connect("id_pressed", _on_tactics_pressed)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Go to main menu when running

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
	options_vis_manager("none")
	var enOneTarg = rng.randi_range(1,3)
	if enOneTarg == 1:
		$BasicAttack.play(charaSpots["avi"]+"Damaged")
		await $BasicAttack.animation_finished 
		Stats.curAviHealth -= roundi(enOne.atk/Stats.aviDef + 1)
		set_bar($AviStats/AviHP, Stats.curAviHealth, Stats.maxAviHealth)

	elif enOneTarg == 2: 
		$BasicAttack.play(charaSpots["ast"]+"Damaged")
		await $BasicAttack.animation_finished 
		Stats.curAstHealth -= roundi(enOne.atk/Stats.astDef + 1)
		set_bar($AstStats/AstHP, Stats.curAstHealth, Stats.maxAstHealth)
	
	elif enOneTarg == 3: 
		$BasicAttack.play(charaSpots["bro"]+"Damaged")
		await $BasicAttack.animation_finished 
		Stats.curBroHealth -= roundi(enOne.atk/Stats.aviDef + 1)
		set_bar($BroStats/BroHP, Stats.curBroHealth, Stats.maxBroHealth)

	options_vis_manager("reset")
	


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
		options_vis_manager("none")
		$BasicAttack.play("En1Damaged")
		await $BasicAttack.animation_finished 
		#Reset Attack Button 
		$ActiveCharacter/Attack.text = "Attack"
		$En1/En1Tex.material = null
		#Turn the current character's turn off
		var turnOff = curChara.find_key(true)
		movedChara[turnOff] = true
		change_turn()

#The following few functions relate to logic within all option buttons excluding Attacking

func _on_skills_pressed(index_pressed):
	var skillName = $ActiveCharacter/Skills.get_popup().get_item_text(index_pressed)
	if skillName != "Back": 
		if skillName == "Defend": 
			defense_manager(curChara.find_key(true))
		var turnOff = curChara.find_key(true)
		movedChara[turnOff] = true
		change_turn()

func _on_tactics_pressed(index_pressed):
	var tactic = $ActiveCharacter/Tactics.get_popup().get_item_text(index_pressed)
	if tactic != "Back":
		if tactic == "Run":
			get_tree().change_scene_to_file("res://src/mainmenu.tscn")



#Set menus and link them to functions (except for attack which has none and tactics which was established at the beginning of the code)
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
		options_vis_manager("reset")
	elif attacking == false: 
		attacking = true
		$ActiveCharacter/Attack.text = "Back"
		options_vis_manager("attack")

#Hide menu buttons
func options_vis_manager(activeButton):
	if activeButton == "attack":
		$ActiveCharacter/Magic.hide()
		$ActiveCharacter/Items.hide()
		$ActiveCharacter/Tactics.hide()
		$ActiveCharacter/Skills.hide()
	if activeButton == "reset":
		$ActiveCharacter/Attack.show()
		$ActiveCharacter/Magic.show()
		$ActiveCharacter/Items.show()
		$ActiveCharacter/Tactics.show()
		$ActiveCharacter/Skills.show()
	if activeButton== "none":
		$ActiveCharacter/Attack.hide()
		$ActiveCharacter/Magic.hide()
		$ActiveCharacter/Items.hide()
		$ActiveCharacter/Tactics.hide()
		$ActiveCharacter/Skills.hide()
