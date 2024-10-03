extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Gems/GemCount.text = str(Stats.gems)


func _on_fight_pressed() -> void:
	Stats.curAviHealth = Stats.maxAviHealth
	Stats.curAstHealth = Stats.maxAstHealth
	Stats.curBroHealth = Stats.maxBroHealth
	Stats.curAviIM = Stats.maxAviIM
	Stats.curAstIM = Stats.maxAstIM
	if Stats.maxBroIM > 0:
		Stats.curBroIM = Stats.maxBroIM
	get_tree().change_scene_to_file("res://src/battle.tscn")

