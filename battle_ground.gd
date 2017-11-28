# TODO: Zabalit všechno generování do třidy Track, co se o to postará
# TODO: Zajistit, že se konec branche vygeneruje tak, aby mohl tvořit base
# TODO: Zajistit, aby v tracku bylo dost rovných, volných úseků k napojení
# TODO: Get rid of margin
# TODO: Method of track for generating branch
# TODO: Zajisit, že bude vygenerovaná branch validní


extends Node2D

var Track = preload("track.gd")


# Generating
var min_branch = 5  # How long should the branches be at minimum; Putting in 0 breaks things
var margin = 1      # How many nodes from the rim of the grid should be left free
var graph = [       # Graph respresenting relations between rails; Track is generated from it
	[1, 0],
	[2, 0],
	[0, 0]
]


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


# Generating
func get_neighbors(nodes, x, y):
	""" Returns array of positions of neighbors of a node at xy position """
	var neighbors = [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]]
	var result = []
	for neighbor in neighbors:  # Check if neighbors are valid
		if not (neighbor[0] >= nodes.size() or neighbor[1] >= nodes[0].size() or
				neighbor[0] < 0 or neighbor[1] < 0):
			result.append(neighbor)
	return result

func get_max_value_neighbors(nodes, x, y):
	""" Returns array of positions of neighbors of a node at xy; Only those with the highest value are returned """
	var neighbors = get_neighbors(nodes, x, y)
	var max_value = 0
	var result = []
	for neighbor in neighbors:
		var value = nodes[neighbor[0]][neighbor[1]]
		if value > max_value:
			result = [neighbor]
			max_value = value
		elif value == max_value:
			result.append(neighbor)
	return result

func set_neighbor_nodes(nodes, x, y, value):
	""" Sets neighbor nodes values to a value; Ignores nodes with a smaller value """
	for neighbor in get_neighbors(nodes, x, y):
		x = neighbor[0]
		y = neighbor[1]
		if not nodes[x][y] <= value:  # Ignore smaller value nodes
			nodes[x][y] = value

func clear_nodes(nodes):
	""" Clear values (give those nodes 2147483647) in a 2d node array (0 stays) """
	var x = 0
	while x < nodes.size():
		var y = 0
		while y < nodes[0].size():
			if nodes[x][y] != 0:
				nodes[x][y] = 2147483647
			y += 1
		x += 1

func evaluate_nodes(nodes):
	""" Assign values to unoccupied nodes in a 2d node array """
	clear_nodes(nodes)      # If nodes already had some values, it would mess up the evaluation process
	
	var keep_going = true   # This signalizes that there is still work to do
	var solving_value = 0   # The value of nodes whose neighbors we're evaluating
	while keep_going:
		keep_going = false  # If no operation is done this cycle, there is nothing to do
		var x = 0
		while x < nodes.size():
			var y = 0
			while y < nodes[0].size():
				var curr_value = nodes[x][y]
				if curr_value == solving_value:  # Found a node whose neighbors we're evaluating
					set_neighbor_nodes(nodes, x, y, solving_value + 1)
					keep_going = true  # We have done something
				y += 1
			x += 1
		solving_value += 1  

func generate_track(graph, node_count_x, node_count_y):
	""" Generate a track from a graph of rail realtions """
	var rail = []
	
	# Assure it's int
	node_count_x = int(node_count_x)
	node_count_y = int(node_count_y)
	
	# Subtract margin from the count of available nodes
	node_count_x -= (margin * 2) - 1  # We can go all the way right, but not left
	node_count_y -= (margin * 2) - 1  # To put it differently: we can go to max_valueimal x or y but not to 0 x or y
	
	# For storing values of nodes; Exceptions: 0 = occupied, 2147483647 = uninitialized
	var nodes = []
	for i in range(node_count_x):  # Fill nodes array with 2147483647
		var a = []
		for j in range(node_count_y):
			a.append(2147483647)
		nodes.append(a)
	
	# Generate a random position; That will be the rail origin
	var origin_x = (randi() % (node_count_x - 2)) + 1
	var origin_y = (randi() % (node_count_y - 2)) + 1
	
	# Create the base; Either...
	if randi() % 2:  # ...horizontally
		rail.append(Vector2(origin_x - 1, origin_y))
		nodes[origin_x - 1][origin_y] = 0
		# rail.append(Vector2(origin_x, origin_y))
		nodes[origin_x][origin_y] = 0
		rail.append(Vector2(origin_x + 1, origin_y))
		nodes[origin_x + 1][origin_y] = 0
	else:            # ...or vertically
		rail.append(Vector2(origin_x, origin_y - 1))
		nodes[origin_x][origin_y - 1] = 0
		# rail.append(Vector2(origin_x, origin_y))
		nodes[origin_x][origin_y] = 0
		rail.append(Vector2(origin_x, origin_y + 1))
		nodes[origin_x][origin_y + 1] = 0
	
	# Evaluate nodes (+ print the result, pls delet)
	evaluate_nodes(nodes)
	var y = 0
	while y < nodes[0].size():
		var x = 0
		var d = []
		var s = ""
		while x < nodes.size():
			d.append(nodes[x][y])
			s += "%4d "
			x += 1
		print(s % d)
		y += 1
	
	# Grow a branch (testing)
	var curr_node = [rail[1].x, rail[1].y]  # Start with the last node in the base
	var count = 0
	while count < min_branch:
		# Get the neighbors with max value
		var neighbors = get_max_value_neighbors(nodes, curr_node[0], curr_node[1])
		# Choose a random neighbor and add him to the branch
		curr_node = neighbors[randi() % neighbors.size()]
		rail.append(Vector2(curr_node[0], curr_node[1]))
		nodes[curr_node[0]][curr_node[1]] = 0
		# We now continue the cycle again, but on the chosen node
		count += 1
		
	
	# Evaluate nodes (+ print the result, pls delet)
	print("---")
	evaluate_nodes(nodes)
	var y = 0
	while y < nodes[0].size():
		var x = 0
		var d = []
		var s = ""
		while x < nodes.size():
			d.append(nodes[x][y])
			s += "%4d "
			x += 1
		print(s % d)
		y += 1
	
	# Grow a branch (testing)
	var curr_node = [rail[0].x, rail[0].y]  # Start with the last node in the base
	var count = 0
	while count < min_branch:
		# Get the neighbors with max value
		var neighbors = get_max_value_neighbors(nodes, curr_node[0], curr_node[1])
		print(neighbors)
		# Choose a random neighbor and add him to the branch
		curr_node = neighbors[randi() % neighbors.size()]
		rail.insert(0, Vector2(curr_node[0], curr_node[1]))
		nodes[curr_node[0]][curr_node[1]] = 0
		# We now continue the cycle again, but on the chosen node
		count += 1
	
	####
	var count = 0
	while count < rail.size():
		rail[count].x += margin
		rail[count].y += margin
		count += 1
	return [rail]

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
	var node1 = rail[0]
	var node2 = rail[1]
	draw_start(node1, node2, color)
	
	var count = 2  # We'd normally start at one and we've already gone throught one node
	while count < rail.size() - 1:
		node1 = node2
		node2 = rail[count]
		draw_section(node1, node2, color)
		count += 1
		
	var node1 = node2
	var node2 = rail[count]
	draw_end(node1, node2, color)

func draw_track(track):
	for rail in track.rails:
		var color = randi() % colors.size()
		draw_rail(rail, colors[color])
		colors.remove(color) 


# Controll
func _ready():
	randomize()
	
func _draw():
	draw_grid(gap)
	# draw_track(generate_track(graph, 16, 9))
	draw_track(Track(graph, 16, 9))
