extends Control

var rng = RandomNumberGenerator.new()
#Export variables for enemy slots
@export var enOne: Resource = roll_enemies(Stats.spawnsA1slt1)
@export var enTwo: Resource = roll_enemies(Stats.spawnsA1slt2)
@export var enThree: Resource = roll_enemies(Stats.spawnsA1slt3)

#various variables
var enSelMat = preload("res://materialshader/en1.tres")
var disableChara = " "
var curChara:Dictionary = {"avi":true, "ast":false, "bro":false}
var movedChara:Dictionary = {"avi":false,"ast":true,"bro":true}
var attacking = false
var charaSpots:Dictionary = {"avi":"ActiveChara", "ast": "BackChara2", "bro": "BackChara1"}
var enSpots:Dictionary = {}
var defBoosted = []
var downChara = []
var slainEn = []
# Called when the node enters the scene tree for the first time.]
func _ready() -> void:
	
	enSpots.get_or_add(enOne,$En1)
	enSpots.get_or_add(enTwo,$En2)
	enSpots.get_or_add(enThree,$En3)

	#Set Value Bars for all HP, IM, and EM
	set_bar($En1/En1Tex/En1HP, enOne.curHealth, enOne.maxHealth)
	set_bar($En2/En2Tex/En2HP, enTwo.curHealth, enTwo.maxHealth)
	set_bar($En3/En3Tex/En3HP, enThree.curHealth, enThree.maxHealth)
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

	

# Called every frame. 'delta' is the elapsed time since the previous frame. (unused)
#func _process(delta: float) -> void:
	#print_debug(slainEn)

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
	for i in range(3):
		var enTarg = rng.randi_range(1,3)
		var curEn = null
		if i == 0:
			if slainEn.has(enOne) == false:
				curEn = enOne
		if i == 1:
			if slainEn.has(enTwo) == false:
				curEn = enTwo
		if i == 2:
			if slainEn.has(enThree) == false:
				curEn = enThree

		if curEn != null:
			if enTarg == 1:
				$BasicAttack.play(charaSpots["avi"]+"Damaged")
				await $BasicAttack.animation_finished 
				Stats.curAviHealth -= roundi(curEn.atk/Stats.aviDef + 1)
				set_bar($AviStats/AviHP, Stats.curAviHealth, Stats.maxAviHealth)
				checkHealth("avi",Stats.curAviHealth)

			elif enTarg == 2: 
				$BasicAttack.play(charaSpots["ast"]+"Damaged")
				await $BasicAttack.animation_finished 
				Stats.curAstHealth -= roundi(curEn.atk/Stats.astDef + 1)
				set_bar($AstStats/AstHP, Stats.curAstHealth, Stats.maxAstHealth)
				checkHealth("ast",Stats.curAstHealth)

			elif enTarg == 3: 
				$BasicAttack.play(charaSpots["bro"]+"Damaged")
				await $BasicAttack.animation_finished 
				Stats.curBroHealth -= roundi(curEn.atk/Stats.broDef + 1)
				set_bar($BroStats/BroHP, Stats.curBroHealth, Stats.maxBroHealth)
				checkHealth("bro",Stats.curBroHealth)

	options_vis_manager("reset")
	


# Show enemy selections
func _on_en_1_sel_mouse_entered() -> void:
	if attacking == true:
		$En1/En1Tex.material = enSelMat
func _on_en_1_sel_mouse_exited() -> void:
	if attacking == true:
		$En1/En1Tex.material = null

func _on_en_2_sel_mouse_entered() -> void:
	if attacking == true: 
		$En2/En2Tex.material = enSelMat

func _on_en_2_sel_mouse_exited() -> void:
	if attacking == true: 
		$En2/En2Tex.material = null

func _on_en_3_sel_mouse_entered() -> void:
	if attacking == true: 
		$En3/En3Tex.material = enSelMat

func _on_en_3_sel_mouse_exited() -> void:
	if attacking == true: 
		$En3/En3Tex.material = null


#Do the funny basic attack
func _on_en_1_sel_pressed() -> void:
	basic_attack($En1/En1Tex/En1HP,enOne,1)

func _on_en_2_sel_pressed() -> void:
	basic_attack($En2/En2Tex/En2HP,enTwo,2)

