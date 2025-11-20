extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func _process(_delta: float) -> void:
    pass # Replace with function body.

func execute_turn(attacker: Pokemon, defender: Pokemon, move: MoveData):
    print(attacker.stats.name + " usa " + move.name + "!")

    # 1. CALCOLO PRECISIONE (Hit or Miss)
    # Generiamo un numero casuale tra 0 e 100
    var hit_roll = randi() % 101

    # Se il numero è più alto della precisione della mossa, abbiamo mancato
    if hit_roll > move.accuracy:
        print("...ma ha fallito!")
        return # Esce dalla funzione, niente danno

    # 2. CALCOLO DEL DANNO (Formula classica semplificata)
        # Formula: (Attacco / Difesa) * Potenza della mossa
        # Usiamo float() per non perdere i decimali durante la divisione
    var damage_multiplier = float(attacker.stats.attack) / float(defender.stats.defense)
    var final_damage = int(damage_multiplier * move.power)

    # Aggiungiamo un minimo di 1 danno per evitare attacchi nulli
    final_damage = max(1, final_damage)

    # 3. APPLICAZIONE DANNO
    defender.take_damage(final_damage)
