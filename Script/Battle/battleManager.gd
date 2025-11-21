extends Node2D

enum BattleState { SELECTION, EXECUTION, WIN, LOSE }
var current_state = BattleState.SELECTION

# RIFERIMENTI
@export var player_node: Pokemon
@export var enemy_node: Pokemon
@export var battle_ui: BattleUI # Trascina qui il nodo che ha lo script BattleUI

var player_chosen_move: MoveData

func _ready():
	# Colleghiamo il segnale della UI alla nostra funzione
	if battle_ui:
		battle_ui.move_selected.connect(on_player_selected_move)
	
	await get_tree().create_timer(0.1).timeout
	print("--- BATTAGLIA INIZIATA ---")
	
	start_selection_phase()

# --- FASE 1: SELEZIONE ---
func start_selection_phase():
	current_state = BattleState.SELECTION
	print("Scegli una mossa...")
	# Chiediamo alla UI di accendersi e mostrare le mosse del player
	battle_ui.enable_move_selection(player_node.my_data.current_moves)

# Questa funzione viene chiamata AUTOMATICAMENTE dal segnale della UI
func on_player_selected_move(move_index: int):
	if current_state != BattleState.SELECTION: return
	
	var moves = player_node.my_data.current_moves
	if move_index < moves.size():
		player_chosen_move = moves[move_index]
		
		# Spegniamo la UI mentre si combatte
		battle_ui.disable_ui()
		
		# Passiamo all'azione
		start_turn_resolution()
	else:
		print("Slot vuoto selezionato")

# --- FASE 2: RISOLUZIONE (Logica Pura) ---
func start_turn_resolution():
	current_state = BattleState.EXECUTION
	
	# A. AI
	var enemy_move = decide_ai_move()
	
	# B. Speed Check
	var first: Pokemon
	var second: Pokemon
	var first_move: MoveData
	var second_move: MoveData
	
	var p_speed = player_node.stats.speed
	var e_speed = enemy_node.stats.speed
	
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
	
	# C. Esecuzione
	await execute_attack_sequence(first, second, first_move)
	
	if second.current_hp <= 0:
		handle_faint(second)
		return

	await execute_attack_sequence(second, first, second_move)
	
	if first.current_hp <= 0:
		handle_faint(first)
		return
		
	# D. Fine turno -> Si ricomincia
	start_selection_phase()

# --- ATTACCO ---
func execute_attack_sequence(attacker: Pokemon, defender: Pokemon, move: MoveData):
	print(attacker.stats.name + " usa " + move.name + "!")
	
	# Qui in futuro puoi chiamare battle_ui.show_dialog_text(...)
	await get_tree().create_timer(1.0).timeout
	
	var hit_roll = randi() % 100 + 1
	if hit_roll > move.accuracy:
		print("...ma fallisce!")
	else:
		var damage = calculate_damage(attacker, defender, move)
		defender.take_damage(damage)
	
	await get_tree().create_timer(1.0).timeout

func calculate_damage(attacker: Pokemon, defender: Pokemon, move: MoveData) -> int:
	var atk = float(attacker.stats.attack)
	var def = float(defender.stats.defense)
	var dmg = int((atk / def) * move.power)
	return max(1, dmg)

# --- AI ---
func decide_ai_move() -> MoveData:
	if enemy_node.stats.starting_moves.size() > 0:
		return enemy_node.stats.starting_moves.pick_random()
	return null

# --- FINE BATTAGLIA ---
func handle_faint(pokemon: Pokemon):
	if pokemon == player_node:
		print("Hai perso!")
		current_state = BattleState.LOSE
	else:
		print("Hai vinto!")
		current_state = BattleState.WIN
