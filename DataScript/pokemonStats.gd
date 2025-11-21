extends Resource
class_name PokemonStats

@export var name: String = "NomePokemon"

@export var sprite_number: int = 1 
@export var max_hp: int = 20
@export var attack: int = 10
@export var defense: int = 10
@export var speed: int = 10
# QUESTE SONO LE MOSSE DI DEFAULT (Quelle che ha appena lo crei)
@export var starting_moves: Array[MoveData]