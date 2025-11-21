extends Node2D

enum BattleState { SELECTION, EXECUTION, WIN, LOSE }
var current_state = BattleState.SELECTION

# RIFERIMENTI
@export var player_node: Pokemon
@export var enemy_node: Pokemon
@export var battle_ui: BattleUI 

var player_chosen_move: MoveData

# Registro temporaneo per i PP del nemico
var enemy_battle_pp: Dictionary = {}

func _ready():
	if battle_ui:
		if not battle_ui.move_selected.is_connected(on_player_selected_move):
			battle_ui.move_selected.connect(on_player_selected_move)
		if not battle_ui.change_selected.is_connected(on_move_changed):
			battle_ui.change_selected.connect(on_move_changed)
	# --- INIZIALIZZA I NOMI NELLA UI ---
	if player_node and player_node.my_data:
		var player_name = player_node.my_data.nickname if player_node.my_data.nickname != "" else player_node.stats.name
		var enemy_name = enemy_node.stats.name
		battle_ui.selct_name(player_name, enemy_name)
	# --- INIZIALIZZA LA SALUTE DEL GIOCATORE NELLA UI ---
		if player_node.my_data:
			battle_ui.update_player_health(player_node.my_data.current_hp, player_node.my_data.max_hp)
	# --- INIZIALIZZA I PP DEL NEMICO ---
	enemy_battle_pp.clear()
	if enemy_node and enemy_node.stats:
		for move in enemy_node.stats.starting_moves:
			enemy_battle_pp[move.name] = move.max_pp
	
	await get_tree().create_timer(0.1).timeout
	
	if player_node.my_data and player_node.my_data.current_moves.size() > 0:
		on_move_changed(0) 
		
	print("--- BATTAGLIA INIZIATA ---")
	start_selection_phase()

# --- FASE 1: SELEZIONE ---
func start_selection_phase():
	current_state = BattleState.SELECTION
	print("Scegli una mossa...")

	# MODIFICA QUI: Passiamo anche i PP attuali alla UI
	battle_ui.enable_move_selection(player_node.my_data.current_moves, player_node.my_data.current_moves_pp)
	if player_node.my_data and player_node.my_data.current_moves.size() > 0:
		on_move_changed(0) 

# Questa funzione viene chiamata AUTOMATICAMENTE dal segnale della UI
func on_player_selected_move(move_index: int):
	if current_state != BattleState.SELECTION: return
	var moves = player_node.my_data.current_moves
	
	if move_index < moves.size():
		var selected_move = moves[move_index]
		# Aggiorna tipo
		var move_type_position = moves[move_index].move_type
		var move_type_name = ""
		if GameManager.Type.keys().size() > move_type_position:
			move_type_name = GameManager.Type.keys()[move_type_position]
		battle_ui.selct_type(move_type_name)
		
		# CONTROLLO PP GIOCATORE (Doppia sicurezza, anche se la UI blocca)
		var move_name = selected_move.name
		var current_pp = player_node.my_data.current_moves_pp.get(move_name, 0)
		
		if current_pp > 0:
			player_chosen_move = selected_move
			
			# Consumiamo 1 PP
			player_node.my_data.current_moves_pp[move_name] = current_pp - 1
			battle_ui.select_pp(current_pp - 1, selected_move.max_pp)
			battle_ui.disable_ui()
			start_turn_resolution()
		else:
			print("Non hai abbastanza PP per questa mossa!")
	else:
		print("Slot vuoto selezionato")

# --- FASE 2: RISOLUZIONE ---
func start_turn_resolution():
	current_state = BattleState.EXECUTION
	
	var enemy_move = decide_ai_move()
	
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
	
	if first_move:
		await execute_attack_sequence(first, second, first_move)
		if second.current_hp <= 0:
			handle_faint(second)
			return

	if second_move:
		await execute_attack_sequence(second, first, second_move)
		if first.current_hp <= 0:
			handle_faint(first)
			return
		
	start_selection_phase()

# --- ATTACCO ---
func execute_attack_sequence(attacker: Pokemon, defender: Pokemon, move: MoveData):
	print(attacker.stats.name + " usa " + move.name + "!")
	
	await get_tree().create_timer(1.0).timeout
	
	var hit_roll = randi() % 100 + 1
	if hit_roll > move.accuracy:
		print("...ma fallisce!")
	else:
		var damage = calculate_damage(attacker, defender, move)
		defender.take_damage(damage)
		# AGGIORNA LA SALUTE DEL GIOCATORE NELLA UI SE IL GIOCATORE È STATO COLPITO
		if defender == player_node and player_node.my_data:
			battle_ui.update_player_health(player_node.my_data.current_hp, player_node.my_data.max_hp)
		else:
			battle_ui.update_enemy_health(enemy_node.current_hp, enemy_node.stats.max_hp)
	
	await get_tree().create_timer(1.0).timeout

func calculate_damage(attacker: Pokemon, defender: Pokemon, move: MoveData) -> int:
	var atk = float(attacker.stats.attack)
	var def = float(defender.stats.defense)
	var dmg = int((atk / def) * move.power)
	return max(1, dmg)

# --- AI INTELLIGENTE ---
func decide_ai_move() -> MoveData:
	var all_moves = enemy_node.stats.starting_moves
	var valid_moves: Array[MoveData] = []
	
	for move in all_moves:
		var pp = enemy_battle_pp.get(move.name, 0)
		if pp > 0:
			valid_moves.append(move)
	
	if valid_moves.size() > 0:
		var selected = valid_moves.pick_random()
		enemy_battle_pp[selected.name] -= 1
		print("Nemico usa " + selected.name + " (PP rimasti: " + str(enemy_battle_pp[selected.name]) + ")")
		return selected
	else:
		print("Il nemico non ha più PP! (Usa Scontro/Struggle)")
		return null

# --- FINE BATTAGLIA ---
func handle_faint(pokemon: Pokemon):
	if pokemon == player_node:
		print("Hai perso!")
		current_state = BattleState.LOSE
	else:
		print("Hai vinto!")
		current_state = BattleState.WIN

# --- GESTIONE UI CAMBIO SELEZIONE ---
func on_move_changed(move_index: int):
	if current_state != BattleState.SELECTION: return
	
	var moves = player_node.my_data.current_moves
	if move_index < moves.size():

		# Aggiorna tipo
		var move_type_position = moves[move_index].move_type
		var move_type_name = ""
		if GameManager.Type.keys().size() > move_type_position:
			move_type_name = GameManager.Type.keys()[move_type_position]
		
		# Aggiorna PP
		var move_name = moves[move_index].name
		var pp_value = player_node.my_data.current_moves_pp.get(move_name, 0)
		var max_pp_value = moves[move_index].max_pp
		
		# Aggiorna UI
		battle_ui.select_pp(pp_value, max_pp_value)
		battle_ui.selct_type(move_type_name)
