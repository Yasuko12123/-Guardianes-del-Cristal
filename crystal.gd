extends Area2D
@export var crystal_id: String = ""
var was_collected: bool = false

func _ready() -> void:
	if crystal_id in QuestManager.collected_crystal_ids:
		queue_free()
		return
	
func _on_body_entered(body: Node2D) -> void:
	if was_collected:
		return

	if not body.is_in_group("player"):
		return
	if QuestManager.collect_crystal(crystal_id):
		was_collected = true
		queue_free()
