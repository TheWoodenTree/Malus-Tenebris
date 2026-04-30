extends Node

enum ID {
	NONE = 0,
	RUBOLEUM_VIAL = 1,
	BANDAGE = 2,
	HOURGLASS = 3,
	JOURNAL = 4,
	WINCH_CRANK = 5,
	BEEF_FAT = 6,
	CELL_HALL_KEY = 7,
	SUMP_TUNNELS_KEY = 8,
	LARDER_KEY = 9,
}

var item_data_resources: Dictionary[ItemRegistry.ID, Resource]

func _ready() -> void:
	item_data_resources = {
		ItemRegistry.ID.NONE: null,
		ItemRegistry.ID.RUBOLEUM_VIAL: preload("uid://dq2xpjjilobj"),
		ItemRegistry.ID.BANDAGE: preload("uid://d26ds3d235e2e"),
		ItemRegistry.ID.HOURGLASS: preload("uid://binua2vubahmw"),
		ItemRegistry.ID.JOURNAL: preload("uid://bqtcwaf610b65"),
		ItemRegistry.ID.WINCH_CRANK: preload("uid://8ou378eo38r2"),
		ItemRegistry.ID.BEEF_FAT: preload("uid://bm4qj337mcios"),
		ItemRegistry.ID.CELL_HALL_KEY: preload("uid://c8opu2jmkysqx"),
		ItemRegistry.ID.SUMP_TUNNELS_KEY: preload("uid://ddwrs221n0xxx"),
		ItemRegistry.ID.LARDER_KEY: preload("uid://bqar0bonuyvsp"),
	}
