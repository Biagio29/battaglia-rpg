extends CanvasLayer
class_name BattleUI

# --- SEGNALI ---
# Questo segnale viene "urlato" al Manager quando il giocatore sceglie
signal move_selected(move_index: int)

# --- RIFERIMENTI (Trascina dall'Inspector) ---
@export var moves_container: GridContainer
@export var selection_arrow: TextureRect

# --- VARIABILI INTERNE ---
var move_labels: Array[Label] = []
var current_selection_index: int = 0
var arrow_tween: Tween
var is_active: bool = false # Per bloccare l'input durante le animazioni/attacchi
var valid_moves_count: int = 0 # Nuova variabile per sapere quante mosse vere ci sono

func _ready():
	# Recuperiamo le label dal contenitore
	for child in moves_container.get_children():
		if child is Label:
			move_labels.append(child)
	
	selection_arrow.visible = false

# --- FUNZIONE CHIAMATA DAL MANAGER PER ATTIVARE IL MENU ---
func enable_move_selection(moves: Array[MoveData]):
	is_active = true
	selection_arrow.visible = true
	# Salviamo quante mosse abbiamo per bloccare il cursore dopo
	valid_moves_count = moves.size()

	# Aggiorniamo i testi
	for i in range(move_labels.size()):
		if i < moves.size():
			move_labels[i].text = moves[i].name
		else:
			move_labels[i].text = "-"
	
	# Resettiamo la selezione
	current_selection_index = 0
	update_arrow_position()

# --- FUNZIONE PER DISATTIVARE IL MENU (Mentre attaccano) ---
func disable_ui():
	is_active = false
	selection_arrow.visible = false

# --- GESTIONE INPUT (Navigazione) ---
func _input(event):
	if not is_active:
		return
		
	var grid_columns = moves_container.columns # Dovrebbe essere 2
	var changed = false	
	# DESTRA: Se premo destra AND sono nella colonna pari AND esiste una mossa successiva
	if event.is_action_pressed("ui_right") and current_selection_index % grid_columns == 0 and current_selection_index + 1 < valid_moves_count:
		current_selection_index += 1
		changed = true
				
	# SINISTRA: Se premo sinistra AND sono nella colonna dispari
	elif event.is_action_pressed("ui_left") and current_selection_index % grid_columns != 0:
		current_selection_index -= 1
		changed = true
			
	# GIÙ: Se premo giù AND c'è una mossa valida nella riga sotto
	elif event.is_action_pressed("ui_down") and current_selection_index + grid_columns < valid_moves_count:
		current_selection_index += grid_columns
		changed = true
			
	# SU: Se premo su AND non esco dalla griglia in alto
	elif event.is_action_pressed("ui_up") and current_selection_index - grid_columns >= 0:
		current_selection_index -= grid_columns
		changed = true			
	if changed:
		update_arrow_position()
	
	# CONFERMA SELEZIONE
	if event.is_action_pressed("ui_accept") and current_selection_index < valid_moves_count:
		# Diciamo al Manager: "Hanno scelto la mossa numero X"
		emit_signal("move_selected", current_selection_index)

# --- LOGICA GRAFICA FRECCIA ---
func update_arrow_position():
	if move_labels.size() == 0: return
	
	var selected_label = move_labels[current_selection_index]
	var target_pos = Vector2()
	
	# 1. Centratura Verticale
	var centro_label_y = selected_label.global_position.y + (selected_label.size.y / 2)
	var mezza_altezza_freccia = selection_arrow.size.y / 4
	target_pos.y = centro_label_y - mezza_altezza_freccia - 2
	
	# 2. Posizione Orizzontale (Colonne fisse)
	# ATTENZIONE: Aggiusta questi numeri (50 e 250) usando il Remote Debugger come visto prima
	var col_sinistra_x = 2.5
	var col_destra_x = 107 
	
	# Se l'indice è pari (0, 2) siamo a sinistra. Se dispari (1, 3) a destra.
	if current_selection_index % 2 == 0:
		target_pos.x = col_sinistra_x
	else:
		target_pos.x = col_destra_x
	
	selection_arrow.global_position = target_pos
	start_arrow_animation()

func start_arrow_animation():
	if arrow_tween: arrow_tween.kill()
	arrow_tween = create_tween()
	arrow_tween.set_loops()
	arrow_tween.tween_property(selection_arrow, "position:x", 5.0, 0.5).as_relative().set_trans(Tween.TRANS_SINE)
	arrow_tween.tween_property(selection_arrow, "position:x", -5.0, 0.5).as_relative().set_trans(Tween.TRANS_SINE)