func _on_en_3_sel_pressed() -> void:
	basic_attack($En3/En3Tex/En3HP,enThree,3)

#basic attack logic
func basic_attack(enBar,curEn, curNum):
	if attacking == true and slainEn.find(curEn) == -1:
		attacking = false
		curEn.curHealth -= roundi(Stats.get(curChara.find_key(true)+"Atk")/curEn.def + 1)
		set_bar(enBar, curEn.curHealth, curEn.maxHealth)
		options_vis_manager("none")
		$BasicAttack.play("En"+str(curNum)+"Damaged")
		await $BasicAttack.animation_finished 
		#Reset Attack Button and select outlines
		$ActiveCharacter/Attack.text = "Attack"
		if $En1 != null:
			$En1/En1Tex.material = null
		if $En2 != null:
			$En2/En2Tex.material = null
		if $En3 != null:
			$En3/En3Tex.material = null
		#Check Enemy's health
		checkHealth(curEn, curEn.curHealth)
		#Turn the current character's turn off
		var turnOff = curChara.find_key(true)
		movedChara[turnOff] = true
		change_turn()


#The following few functions relate to logic within all option buttons excluding Attacking

func _on_magic_pressed(index_pressed):
	var spellName = $ActiveCharacter/Magic.get_popup().get_item_text(index_pressed)
	if spellName != "Back":
		pass

func _on_skills_pressed(index_pressed):
	var skillName = $ActiveCharacter/Skills.get_popup().get_item_text(index_pressed)
	if skillName != "Back": 
		if skillName == "Defend": 
			defense_manager(curChara.find_key(true))
		var turnOff = curChara.find_key(true)
		movedChara[turnOff] = true
		change_turn()

func _on_items_pressed(index_pressed):
	var itemName = $ActiveCharacter/Items.get_popup().get_item_text(index_pressed)
	if itemName != "Back":
		pass

func _on_tactics_pressed(index_pressed):
	var tacticName = $ActiveCharacter/Tactics.get_popup().get_item_text(index_pressed)
	if tacticName != "Back":
		if tacticName == "Run":
			get_tree().change_scene_to_file("res://src/mainmenu.tscn")



#Set menus and link them to functions (attack and tactics excluded; magic and items aren't implemented at this time)
func menu_manager() -> void: 
	for i in range(Stats.get(curChara.find_key(true)+"Skills").size()):
		$ActiveCharacter/Skills.get_popup().add_item(Stats.get(curChara.find_key(true)+"Skills")[i])
	$ActiveCharacter/Magic.get_popup().add_item("Back")
	$ActiveCharacter/Items.get_popup().add_item("Back")
	$ActiveCharacter/Skills.get_popup().connect("id_pressed", _on_skills_pressed)
	$ActiveCharacter/Magic.get_popup().connect("id_pressed", _on_magic_pressed)
	$ActiveCharacter/Items.get_popup().connect("id_pressed", _on_items_pressed)

func clear_menus(): 
	$ActiveCharacter/Skills.get_popup().disconnect("id_pressed", _on_skills_pressed)
	$ActiveCharacter/Magic.get_popup().disconnect("id_pressed", _on_magic_pressed)
	$ActiveCharacter/Skills.get_popup().disconnect("id_pressed",_on_skills_pressed)
	$ActiveCharacter/Skills.get_popup().clear()
	$ActiveCharacter/Magic.get_popup().clear()
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
		if $En1 != null:
			$En1/En1Tex.material = null
		if $En2 != null:
			$En2/En2Tex.material = null
		if $En3 != null:
			$En3/En3Tex.material = null
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



func roll_enemies(spawnTable):
	var chosenEn = spawnTable[randi() % spawnTable.size()]
	return load(chosenEn)

func checkHealth(target, targetHealth):
	if targetHealth <= 0: 
		if target is String and (target == "avi" or "ast" or "bro"):
			downChara.append(target)
		else:
			slainEn.append(target)
			Stats.gems += int(randi_range(1,3)*target.gemMult)
			remove_child(enSpots[target])
			if slainEn.size() >= 3:
				get_tree().reload_current_scene()
				slainEn.clear()
