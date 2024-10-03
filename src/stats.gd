extends Node

# Universal stats
var maxEM = 100
var curEM = 100
var activeChara = "avi"
var defMod = 2 
var gems = 0 
var spawnsA1 = ["res://src/enemydata/grybus.tres","res://src/enemydata/patchett.tres","res://src/enemydata/stalagfite.tres"]

#Avia's stats
var maxAviHealth = 30
var curAviHealth = 30
var maxAviIM = 30
var curAviIM = 30
var aviAtk = 100
var aviDef = 2
var aviMoved = false
var aviSkills = ["Defend", "Back"]

#Astell's stats
var maxAstHealth = 40
var curAstHealth = 40
var maxAstIM = 20
var curAstIM = 20
var astAtk = 4
var astDef = 4
var astMoved = false

#Avia's stats
var maxBroHealth = 60
var curBroHealth = 60
var maxBroIM = 0
var curBroIM = -1
var broAtk = 5
var broDef = 3
var broMoved = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


