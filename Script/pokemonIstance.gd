class_name PokemonInstance


var stats: PokemonStats # Riferimento alla specie (es. Charizard)
var current_hp: int
var current_moves: Array[MoveData]
var nickname: String = ""
var level: int = 5

# Funzione costruttore (chiamata quando fai PokemonInstance.new())
func _init(base_stats: PokemonStats, level_val: int = 5):
	stats = base_stats
	level = level_val

	# Calcolo semplice della vita basata sul livello (puoi complicarla dopo)
	current_hp = stats.max_hp + (level * 2) 
	# Copiamo le mosse dalla base (in futuro qui gestirai l'apprendimento)
	current_moves = []
	# Nota: qui dovresti avere una logica per scegliere le mosse, 
	# per ora copiamo quelle predefinite se ne hai messe nello script MonsterStats
	# (Se non hai mosse in MonsterStats, dovrai passarle manualmente)

func level_up():
	level += 1
	# Semplice incremento delle statistiche (puoi migliorare con formule più complesse)
	current_hp = stats.max_hp + (level * 2)
	stats.attack += 1
	stats.defense += 1
	stats.speed += 1

