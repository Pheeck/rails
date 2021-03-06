# -- Member variables --

const MAX_INT = 2147483647

var min_branch = 5  # How long should the branches be at minimum; Putting in 0 breaks things
var graph = [       # Graph respresenting relations between rails; Track is generated from it
	[1, 0],
	[2, 0],
	[0, 0]
]
var nodes = []      # For storing values of nodes; Exceptions: 0 = occupied, MAX_INT = uninitialized
var rails = []      # For storing individual rail objects; TODO: Maybe define get method


# -- Functions -- 

func _init(graph, node_count_x, node_count_y):
	""" Constructor """
	node_count_x = int(node_count_x)
	node_count_y = int(node_count_y)
	
	# Fill nodes array with MAX_INT
	for i in range(node_count_x):
		var a = []
		for j in range(node_count_y):
			a.append(MAX_INT)
		nodes.append(a)
	
	# Create rail (testing)
	rails.append(Rail.new(self))

func get_neighbors(pos_x, pos_y):
	""" Returns array of positions of neighbors of a node at pos position """
	# Generate neighbor positions 
	var neighbors = [
		[pos_x - 1, pos_y],
		[pos_x + 1, pos_y],
		[pos_x, pos_y - 1],
		[pos_x, pos_y + 1]
	]
	
	# Check if neighbors are valid - if they aren't outside of node array
	var result = []
	for neighbor in neighbors:
		if not (neighbor[0] >= nodes.size() or neighbor[1] >= nodes[0].size() or
				neighbor[0] < 0 or neighbor[1] < 0):
			result.append(neighbor)
	
	# Return the valid neighbors
	return result

func get_max_value_neighbors(pos_x, pos_y):
	""" Returns array of positions of neighbors of a node at pos_x, pos_y; Only those with the highest value are returned """
	var neighbors = get_neighbors(pos_x, pos_y)
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

func set_neighbor_nodes(pos_x, pos_y, value):
	""" Sets neighbor nodes values to a value; Ignores nodes with a smaller value """
	for neighbor in get_neighbors(pos_x, pos_y):
		var x = neighbor[0]
		var y = neighbor[1]
		if not nodes[x][y] <= value:  # Ignore smaller value nodes
			nodes[x][y] = value

func clear_nodes():
	""" Clear values (give those nodes MAX_INT) in a nodes (0 stays) """
	var x = 0
	while x < nodes.size():
		var y = 0
		while y < nodes[0].size():
			if nodes[x][y] != 0:
				nodes[x][y] = MAX_INT
			y += 1
		x += 1

func evaluate_nodes():
	""" Assign values to unoccupied nodes in nodes array """
	clear_nodes()           # If nodes already had some values, it would mess up the evaluation process
	
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
					set_neighbor_nodes(x, y, solving_value + 1)
					keep_going = true  # We have done something
				y += 1
			x += 1
		solving_value += 1


# -- Inner classes --

class Rail:
	var track      # Reference to the outer track object; Workaround for GDScript not providing outer object reference to inner object
	var path = []  # For storing nodes of the rail (their [x, y])
	
	func _init(track):
		""" Constructor """
		self.track = track
		
		# Generate a random position; That will be the path origin
		var origin_x = (randi() % (track.nodes.size() - 2)) + 1  # We generate the position so that the origin can't be on the edge of nodes array
		var origin_y = (randi() % (track.nodes[0].size() - 2)) + 1
		
		# Create the base; Either...
		if randi() % 2:  # ...horizontally
			path.append([origin_x - 1, origin_y])
			track.nodes[origin_x - 1][origin_y] = 0
			# path.append([origin_x, origin_y]) is not needed
			track.nodes[origin_x][origin_y] = 0
			path.append([origin_x + 1, origin_y])
			track.nodes[origin_x + 1][origin_y] = 0
		else:            # ...or vertically
			path.append([origin_x, origin_y - 1])
			track.nodes[origin_x][origin_y - 1] = 0
			# path.append([origin_x, origin_y]) is not needed
			track.nodes[origin_x][origin_y] = 0
			path.append([origin_x, origin_y + 1])
			track.nodes[origin_x][origin_y + 1] = 0
			
		# Grow branches from each side
		var new_branch = grow_branch(path[1][0], path[1][1])
		path = path + new_branch  # From the back
		new_branch = grow_branch(path[0][0], path[0][1])
		new_branch.invert()       # We need to connect it to the path by the node it grew from
		path = new_branch + path  # From the front
	
	func grow_branch(start_x, start_y):  # TODO: More different types of growing; Anticipating bad branches
		""" Grows a branch and returns its path """
		var result = []
		
		# We will be using node valus -> we need to evaluate them first
		track.evaluate_nodes()
		
		# Start with the starting node
		var curr_node = [start_x, start_y]
		
		# This type of growing is not ideal - TODO: Different growing
		# The branch grows a section every cycle
		var count = 0
		while count < track.min_branch:
			# Get the neighbors with max value
			var neighbors = track.get_max_value_neighbors(curr_node[0], curr_node[1])
			
			# Choose a random neighbor and add him to the branch
			curr_node = neighbors[randi() % neighbors.size()]
			result.append([curr_node[0], curr_node[1]])
			track.nodes[curr_node[0]][curr_node[1]] = 0
			
			# We now continue the cycle again, but on the chosen node
			count += 1
		
		return result
	
	func get_vectors():
		""" Return this track's path with nodes converted to Vector2s """
		var result = []
		
		for node in path:
			var new_vector = Vector2(node[0], node[1])
			result.append(new_vector)
			
		return result
