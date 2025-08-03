# File: large_areas.gd
extends Node

var large_areas = [
	{
		"bounds": [Vector2(4, 0), Vector2(5, 1)],
		"center": Vector2(4.5, 0.5),
		"zoom": 0.5
	},
	{
		"bounds": [Vector2(4, 11), Vector2(6, 13)],
		"center": Vector2(5, 12),
		"zoom": .33333
	}
]

func get_large_areas():
	return large_areas
