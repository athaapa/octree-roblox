local Node = require(script.Node)

local Octree = {}
Octree.__index = Octree

local CHUNK_RESOLUTION = 10
local SCALE = 1
local BASEPLATE_HEIGHT = 16

function Octree.new(divisions: number)
	-- // Detemine size based on chunk resolution
	local size = 1024 / 2
	local rootNode = Node.new(size, Vector3.new(0, size / 2 + BASEPLATE_HEIGHT / 2, 0))
	rootNode:show()

	for i = 1, divisions do
		rootNode:subdivide()
	end

	local self = setmetatable({}, Octree)
	self.rootNode = rootNode
	self.highlightedNodes = {}
	return self
end

function Octree:_query(nodesToCheck, position: Vector3)
	if not nodesToCheck then
		return nil
	end

	local container = {}
	for _, node in pairs(nodesToCheck) do
		local containedNodes = node:find(position)
		if containedNodes then
			for _, containedNode in pairs(containedNodes) do
				table.insert(container, containedNode)
			end
		end
	end

	if #container > 0 then
		return self:_query(container, position)
	else
		return nodesToCheck
	end
end

function Octree:resetHighlights()
	for _, node in pairs(self.highlightedNodes) do
		node:resetHighlight()
	end
	table.clear(self.highlightedNodes)
end

function Octree:highlight(nodes: {})
	for _, node in pairs(nodes) do
		node:highlight()
		table.insert(self.highlightedNodes, node)
	end
end

function Octree:query(position: Vector3)
	return self:_query({ self.rootNode }, position)
end

return Octree
