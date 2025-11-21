class_name PokemonInstance


var stats: PokemonStats # Riferimento alla specie (es. Charizard)
var current_hp: int
var current_moves: Array[MoveData] = []
var nickname: String = ""
var level: int = 5

# Funzione costruttore (chiamata quando fai PokemonInstance.new())
func _init(base_stats: PokemonStats, level_val: int = 5):
	stats = base_stats
	level = level_val
	current_hp = stats.max_hp + (level * 2)
	# --- COPIA LE MOSSE ---
	# Prendiamo le mosse di default dalla scheda tecnica e le mettiamo nello zaino personale
	current_moves = []
	for move in stats.starting_moves:
		current_moves.append(move)
		# Controllo di sicurezza: se ne ha più di 4, teniamo solo le prime 4
	if current_moves.size() > 4:
		current_moves.resize(4)

func level_up():
	level += 1
	# Semplice incremento delle statistiche (puoi migliorare con formule più complesse)
	current_hp = stats.max_hp + (level * 2)
	stats.attack += 1
	stats.defense += 1
	stats.speed += 1

