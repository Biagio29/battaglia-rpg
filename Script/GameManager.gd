extends Node

enum Bioma{
	arena1,
	arena2,
	arena3,
	arena4,
	arena5,
	cave,
	desert,
	forest,
	indor1,
	indor2,
	path,
	sand,
	sea,
	swamp,
	water
}
# Type enum per i tipi di mosse/pokemon
enum Type{
    BUG,
    DARK,
    DRAGON,
    ELECTRIC,
    FIGHT,
    FIRE,
    FLYING,
    GHOST,
    GRASS,
    GROUND,
    ICE,
    NONE,
    NORMAL,
    POISON,
    PSYCHIC,
    ROCK,
    STEEL,
    WATER
}

var current_biome: Bioma = Bioma.path
# La squadra del giocatore (massimo 6)
var player_party: Array[PokemonInstance] = []

# Indice del pokemon che sta combattendo ora (0 = il primo della lista)
var active_slot_index: int = 0

func _ready():
	# SOLO PER TEST: Creiamo una squadra finta all'avvio del gioco
	setup_test_team()

func setup_test_team():
	# Carichiamo le risorse (assicurati che i percorsi siano giusti!)
	var charizard_res = load("res://Resources/Pokemon/Charizard.tres") 
	var pikachu_res = load("res://Resources/Pokemon/Pikachu.tres")
	
	# Creiamo le istanze "viventi"
	var my_charizard = PokemonInstance.new(charizard_res, 10)
	my_charizard.nickname = "Fiamma"
	var my_pikachu = PokemonInstance.new(pikachu_res, 5)
	my_pikachu.nickname = "Fulmine"
	# Aggiungiamo alla squadra
	player_party.append(my_pikachu)
	player_party.append(my_charizard)
	
	
	print("Squadra creata! Hai " + str(player_party.size()) + " pokemon.")
	print("Primo pokemon: " + player_party[0].stats.name + " Lv." + str(player_party[0].level) + " max HP: " + str(player_party[0].max_hp)) 
func get_active_pokemon() -> PokemonInstance:
	if player_party.size() > 0:
		return player_party[active_slot_index]
	return null