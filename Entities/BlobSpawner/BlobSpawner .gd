extends Node2D


# Nodes references
var tilemap
var tree_tilemap

# Spawner variables
export var spawn_area : Rect2 = Rect2(50, 150, 700, 700)
export var max_blobs = 10
export var start_blobs = 10
var blob_count = 0
var blob_scene = preload("res://Entities/Enemies/Blob.tscn")

# Random number generator
var rng = RandomNumberGenerator.new()

func instance_skeleton():
	# Instance the skeleton scene and add it to the scene tree
	var blob = blob_scene.instance()
	add_child(blob)

	# Place the skeleton in a valid position
	var valid_position = false
	while not valid_position:
		var randx = rng.randf_range(0, 700)
		var randy = rng.randf_range(0, 600)
		blob.position.x = spawn_area.position.x + randx
		blob.position.y = spawn_area.position.y + randy
		var cell_coord = tilemap.world_to_map(position)
		var cell_type_id = tilemap.get_cellv(cell_coord)
		#if cell_type_id == tilemap.tile_set.find_tile_by_name("Grass")):
		valid_position = true
#		var cell_coord = tilemap.world_to_map(position)
#		var cell_type_id = tilemap.get_cellv(cell_coord)
#		var grass_or_sand = (cell_type_id == tilemap.tile_set.find_tile_by_name("Grass")) || (cell_type_id == tilemap.tile_set.find_tile_by_name("Sand"))
#		if grass_or_sand:
		#valid_position = test_position(blob.position)

	# Play skeleton's birth animation


#
#func test_position(position : Vector2):
#	# Check if the cell type in this position is grass or sand
#	var cell_coord = tilemap.world_to_map(position)
#	var cell_type_id = tilemap.get_cellv(cell_coord)
#	var grass_or_sand = (cell_type_id == tilemap.tile_set.find_tile_by_name("Grass")) || (cell_type_id == tilemap.tile_set.find_tile_by_name("Sand"))
#
#	# Check if there's a tree in this position
#	cell_coord = tree_tilemap.world_to_map(position)
#	cell_type_id = tree_tilemap.get_cellv(cell_coord)
#	var no_trees = (cell_type_id != tilemap.tile_set.find_tile_by_name("Tree"))
	
	# If the two conditions are true, the position is valid
#	return grass_or_sand and no_trees
	
	
func _ready():
	# Get tilemaps references
	tilemap = get_tree().root.get_node("Root/TileMap")
	tree_tilemap = get_tree().root.get_node("Root/Tree TileMap")
	
	# Initialize random number generator
	rng.randomize()
	
	# Create skeletons
	for _i in range(start_blobs):
		instance_skeleton()
	blob_count = start_blobs


func _on_Timer_timeout():
	# Every second, check if we need to instantiate a skeleton
	if blob_count < max_blobs:
		instance_skeleton()
		blob_count = blob_count + 1
