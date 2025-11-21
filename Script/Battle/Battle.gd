extends Node2D


var grafic_start_path = "res://Assets/Sprite/battleEnvirorment/"
var grafic_player_platform_end_path = "_base0.png"
var grafic_enemy_platform_end_path = "_base1.png"
var grafic_bg_end_path = "_bg.png"

func _ready() -> void:
	set_grafic()


func set_grafic():
	var str_bioma: String = GameManager.Bioma.keys()[GameManager.current_biome]
	$Platforms/Plat_player.texture = load(grafic_start_path + str_bioma + grafic_player_platform_end_path)
	$Platforms/Plat_enemy.texture = load(grafic_start_path + str_bioma + grafic_enemy_platform_end_path)
	$Background.texture = load(grafic_start_path + str_bioma + grafic_bg_end_path)
