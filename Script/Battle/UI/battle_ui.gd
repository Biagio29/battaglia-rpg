extends CanvasLayer
class_name BattleUI

# --- SEGNALI ---
signal move_selected(move_index: int)
signal change_selected(move_index: int)

# --- RIFERIMENTI ---
@export var moves_container: GridContainer
@export var selection_arrow: TextureRect
@export var TypeLabel: Label
@export var PPLabel: Label
@export var PlayerNameLabel: Label
@export var EnemyNameLabel: Label
@export var PlayerHealth: Label
@export var PlayerHealthBar: Sprite2D
@export var EnemyHealthBar: Sprite2D
# --- VARIABILI INTERNE ---
var move_labels: Array[Label] = []
var current_selection_index: int = 0
var arrow_tween: Tween
var is_active: bool = false 
var valid_moves_count: int = 0

# Nuove variabili per ricordare i dati
var stored_moves: Array[MoveData] = []
var stored_pp: Dictionary = {}

func _ready():
	for child in moves_container.get_children():
		if child is Label:
			move_labels.append(child)
	
	selection_arrow.visible = false

# --- FUNZIONE DI ATTIVAZIONE ---
# Modificata per accettare anche i PP
func enable_move_selection(moves: Array[MoveData], pp_dict: Dictionary = {}):
	is_active = true
	selection_arrow.visible = true
	
	stored_moves = moves
	stored_pp = pp_dict
	valid_moves_count = moves.size()
	
	# Aggiorniamo i testi e coloriamo di grigio se PP = 0
	for i in range(move_labels.size()):
		if i < moves.size():
			var m_name = moves[i].name
			move_labels[i].text = m_name
			
			# Controllo Visivo PP
			var current_pp = stored_pp.get(m_name, 0)
			if current_pp <= 0:
				move_labels[i].modulate = Color(0.5, 0.5, 0.5) # Grigio
			else:
				move_labels[i].modulate = Color(1, 1, 1) # Bianco normale
				
		else:
			move_labels[i].text = "-"
			move_labels[i].modulate = Color(1, 1, 1)
	
	current_selection_index = 0
	update_arrow_position()

# --- FUNZIONE DI DISATTIVAZIONE ---
func disable_ui():
	is_active = false
	selection_arrow.visible = false

# --- GESTIONE INPUT ---
func _input(event):
	if not is_active:
		return
		
	var grid_columns = moves_container.columns 
	var changed = false
	
	if event.is_action_pressed("ui_right") and current_selection_index % grid_columns == 0 and current_selection_index + 1 < valid_moves_count:
		current_selection_index += 1
		changed = true
				
	elif event.is_action_pressed("ui_left") and current_selection_index % grid_columns != 0:
		current_selection_index -= 1
		changed = true
			
	elif event.is_action_pressed("ui_down") and current_selection_index + grid_columns < valid_moves_count:
		current_selection_index += grid_columns
		changed = true
			
	elif event.is_action_pressed("ui_up") and current_selection_index - grid_columns >= 0:
		current_selection_index -= grid_columns
		changed = true
			
	if changed:
		emit_signal("change_selected", current_selection_index)
		update_arrow_position()
	
	# CONFERMA SELEZIONE
	if event.is_action_pressed("ui_accept") and current_selection_index < valid_moves_count:
		# --- CONTROLLO PP PRIMA DI CONFERMARE ---
		var move_to_check = stored_moves[current_selection_index]
		var pp_available = stored_pp.get(move_to_check.name, 0)
		
		if pp_available > 0:
			emit_signal("move_selected", current_selection_index)
		else:
			# Qui potresti far suonare un "Buzzer" di errore
			print("Impossibile selezionare: PP esauriti!")

# --- LOGICA FRECCIA ---
func update_arrow_position():
	if move_labels.size() == 0: return
	
	var selected_label = move_labels[current_selection_index]
	var target_pos = Vector2()
	
	var centro_label_y = selected_label.global_position.y + (selected_label.size.y / 2)
	var mezza_altezza_freccia = selection_arrow.size.y / 4
	target_pos.y = centro_label_y - mezza_altezza_freccia - 2
	
	var col_sinistra_x = 2.5
	var col_destra_x = 107 
	
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

# --- UI Updates ---
func selct_type(type_name: String):
	if TypeLabel:
		TypeLabel.text = type_name

func select_pp(pp_value: int, max_pp_value: int):
	if PPLabel:
		PPLabel.text = str(pp_value) + "/" + str(max_pp_value)

func selct_name(player_name: String, enemy_name: String):
	if PlayerNameLabel:
		PlayerNameLabel.text = player_name
	if EnemyNameLabel:
		EnemyNameLabel.text = enemy_name

func update_player_health(current_hp: int, max_hp: int):
	if PlayerHealth and PlayerHealthBar:
		PlayerHealth.text = str(current_hp) + "/" + str(max_hp)
		var health_ratio = float(current_hp) / float(max_hp)
		# Faccio diminuire la barra della salute in base al rapporto solo nel lato destro
		PlayerHealthBar.scale.x = health_ratio
		if health_ratio > 0.5:
			PlayerHealthBar.frame = 0 # Verde
		elif health_ratio > 0.2:
			PlayerHealthBar.frame = 1 # Giallo
		else:
			PlayerHealthBar.frame = 2 # Rosso

func update_enemy_health(current_hp: int, max_hp: int):
	if EnemyHealthBar:
		var health_ratio = float(current_hp) / float(max_hp)
		# Faccio diminuire la barra della salute in base al rapporto solo nel lato destro
		EnemyHealthBar.scale.x = health_ratio
		if health_ratio > 0.5:
			EnemyHealthBar.frame = 0 # Verde
		elif health_ratio > 0.2:
			EnemyHealthBar.frame = 1 # Giallo
		else:
			EnemyHealthBar.frame = 2 # Rosso