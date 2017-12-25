local bit = require("bit")
local band = bit.band
local shl = bit.lshift

minetest.register_node("test_lighting:white", {
	description = "White solid node",
	tiles = {"test_lighting_white.png"},
})

minetest.register_node("test_lighting:white_box", {
	description = "White transparent node",
	tiles = {"test_lighting_white.png"},
	drawtype = "nodebox",
	paramtype = "light",
})

local function sel(param, bit, off, on)
	if band(param, shl(1, bit)) == 0 then
		return off
	else
		return on
	end
end

minetest.register_chatcommand("testlight", {
	params = "[]",
	description = "Create light test",
--	privs = {talk = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		local b = vector.round(player:getpos())
		local vm = VoxelManip()
		local e1, e2 = vm:read_from_map({x=b.x, y=b.y, z=b.z}, {x=b.x+48, y=b.y+2, z=b.z+48})
		local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
		local c_solid = minetest.get_content_id("test_lighting:white")
		local c_node = minetest.get_content_id("test_lighting:white_box")
		local c_air = minetest.get_content_id("air")
		local data = vm:get_data()
		local y = b.y
		for i = 0, 16 do
			for j = 0, 16 do
				local x = b.x + 3 * i
				local z = b.z + 3 * j
				data[area:index(x, y, z)] = sel(i, 0, c_node, c_solid)
				data[area:index(x+1, y, z)] = sel(i, 1, c_air, c_solid)
				data[area:index(x, y, z+1)] = sel(i, 2, c_air, c_solid)
				data[area:index(x+1, y, z+1)] = sel(i, 3, c_air, c_solid)
				data[area:index(x, y+1, z)] = sel(j, 0, c_air, c_solid)
				data[area:index(x+1, y+1, z)] = sel(j, 1, c_air, c_solid)
				data[area:index(x, y+1, z+1)] = sel(j, 2, c_air, c_solid)
				data[area:index(x+1, y+1, z+1)] = sel(j, 3, c_air, c_solid)
			end
		end
--		print(dump(data))
		vm:set_data(data)
		vm:write_to_map()
		return true, "Done."
	end,
})

minetest.register_chatcommand("messit", {
	params = "[]",
	description = "Mess up everything around",
--	privs = {talk = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		local b = vector.round(player:getpos())
		local vm = VoxelManip()
		local r = 16
		local e1, e2 = vm:read_from_map({x=b.x-r, y=b.y-1, z=b.z-r}, {x=b.x+r, y=b.y+1, z=b.z+r})
		local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
		local c_stone = minetest.get_content_id("test_lighting:white")
		local c_air = minetest.get_content_id("air")
		local c_ignore = minetest.get_content_id("ignore")
		local c_rail = minetest.get_content_id("rail")
		local data = vm:get_data()
		local param1 = vm:get_light_data()
		local param2 = vm:get_param2_data()
		local y = b.y
		for x = b.x - r, b.x + r do
			for z = b.z - r, b.z + r do
				local l = 0
				if param == "smooth" then
					l = math.random(0, 15)
					l = 0x11 * l
				elseif math.random() < 0.5 then
					l = 0xff
				end
				local b = c_stone
				local c = c_air
				if param == "rail" then
					c = c_rail
				elseif param == "ignore" and math.random() < 0.5 then
					c = c_ignore
				end
				local i = area:index(x, y-1, z)
				local j = area:index(x, y, z)
				local k = area:index(x, y+1, z)
				data[i] = c_stone
				data[j] = c
				data[k] = c_air
				param1[i] = 0
				param1[j] = l
				param1[k] = 0xffff
				param2[i] = 0
				param2[j] = 0
				param2[k] = 0
			end
		end
		vm:set_data(data)
		vm:set_light_data(param1)
		vm:set_param2_data(param2)
		vm:write_to_map(false)
		return true, "Done."
	end,
})
