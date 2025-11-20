extends Node2D

# DEFINIAMO GLI STATI DELLA BATTAGLIA
enum BattleState { SELECTION, EXECUTION, WIN, LOSE }
var current_state = BattleState.SELECTION

# RIFERIMENTI AI NODI POKEMON (Trascinali dall'Inspector)
@export var player_node: Pokemon
@export var enemy_node: Pokemon

# Variabile per memorizzare la mossa scelta dal giocatore mentre l'AI pensa
var player_chosen_move: MoveData

func _ready():
	# Aspettiamo un attimo che i Pokemon si carichino (i loro _ready)
	await get_tree().create_timer(0.1).timeout
	
	print("--- BATTAGLIA INIZIATA ---")
	print("In campo: " + player_node.stats.name + " VS " + enemy_node.stats.name)
	
	# Abilitiamo l'interfaccia (qui dovrai mostrare i bottoni)
	current_state = BattleState.SELECTION

# --- 1. FASE DI INPUT (Il giocatore preme un bottone) ---
# Collega i segnali dei tuoi bottoni a questa funzione
# move_index sarà 0, 1, 2 o 3 a seconda del bottone premuto
func on_move_button_pressed(move_index: int):
	if current_state != BattleState.SELECTION:
		return
	
	# Recuperiamo la mossa vera dalla lista del Pokemon
	# NOTA: Se usi il sistema Party, player_node.my_data.current_moves[move_index]
	# Per ora usiamo una lista temporanea se non l'hai ancora implementata
	var available_moves = player_node.stats.moves # O player_node.my_data.current_moves
	
	if move_index < available_moves.size():
		player_chosen_move = available_moves[move_index]
		start_turn_resolution()
	else:
		print("Errore: Quella mossa non esiste (Slot vuoto)")

# --- 2. FASE DI RISOLUZIONE (Calcoli e Ordine) ---
func start_turn_resolution():
	current_state = BattleState.EXECUTION
	
	# A. L'AI Sceglie la mossa
	var enemy_move = decide_ai_move()
	
	# B. Chi è più veloce?
	var first: Pokemon
	var second: Pokemon
	var first_move: MoveData
	var second_move: MoveData
	
	var p_speed = player_node.stats.speed
	var e_speed = enemy_node.stats.speed
	
	# Logica Speed Tie (Se velocità uguale, 50% di chance)
	var player_goes_first = false
	if p_speed > e_speed:
		player_goes_first = true
	elif p_speed == e_speed:
		player_goes_first = randf() > 0.5
	
	if player_goes_first:
		first = player_node
		first_move = player_chosen_move
		second = enemy_node
		second_move = enemy_move
	else:
		first = enemy_node
		first_move = enemy_move
		second = player_node
		second_move = player_chosen_move
	
	# C. Eseguiamo gli attacchi in sequenza
	await execute_attack_sequence(first, second, first_move)
	
	# Se il secondo è morto, finisce qui
	if second.current_hp <= 0:
		handle_faint(second)
		return

	await execute_attack_sequence(second, first, second_move)
	
	# Se il primo è morto dopo il contrattacco
	if first.current_hp <= 0:
		handle_faint(first)
		return
		
	# D. Se tutti vivi, nuovo turno
	current_state = BattleState.SELECTION
	print(">>> Nuovo Turno! Scegli un'azione.")

# --- 3. ESECUZIONE ATTACCO ---
func execute_attack_sequence(attacker: Pokemon, defender: Pokemon, move: MoveData):
	print(attacker.stats.name + " usa " + move.name + "!")
	
	# Qui in futuro metterai: await play_animation(move.anim_name)
	await get_tree().create_timer(1.0).timeout
	
	# Calcolo Colpire/Mancare
	var hit_roll = randi() % 100 + 1 # Genera 1-100
	if hit_roll > move.accuracy:
		print("...ma l'attacco fallisce!")
	else:
		# Calcolo Danno (Formula semplificata Pokemon)
		# Danno = (Attacco / Difesa) * Potenza * Variabili
		var atk_stat = float(attacker.stats.attack)
		var def_stat = float(defender.stats.defense)
		
		var damage = int((atk_stat / def_stat) * move.power)
		damage = max(1, damage) # Minimo 1 danno
		
		# Bonus tipo (Stab, Efficacia) andrebbero qui
		
		defender.take_damage(damage)
	
	# Pausa drammatica
	await get_tree().create_timer(1.0).timeout

# --- AI SEMPLICE ---
func decide_ai_move() -> MoveData:
	# Se il nemico ha delle mosse definite, ne sceglie una a caso
	if enemy_node.stats.moves.size() > 0:
		return enemy_node.stats.moves.pick_random()
	else:
		# Mossa di default se ti sei dimenticato di darle al nemico
		print("AI warning: Nemico senza mosse! Uso mossa placeholder.")
		return load("res://Resources/Moves/Tackle.tres") # Assicurati di averne una

# --- GESTIONE FINE BATTAGLIA ---
func handle_faint(fainted_pokemon: Pokemon):
	if fainted_pokemon == player_node:
		current_state = BattleState.LOSE
		print("SEI STATO SCONFITTO! Corri al centro Pokemon...")
		# GameManager.heal_party()
		# get_tree().change_scene_to_file("res://Scenes/Maps/PokemonCenter.tscn")
	else:
		current_state = BattleState.WIN
		print("VITTORIA! Il nemico è esausto.")
		# Qui daresti esperienza
		# get_tree().change_scene_to_file("res://Scenes/Maps/WorldMap.tscn")
