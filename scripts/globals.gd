extends Node;

var player: CharacterBody3D;
var world: Node3D;

var map_data: Array[ Variant ] = JSON.parse_string("""
[
	{
		"type": "player",
		"name": "player",
		"position": {
			"x": 0,
			"y": 1,
			"z": 0
		},
		"rotation": {
			"x": 0,
			"y": 0,
			"z": 0
		}
	},
	{
		"type": "button",
		"name": "button-1",
		"position": {
			"x": -2,
			"y": 0,
			"z": 0
		},
		"rotation": {
			"x": 0,
			"y": 0,
			"z": 0
		}
	},
	{
		"type": "blockade",
		"name": "blockade-1",
		"activator": "button-1",
		"position": {
			"x": 2,
			"y": 0,
			"z": 0
		},
		"rotation": {
			"x": 0,
			"y": 0,
			"z": 0
		}
	}
]
""");
