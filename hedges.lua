


hedges.register_leaves = function(name, leafnode, leaftex)

	minetest.register_node("hedges:"..name.."_leaves", {
		description = name.." Leaves",
		drawtype = "allfaces_optional",
		tiles = { leaftex },
		paramtype = "light",
		groups = {snappy=3, flammable=2, leaves=1, hedges_leaves=1,not_in_creatve_inventory=1},
		sounds = default.node_sound_leaves_defaults(),

		drop = {
			max_items = 1,
			items = {
				{items = {"hedges:"..name.."_sapling"}, rarity = 200 },
				{items = {leafnode} }
			}
		},
	})
	
	minetest.register_node("hedges:"..name.."_leaves_top", {
		description = name.." Leaves",
		drawtype = "allfaces_optional",
		tiles = { leaftex },
		paramtype = "light",
		groups = {snappy=3, flammable=2, leaves=1, hedges_leaves=1,not_in_creatve_inventory=1},
		sounds = default.node_sound_leaves_defaults(),
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.3, -0.5, -0.5, 0.3, 0.3, 0.5},
				{-0.5, -0.5, -0.3, 0.5, 0.3, 0.3},
				{-0.3, -0.5, -0.3, 0.3, 0.5, 0.3},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			},
		},
		
		drop = {
			max_items = 1,
			items = {
				{items = {"hedges:"..name.."_sapling"}, rarity = 200 },
				{items = {leafnode} }
			}
		},
	})



end


hedges.register_root = function(name, leaftex, maxheight)
	
	minetest.register_node("hedges:"..name.."_root", {
		description = name.." Root ",
		drawtype = "allfaces_optional",
		tiles = { leaftex.."^hedges_root.png" },
		paramtype = "light",
		groups = {snappy=3, flammable=2, leaves=1, hedges_root=1},
		sounds = default.node_sound_leaves_defaults(),
		
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("hedgename", name)
		end	
		
-- 		drop = {
-- 			max_items = 1,
-- 			items = {
-- 				{items = {"hedges:"..name.."_sapling"}, rarity = 200 },
-- 				{items = {"hedges:"..name.."_root"} }
-- 			}
-- 		},
	})
	

end


hedges.register_sapling = function(name, maxheight)
	
	minetest.register_node("hedges:"..name.."_sapling", {
		description = name.." Sapling "..maxheight,
		drawtype = "allfaces_optional",
		tiles = { "hedges_root.png" },
		paramtype = "light",
		groups = {snappy=3, flammable=2, leaves=1, hedges_sapling=1},
		sounds = default.node_sound_leaves_defaults(),
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("hedgename", name)
		end
-- 		drop = {
-- 			max_items = 1,
-- 			items = {
-- 				{items = {"hedges:"..name.."_sapling"}, rarity = 200 },
-- 				{items = {"hedges:"..name.."_root"} }
-- 			}
-- 		},
	})


end



hedges.register_hedge = function(name, leafnode, leaftex, sapling, maxheight)
	
	--register the sapling
	hedges.register_sapling(name, maxheight)
	
	-- register the root
	hedges.register_root(name, leaftex, maxheight)
	
	-- register the leaves
	hedges.register_leaves(name, leafnode, leaftex)
	
	
	minetest.register_craft({
		output = "hedges:"..name.."_sapling 3",
		recipe = {
			{leafnode, leafnode, leafnode},
			{leafnode, leafnode, leafnode},
			{sapling, sapling, sapling},
		}
	})
	

end




minetest.register_abm({
	nodenames = {"group:hedges_sapling"},
	interval = 5,
	chance = 1,
	action = function(pos, node)
		pos.y = pos.y-1
		local name = minetest.get_node(pos).name
		if name == "default:dirt" 
			or name == "default:dirt_with_grass" 
			or name == "default:sand"
			or name == "default:desert_sand"
			
			then
			
			pos.y = pos.y+1
			local meta = minetest.get_meta(pos)
			local nn = meta:get_string("hedgename")
			
			minetest.set_node(pos, {name="hedges:"..nn.."_root"})

		end
	end,
})


local printpos = function(p,s)
	print("pos: "..p.x..","..p.y..","..p.z.." "..s)
end

local cp = function(p)
	return {x=p.x, y=p.y, z=p.z}
