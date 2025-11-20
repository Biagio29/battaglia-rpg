extends Resource

class_name MoveData
# Queste variabili appariranno nell'Inspector di Godot
@export var name: String = "Azione"
@export var power: int = 40
@export var accuracy: int = 100  # Percentuale 0-100
@export_enum("Fisico", "Speciale") var category: String = "Fisico"
@export var description: String = ""