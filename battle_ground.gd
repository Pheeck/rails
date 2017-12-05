# TODO: Zabalit všechno generování do třidy Track, co se o to postará
# TODO: Zajistit, že se konec branche vygeneruje tak, aby mohl tvořit base
# TODO: Zajistit, aby v tracku bylo dost rovných, volných úseků k napojení
# TODO: Get rid of margin
# TODO: Method of track for generating branch
# TODO: Zajisit, že bude vygenerovaná branch validní


extends Node2D

var Track = preload("track.gd")
var Dijkstra = preload("dijkstra_modified.gd")


# Pregenerated
var track = [
	[
		Vector2(5, 5),
		Vector2(5, 1),
		Vector2(1, 1),
		Vector2(1, 5),
		Vector2(7, 5)
	],
	[
		Vector2(5, 3),
		Vector2(7, 3),
		Vector2(7, 7)
	],
	[
		Vector2(3, 5),
		Vector2(3, 7),
		Vector2(9, 7),
		Vector2(9, 2),
		Vector2(5, 2)
	]
]

# Graphics
var gap = 64
var margin = 1  # Counted in gaps
var track_width = 5.0
var colors = [
	Color(1.0, 0.5, 0.5),  # Red
	Color(1.0, 1.0, 0.5),  # Yellow
	Color(1.0, 0.5, 1.0),  # Purple
	Color(0.5, 1.0, 0.5),  # Green
	Color(0.5, 1.0, 1.0),  # Turqoise
	Color(0.5, 0.5, 1.0)   # Blue
]


# Utility
func reduce_vector(vector):
	if vector.x > 0:
		vector.x = 1
	elif vector.x < 0:
		vector.x = -1
	if vector.y > 0:
		vector.y = 1
	elif vector.y < 0:
		vector.y = -1
	return vector


# Graphics
func draw_grid(gap):
	var screen_size = get_viewport().get_rect().size
	
	var x = 0
	while x < screen_size.x:
		draw_line(Vector2(x, 0), Vector2(x, screen_size.y), Color(0, 0, 0))
		x += gap
		
	var y = 0
	while y < screen_size.y:
		draw_line(Vector2(0, y), Vector2(screen_size.x, y), Color(0, 0, 0))
		y += gap

func draw_section(node1, node2, color):
	node1.x += margin
	node2.x += margin
	node1.y += margin
	node2.y += margin
	draw_line(node1 * gap, node2 * gap, color, track_width)
	
func draw_start(node1, node2, color):
	var difference = node2 - node1
	difference = reduce_vector(difference)
	difference /= 4
	node1 += difference
	draw_section(node1, node2, color)
	
func draw_end(node1, node2, color):
	var difference = node1 - node2
	difference = reduce_vector(difference)
	difference /= 4
	node2 += difference
	draw_section(node1, node2, color)

func draw_rail(rail, color):
	var vectors = rail.get_vectors()
	
	var node1 = vectors[0]
	var node2 = vectors[1]
	draw_start(node1, node2, color)
	
	var count = 2  # We'd normally start at one and we've already gone throught one node
	while count < vectors.size() - 1:
		node1 = node2
		node2 = vectors[count]
		draw_section(node1, node2, color)
		count += 1
		
	var node1 = node2
	var node2 = vectors[count]
	draw_end(node1, node2, color)

func draw_track(track):
	for rail in track.rails:
		var color = randi() % colors.size()
		draw_rail(rail, colors[color])
		colors.remove(color) 


# Controll
func _ready():
	randomize()
	Dijkstra.test()

func _draw():
	draw_grid(gap)
	draw_track(Track.new([], 15, 9))  # TODO: Graph
