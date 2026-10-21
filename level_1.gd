extends Node2D

var crystals_collected: int = 0
var total_crystals: int = 0

@onready var player = $player
@onready var game_hud = $GameHUD
var crystal_label: Label = null

func _ready() -> void:
	# Buscamos la etiqueta de forma segura dentro del HUD
	crystal_label = $GameHUD.get_node_or_null("CrystalsPanel/CrystalLabel") as Label
	
	var crystals := $crystals.get_children()
	total_crystals = crystals.size()
	
	# Conectar cada cristal de manera limpia y segura
	for crystal in crystals:
		if crystal.has_signal("body_entered"):
			if not crystal.body_entered.is_connected(_on_any_crystal_body_entered.bind(crystal)):
				crystal.body_entered.connect(_on_any_crystal_body_entered.bind(crystal))

	player.health_changed.connect(game_hud.update_health)
	game_hud.update_health(player.health, player.max_health)
	
	QuestManager.reset_quest()
	restore_saved_game.call_deferred()
	
	# Actualizamos el texto inicial en pantalla
	update_crystal_label()

# Función receptora que maneja el toque de cualquier cristal
func _on_any_crystal_body_entered(body: Node2D, crystal_node: Node2D) -> void:
	if body == player:
		crystals_collected += 1
		update_crystal_label()
		crystal_node.queue_free() # Elimina el cristal específico que fue tocado
		
		if crystals_collected >= total_crystals:
			print("¡Todos los cristales recolectados en el nivel 2!")

func update_crystal_label() -> void:
	if crystal_label:
		crystal_label.text = "CRISTALES: %d / %d" % [
			crystals_collected,
			total_crystals
		]

func save_current_game() -> void:
	var current_level: String = scene_file_path
	SaveManager.save_game(
		player,
		current_level
	)

func restore_saved_game() -> void:
	SaveManager.apply_saved_data(player)
