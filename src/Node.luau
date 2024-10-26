local Node = {}
Node.__index = Node

function Node.new(size: number, position: Vector3, color: Color3)
	local self = setmetatable({}, Node)

	self.origin = position
	self.size = size
	self.visible = false
	self.children = {}
	self.subdivided = false

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(size, size, size)
	part.Position = self.origin
	part.Locked = true

	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Adornee = part
	selectionBox.Parent = part
	selectionBox.Color3 = color or Color3.fromRGB(255, 255, 255)
	selectionBox.LineThickness = size / 128
	self.part = part

	return self
end

local function numberWithinBoundsInclusive(num: number, min: number, max: number)
	return num >= min and num <= max
end

function Node:containsPoint(point: Vector3)
	local minX = self.origin.X - self.size / 2
	local maxX = self.origin.X + self.size / 2

	local minY = self.origin.Y - self.size / 2
	local maxY = self.origin.Y + self.size / 2

	local minZ = self.origin.Z - self.size / 2
	local maxZ = self.origin.Z + self.size / 2

	local withinXBounds = numberWithinBoundsInclusive(point.X, minX, maxX)
	local withinYBounds = numberWithinBoundsInclusive(point.Y, minY, maxY)
	local withinZBounds = numberWithinBoundsInclusive(point.Z, minZ, maxZ)

	return withinXBounds and withinYBounds and withinZBounds
end

function Node:highlight()
	self.part.SelectionBox.SurfaceTransparency = 0.5
	self.part.SelectionBox.SurfaceColor3 = Color3.fromRGB(0, 255, 0)
end

function Node:resetHighlight()
	self.part.SelectionBox.SurfaceTransparency = 1
end

function Node:show()
	if self.part.Parent == nil then
		self.part.Parent = workspace
	end
	self.visible = true
end

function Node:setPartParent(parent)
	self.part.Parent = parent
end

function Node:find(position: Vector3)
	if not self.subdivided then
		return nil
	end

	local possibleChildren = {}
	for i = 1, 8 do
		if self.children[i]:containsPoint(position) then
			table.insert(possibleChildren, self.children[i])
		end
	end
	return #possibleChildren > 0 and possibleChildren or nil
end

function Node:subdivide()
	if not self.subdivided then
		self.subdivided = true
		local plusMinus = { 1, -1 }
		for i = 1, 2 do
			for j = 1, 2 do
				for k = 1, 2 do
					local childSize = self.size / 2
					local childOrigin = self.origin
						+ Vector3.new(
							plusMinus[i] * self.size / 4,
							plusMinus[j] * self.size / 4,
							plusMinus[k] * self.size / 4
						)
					local childNode = Node.new(childSize, childOrigin)
					childNode:setPartParent(self.part)
					childNode:show()
					table.insert(self.children, childNode)
				end
			end
		end
	else
		for _, child in pairs(self.children) do
			child:subdivide()
		end
	end
end

return Node
