extends Control

@export var health_changed_label : PackedScene

func _ready():
	SignalBus.connect("_on_health_changed", _on_signal_health_changed)

func _on_signal_health_changed(node : Node, amount_changed : int):
	var label_instance : Label = health_changed_label.instantiate()
	node.add_child(label_instance)
	label_instance.text = str(amount_changed)
