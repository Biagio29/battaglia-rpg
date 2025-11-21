class_name PokemonInstance


var stats: PokemonStats # Riferimento alla specie (es. Charizard)
var current_hp: int
var current_moves: Array[MoveData] = []
var nickname: String = ""
var level: int = 5
var current_moves_pp: Dictionary = {}
var max_hp: int
# Funzione costruttore (chiamata quando fai PokemonInstance.new())
func _init(base_stats: PokemonStats, level_val: int = 5):
	stats = base_stats
	level = level_val
	nickname = ""
	max_hp = stats.max_hp + (level * 2)
	current_hp = max_hp
	# --- COPIA LE MOSSE ---
	# Prendiamo le mosse di default dalla scheda tecnica e le mettiamo nello zaino personale
	current_moves = []
	for move in stats.starting_moves:
		current_moves.append(move)
		# Inizializziamo i PP massimi per ogni mossa
		current_moves_pp[move.name] = move.max_pp
	# Controllo di sicurezza: se ne ha più di 4, teniamo solo le prime 4
	if current_moves.size() > 4:
		current_moves.resize(4)
	# 
	if current_moves_pp.size() > 4:
		var keys = current_moves_pp.keys()
		for i in range(4, keys.size()):
			current_moves_pp.erase(keys[i])


func level_up():
	level += 1
	# Semplice incremento delle statistiche (puoi migliorare con formule più complesse)
	current_hp = stats.max_hp + (level * 2)
	stats.attack += 1
	stats.defense += 1
	stats.speed += 1

