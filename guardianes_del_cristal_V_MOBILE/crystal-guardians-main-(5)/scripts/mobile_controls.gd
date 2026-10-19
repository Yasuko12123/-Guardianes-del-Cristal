extends CanvasLayer

@onready var joystick_base: Control = $Controls/JoystickBase
@onready var joystick_knob: Control = $Controls/JoystickBase/JoystickKnob

@export var joystick_radius: float = 65.0
@export var deadzone: float = 0.15

var joystick_direction: Vector2 = Vector2.ZERO
var active_touch_index: int = -1

func _ready() -> void:
	_preparar_interfaz()
	joystick_knob.position = (
		joystick_base.size - joystick_knob.size
	) / 2.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if active_touch_index == -1:
				if is_inside_joystick(event.position):
					active_touch_index = event.index
					update_joystick(event.position)
		elif event.index == active_touch_index:
			active_touch_index = -1
			reset_joystick()
	elif event is InputEventScreenDrag:
		if event.index == active_touch_index:
			update_joystick(event.position)

func is_inside_joystick(screen_position: Vector2) -> bool:
	var centro := joystick_base.global_position + joystick_base.size / 2.0
	return screen_position.distance_to(centro) <= joystick_radius * 1.5

func update_joystick(screen_position: Vector2) -> void:
	var centro := joystick_base.global_position + joystick_base.size / 2.0
	var offset := (screen_position - centro).limit_length(joystick_radius)

	joystick_knob.position = (joystick_base.size - joystick_knob.size) / 2.0 + offset

	joystick_direction = offset / joystick_radius
	if joystick_direction.length() < deadzone:
		joystick_direction = Vector2.ZERO

	_aplicar_movimiento()

func reset_joystick() -> void:
	joystick_direction = Vector2.ZERO
	joystick_knob.position = (joystick_base.size - joystick_knob.size) / 2.0
	_aplicar_movimiento()

# --- Movimiento: se envía a las acciones que usa player.gd ---
func _aplicar_movimiento() -> void:
	_set_accion("move_left", maxf(-joystick_direction.x, 0.0))
	_set_accion("move_right", maxf(joystick_direction.x, 0.0))
	_set_accion("move_up", maxf(-joystick_direction.y, 0.0))
	_set_accion("move_down", maxf(joystick_direction.y, 0.0))

func _set_accion(accion: String, fuerza: float) -> void:
	if fuerza > 0.0:
		Input.action_press(accion, fuerza)
	else:
		Input.action_release(accion)

# --- Ataque e interacción ---
func _preparar_interfaz() -> void:
	var vp := get_viewport().get_visible_rect().size

	# Joystick: base y perilla visibles
	joystick_base.size = Vector2(140, 140)
	joystick_base.position = Vector2(40, vp.y - 180)
	_pintar_circulo(joystick_base, Color(1, 1, 1, 0.25))

	joystick_knob.size = Vector2(60, 60)
	_pintar_circulo(joystick_knob, Color(1, 1, 1, 0.7))

	# Botones táctiles
	_preparar_boton($Controls/AttackButton, "player_attack", "ATACAR",
		Vector2(vp.x - 110, vp.y - 120), Color(1, 0.3, 0.3, 0.6))
	_preparar_boton($Controls/InteractButton, "interact", "E",
		Vector2(vp.x - 230, vp.y - 70), Color(0.3, 0.8, 1, 0.6))

func _pintar_circulo(nodo: Control, color: Color) -> void:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = color
	estilo.set_corner_radius_all(int(nodo.size.x / 2.0))
	var panel := Panel.new()
	panel.size = nodo.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", estilo)
	nodo.add_child(panel)
	nodo.move_child(panel, 0)

func _preparar_boton(boton: TouchScreenButton, accion: String, texto: String,
		pos: Vector2, color: Color) -> void:
	if boton == null:
		return
	var radio := 45.0
	boton.position = pos
	boton.action = accion  # Godot envía la acción solo
	var forma := CircleShape2D.new()
	forma.radius = radio
	boton.shape = forma
	boton.shape_centered = true

	# Aspecto visual
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = color
	estilo.set_corner_radius_all(int(radio))
	var panel := Panel.new()
	panel.size = Vector2(radio * 2, radio * 2)
	panel.position = Vector2(-radio, -radio)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", estilo)
	boton.add_child(panel)

	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.size = panel.size
	etiqueta.position = panel.position
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boton.add_child(etiqueta)
