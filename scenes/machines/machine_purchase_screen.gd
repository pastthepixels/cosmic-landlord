extends ColorRect

signal request_destroy

signal request_purchase

var label_scene = preload("res://scenes/machines/m_p_s_label.tscn")

func _ready():
	update_purchase_labels()

func _on_back_pressed():
	hide()

func update_purchase_labels():
	for machine in $Machines.get_children():
		var label = label_scene.instantiate()
		label.set_stats(machine)
		label.name = machine.name
		label.set_purchasable()
		
		label.connect("request_purchase", _on_label_request_purchase)
		$%PurchaseLabels.add_child(label)

func update_labels(machines):
	# Updates/adds existing nodes
	for machine in machines:
		if has_node("%Labels" + ("/%s" % machine.name)):
			get_node("%Labels" + ("/%s" % machine.name)).set_stats(machine)
		else:
			var label = label_scene.instantiate()
			label.set_stats(machine)
			label.name = machine.name
			label.connect("request_destroy", _on_label_request_destroy)
			$%Labels.add_child(label)
	# Removes orphaned nodes
	for label in $%Labels.get_children():
		var machine_exists = false
		for machine in machines:
			if label.name == machine.name:
					machine_exists = true
		if machine_exists == false:
			label.queue_free()
	# Updates purchasing labels
	for label in $%PurchaseLabels.get_children():
		# TODO: get_parent() is planet but will it always?
		label.machine._price_multiplier = get_parent().price_multiplier
		label.set_stats(label.machine)

func _on_label_request_destroy(machine):
	emit_signal("request_destroy", machine)

func _on_label_request_purchase(machine):
	emit_signal("request_purchase", machine)

func _on_purchase_back_pressed():
	$CurrentMachines.show()
	$PurchaseMachines.hide()
	_on_back_pressed()

func _on_purchase_pressed():
	$CurrentMachines.hide()
	$PurchaseMachines.show()
