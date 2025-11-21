extends Node2D
class_name Pokemon 

# --- VARIABILI DI STATO ---
@export var is_player: bool = false # Se vero, carica i dati dalla squadra del giocatore
@export var stats: PokemonStats     # Per il nemico selvatico, lo trascini qui. Per il player viene sovrascritto.

# Variabile per collegarsi all'istanza specifica (per salvare i danni)
var my_data: PokemonInstance 

var current_hp: int
var level: int = 1

# --- VARIABILI GRAFICHE (Il tuo sistema) ---
var path_back: String = "res://Assets/Sprite/Pokemon/Back/"
var path_front: String = "res://Assets/Sprite/Pokemon/Front/"

# --- INIZIALIZZAZIONE ---
func _ready() -> void:
	# PASSO 1: RECUPERO DATI (VITA, LIVELLO, STATS)
	if is_player:
		# Sei il giocatore: chiedi al GameManager chi deve combattere
		var active_pkmn = GameManager.get_active_pokemon()
		if active_pkmn:
			my_data = active_pkmn       # Memorizzo il collegamento
			stats = active_pkmn.stats   # Prendo le stats base (incluso sprite_number)
			current_hp = active_pkmn.current_hp # Prendo la vita salvata
			level = active_pkmn.level
			print("Caricato Player: " + stats.name + " HP: " + str(current_hp))
		else:
			print("ERRORE: Nessun pokemon nella squadra!")
			return
	else:
		# Sei il nemico: usa le stats impostate nell'Inspector
		current_hp = stats.max_hp
		# Qui potresti aggiungere logica per randomizzare il livello del nemico
	
	# PASSO 2: CARICAMENTO GRAFICO (La tua logica)
	load_dynamic_sprite()

func load_dynamic_sprite():
	# Costruiamo il percorso del file
	var full_path = ""
	var sprite_num_str = str(stats.sprite_number)
	
	if is_player:
		# Il giocatore vede sempre il RETRO del proprio pokemon
		full_path = path_back + sprite_num_str + ".png"
	else:
		# Il giocatore vede sempre il FRONTE del nemico
		full_path = path_front + sprite_num_str + ".png"
	
	# Tentativo di caricamento sicuro
	if ResourceLoader.exists(full_path):
		var tex = load(full_path)
		$Sprite2D.texture = tex
	else:
		print("ERRORE: Sprite non trovato al percorso: " + full_path)


# --- GESTIONE DANNI ---
func take_damage(amount: int) -> void:
	current_hp -= amount
	current_hp = max(0, current_hp)
	
	# Aggiorniamo il dato persistente se è il giocatore
	if is_player and my_data:
		my_data.current_hp = current_hp
		
	print(stats.name + " ha subito " + str(amount) + " danni! HP: " + str(current_hp))
	
	if current_hp == 0:
		die()

func die() -> void:
	print(stats.name + " è esausto!")
	# Qui aggiungerai l'animazione (tween che va verso il basso)
	# queue_free() # In battaglia a turni meglio nasconderlo o animarlo, non cancellarlo subito
	hide()
