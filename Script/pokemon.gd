extends Node2D

class_name Pokemon  

# Carichiamo le statistiche create prima
@export var stats: PokemonStats
@export var moves: Array[MoveData] # Una lista di mosse che questo mostro conosce
var level: int = 1; # Livello del pokemon
@export var is_attacker: bool = true
var current_hp: int
var sprite: Texture2D
var path_back: String = "res://Assets/Sprite/Pokemon/Back/"
var path_front: String = "res://Assets/Sprite/Pokemon/Front/"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if(is_attacker):
        print("Attacker")
        sprite = load(path_back + str(stats.sprite_number) + ".png")
    else:
        sprite = load(path_front + str(stats.sprite_number) + ".png")
    $Sprite2D.texture = sprite
    current_hp = stats.max_hp

# Funzione per ricevere danni
func take_damage(amount: int) -> void:
    current_hp -= amount
    current_hp = max(0, current_hp) # Non scendere sotto zero
    print(stats.name + " ha subito " + str(amount) + " danni! HP rimanenti: " + str(current_hp))
    if current_hp == 0:
        die()

# Funzione per morire
func die() -> void:
    print(stats.name + " è morto!")
    queue_free()