end
	
hedges.node_in_dir = function(pos, x,z, name)
	
	pos.x = pos.x + x
	pos.z = pos.z + z
	
	local n = minetest.get_node(pos).name
	if n == name then
		return cp(pos)
	
	end
	
	pos.y = pos.y + 1
	n = minetest.get_node(pos).name
	if n == name then
		return cp(pos)
	
	end
	
	pos.y = pos.y - 2
	n = minetest.get_node(pos).name
	if n == name then 
		return cp(pos)
	end

	
	return nil
end

hedges.can_spread = function(pos, x,z, name) 
	local p1 = hedges.node_in_dir(pos, x,z, name)
	if p1 == nil then return false end

	local p2 = hedges.node_in_dir(p1, x,z, name)
	if p2 == nil then return false end

	return true
end


hedges.try_spread = function(pos, x,z, rootname)
	pos.x = pos.x + x
	pos.z = pos.z + z
	
	local ns = {}
	
	pos.y = pos.y - 2 
	
	for i = 1, 3 do
		local dirt = minetest.get_node(pos).name
		local air = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
		
		if air == "air" and
			(dirt == "default:dirt" 
			or dirt == "default:dirt_with_grass" 
			or dirt == "default:sand"
			or dirt == "default:desert_sand") then
			
			minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z}, rootname)
		end
		
		pos.y = pos.y + 1
	end

end


minetest.register_abm({
	nodenames = {"group:hedges_root"},
	interval = 5,
	chance = 1,
	action = function(pos, node)
		local op = {
			x=pos.x,
			y=pos.y,
			z=pos.z
		}
		local myname = minetest.get_node(op).name
		pos.y = pos.y-1
		local name = minetest.get_node(pos).name
		if name == "default:dirt" 
			or name == "default:dirt_with_grass" 
			or name == "default:sand"
			or name == "default:desert_sand"
			
			then
			
			-- grow up
			pos.y = pos.y+1
			
			local meta = minetest.get_meta(pos)
			local nn = meta:get_string("hedgename")
			pos.y = pos.y+1
			

			local height = 1
			while (minetest.get_node(pos).name == "hedges:"..nn.."_leaves" or minetest.get_node(pos).name == "hedges:"..nn.."_leaves_top")  and height < 3 do
				height = height+1
				pos.y = pos.y+1
			end

			if height == 3 then
				if minetest.get_node(pos).name == "air" then
					minetest.set_node(pos, {name="hedges:"..nn.."_leaves_top"})
				end
			elseif height < 3 then
				if minetest.get_node(pos).name == "air" then
					minetest.set_node(pos, {name="hedges:"..nn.."_leaves"})
				end
			end
			
			-- spread
			if hedges.can_spread(cp(op), 1,0, myname) then
				hedges.try_spread(cp(op), -1,0, {name="hedges:"..nn.."_sapling"})
			elseif hedges.can_spread(cp(op), -1,0, myname) then
				hedges.try_spread(cp(op), 1,0, {name="hedges:"..nn.."_sapling"})
			end
			
			if hedges.can_spread(cp(op), 0,1, myname) then
				hedges.try_spread(cp(op), 0,-1, {name="hedges:"..nn.."_sapling"})
			elseif hedges.can_spread(cp(op), 0,-1, myname) then
				hedges.try_spread(cp(op), 0,1, {name="hedges:"..nn.."_sapling"})
			end

		end
	end
})


for i in ipairs(moretrees.treelist) do
	local treename = moretrees.treelist[i][1]
	hedges.register_hedge(treename, "moretrees:"..treename.."_leaves", "moretrees_"..treename.."_leaves.png" , "moretrees:"..treename.."_sapling", 4)
	
end




hedges.register_hedge("defaultleaves", "default:leaves", "default_leaves.png", "default:sapling", 4)
hedges.register_hedge("bananaleaves", "farming:banana_leaves", "farming_banana_leaves.png", "default:sapling", 4)
hedges.register_hedge("pineneedles", "snow:needles", "snow_needles.png", "default:sapling", 4)
hedges.register_hedge("poisonivy", "poisonivy:poisonivy_climbing", "poisonivy_climbing.png", "poisonivy:sproutling", 4)

