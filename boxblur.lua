--[[
The MIT License (MIT)

Copyright (c) 2015 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

return {
requires = {'canvas', 'shader'},
description = "Box blur shader with support for different horizontal and vertical blur size",

new = function(self)
	self.radius_h, self.radius_v = 3, 3
	self.canvas_h, self.canvas_v = love.graphics.newCanvas(), love.graphics.newCanvas()
	self.shader = love.graphics.newShader[[
		extern vec2 direction = vec2(1.0f, 0.0f);
		extern number radius;
		vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _)
		{
			vec4 c = vec4(0.0f);

			for (float i = -radius; i <= radius; i += 1)
			{
				c += Texel(texture, tc + i * direction);
			}
			return c / (2.0f * radius + 1.0f) * color;
		}
	]]
end,

draw = function(self, func)
	local c = love.graphics.getCanvas()
	local s = love.graphics.getShader()
	local co = {love.graphics.getColor()}

	-- draw scene
	self.canvas_h:clear()
	self.canvas_h:renderTo(func)

	love.graphics.setColor(co)
	love.graphics.setShader(self.shader)

	local b = love.graphics.getBlendMode()
	love.graphics.setBlendMode('premultiplied')

	-- first pass (horizontal blur)
	self.shader:send('direction', {1 / love.graphics.getWidth(), 0})
	self.shader:send('radius', math.floor(self.radius_h + .5))
	self.canvas_v:clear()
	self.canvas_v:renderTo(function() love.graphics.draw(self.canvas_h, 0,0) end)

	-- second pass (vertical blur)
	self.shader:send('direction', {0, 1 / love.graphics.getHeight()})
	self.shader:send('radius', math.floor(self.radius_v + .5))
	love.graphics.draw(self.canvas_v, 0,0)

	-- restore blendmode, shader and canvas
	love.graphics.setBlendMode(b)
	love.graphics.setShader(s)
	love.graphics.setCanvas(c)
end,

set = function(self, key, value)
	local sz = math.floor(assert(tonumber(value), "Not a number: "..tostring(value)) + .5)
	if key == "radius" then
		self.radius_h, self.radius_v = sz, sz
	elseif key == "radius_h" or key == "radius_v" then
		self[key] = sz
	else
		error("Unknown property: " .. tostring(key))
	end
	return self
end
}
