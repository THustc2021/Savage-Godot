extends Node

class_name Set

@onready var data
var current = 0

func _init(l=null):
	if l != null:
		self.data = l
	else:
		self.data = []

func add(e):
	if e not in self.data:
		self.data.append(e)
		
func extend(el):
	for e in el:
		self.add(e)

func iter():
	return self.data
