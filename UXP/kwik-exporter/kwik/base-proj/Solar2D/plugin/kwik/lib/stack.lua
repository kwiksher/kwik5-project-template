------------
-- Locals -- 
------------

local Stack = {}
local Stack_mt = { __index = Stack }

-----------------
-- Constructor --
-----------------

function Stack.new(  )
	local Stack = {}

	return setmetatable( Stack, Stack_mt )
end

-------------
-- Methods -- 
-------------

function Stack:print()
	local string = "["
	for i=1, #self do
		string = string .. self[i]
		if (i ~= #self) then
			string = string .. ", "
		end
	end
	string = string .. "]"
	print( string )
end

function Stack:push( a )
	self[#self + 1] = a
	return a
end

function Stack:pop()
	return table.remove( self )
end

function Stack:length(  )
	return #self
end

function Stack:clear( )
	for i=1, #self do
		self:pop()
	end
end

return Stack