extends CanvasLayer

const TIRA := preload("res://assets/ui/44_corazones_vida.png")
const NUM_CORAZONES := 5
const TAMANO_CORAZON := 20
const TAMANO_FUENTE := 14

@onready var health_label: Label = $HUDContainer/HealthPanel/VBoxContainer/HealthLabel
@onready var health_bar: ProgressBar = $HUDContainer/HealthPanel/VBoxContainer/HealthBar
@onready var crystal_label: Label = $HUDContainer/CrystalsPanel/CrystalLabel
@onready var quest_label: Label = $HUDContainer/QuestPanel/QuestLabel

var corazones: Array[TextureRect] = []
var tex_lleno: AtlasTexture
var tex_vacio: AtlasTexture

func _ready() -> void:
	_estilizar_panel($HUDContainer/HealthPanel, Color(0.35, 0.08, 0.12, 0.8))
	_estilizar_panel($HUDContainer/CrystalsPanel, Color(0.08, 0.2, 0.35, 0.8))
	_estilizar_panel($HUDContainer/QuestPanel, Color(0.12, 0.12, 0.2, 0.8))

	_crear_corazones()

	for l in [health_label, crystal_label, quest_label]:
		l.add_theme_font_size_override("font_size", TAMANO_FUENTE)

	if not QuestManager.quest_updated.is_connected(update_quest_info):
		QuestManager.quest_updated.connect(update_quest_info)
	update_quest_info()

	# Conectar con la vida del jugador
	var player := get_tree().get_first_node_in_group("player")
	if player and not player.health_changed.is_connected(update_health):
		player.health_changed.connect(update_health)
		update_health(player.health, player.max_health)

func _estilizar_panel(panel: Control, color: Color) -> void:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = color
	estilo.border_color = Color(0.95, 0.85, 0.45)
	estilo.set_border_width_all(1)
	estilo.set_corner_radius_all(8)
	estilo.set_content_margin_all(5)
	panel.add_theme_stylebox_override("panel", estilo)

func _crear_corazones() -> void:
	tex_lleno = AtlasTexture.new()
	tex_lleno.atlas = TIRA
	tex_lleno.region = Rect2(7, 0, 27, 27)
	tex_vacio = AtlasTexture.new()
	tex_vacio.atlas = TIRA
	tex_vacio.region = Rect2(141, 0, 27, 27)

	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 2)
	var padre := health_bar.get_parent()
	padre.add_child(fila)
	padre.move_child(fila, health_bar.get_index())
	health_bar.visible = false

	for i in NUM_CORAZONES:
		var t := TextureRect.new()
		t.texture = tex_lleno
		t.custom_minimum_size = Vector2(TAMANO_CORAZON, TAMANO_CORAZON)
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		fila.add_child(t)
		corazones.append(t)

func update_health(current: int, maximo: int) -> void:
	var llenos := ceili(float(current) / float(maximo) * NUM_CORAZONES)
	for i in NUM_CORAZONES:
		corazones[i].texture = tex_lleno if i < llenos else tex_vacio
	health_label.text = "VIDA: %d%%" % int(float(current) / float(maximo) * 100.0)

func update_quest_info() -> void:
	crystal_label.text = "CRISTALES: %d/%d" % [
		QuestManager.collected_crystals,
		QuestManager.required_crystals
	]
	match QuestManager.quest_state:
		QuestManager.QuestState.NOT_STARTED:
			quest_label.text = "MISION: Habla con Han Solo"
		QuestManager.QuestState.ACTIVE:
			quest_label.text = "MISION: Recolectar los cristales"
		QuestManager.QuestState.READY_TO_DELIVER:
			quest_label.text = "MISION: Entrega los cristales a Han Solo"
		QuestManager.QuestState.COMPLETED:
			quest_label.text = "MISION COMPLETADA"
