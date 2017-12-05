# -- Member variables --

const MAX_INT = 2147483647


# -- Methods --

static func filled_array(value, lenght):
	""" Returns an array with a specific lenght filled with a value """
	var result = []
	
	var count = 0
	while count < lenght:
		result.append(value)
		count += 1
	
	return result

static func smallest_not_definitive(values, definitive):
	""" Returns the number of the smallest not definitive vertex """
	var result
	
	var smallest = MAX_INT
	var count = 0
	while count < values.size():
		if not definitive[count]:
			var value = values[count]
			if value < smallest:
				result = count
				smallest = value
		count += 1
	
	return result

static func dijkstra(graph, weights, start, end):
	""" Find the shortest path between two vertices in a graph """
	# Create an array for storing vertex values
	var values = filled_array(MAX_INT, graph.size())
	values[start] = 0  # Set the starting vertex to 0
	
	# Create an array for indicating that a vertex is definitive
	var definitive = filled_array(false, graph.size())
	
	# Create an array for storing the best paths to vertices
	var paths = filled_array([], graph.size())
	
	# Repeat until the end vertext is definitive
	while not definitive[end]:
		# Get the vertex with the smallest value from those, that are not definitive
		var w = smallest_not_definitive(values, definitive)
		
		# Set it as definitive
		definitive[w] = true
		
		# Test if there is a better path to some v vertex through w vertex
		var count = 0
		while count < graph[w].size():
			# Get one of the neighbor vertices and it's potential value
			var v = graph[w][count]
			var new_value = values[w] + weights[w][count]
			
			# If the potential (new) value is smaller than the v verex's current value
			if new_value < values[v]:
				# Set its value to the new value and its path to a new path
				values[v] = new_value
				paths[v] = paths[w] + [v]  # It's the path to the w vertex + [v]
			
			count += 1
	
	return paths[end]

static func test():
	var graph = [
	    [1, 4],
	    [2, 3],
	    [4, 5],
	    [5],
	    [5],
	    []
	]
	var weights = [
	    [3, 4],
	    [2, 1],
	    [1, 5],
	    [8],
	    [6],
	    []
	]
	print(dijkstra(graph, weights, 0, 5))

yy