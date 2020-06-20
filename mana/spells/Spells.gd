extends Node

var NONE = Spell.new()
var AIR = Spell.new()
var FIRE = Spell.new()
var LIFE = Spell.new()
var LIGHTNING = Spell.new()
var NATURE = Spell.new()
var POISON = Spell.new()
var STONE = Spell.new()
var WATER = Spell.new()

func _ready():
	AIR.name = "Air"
	AIR.color = Color(0x61d3e3ff)

	FIRE.name = "Fire"
	FIRE.color = Color(0xb21030ff)

	LIFE.name = "Life"
	LIFE.color = Color(0xebebebff)

	LIGHTNING.name = "Lightning"
	LIGHTNING.color = Color(0xebd320ff)

	NATURE.name = "Nature"
	NATURE.color = Color(0x9aeb00ff)

	POISON.name = "Poison"
	POISON.color = Color(0x9241f3ff)

	STONE.name = "Stone"
	STONE.color = Color(0x797979ff)

	WATER.name = "Water"
	WATER.color = Color(0x4161fbff)
