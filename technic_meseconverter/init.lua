
local m_rules = {{x=0,y=0,z=1},{x=0,y=0,z=-1},{x=1,y=0,z=0},{x=-1,y=0,z=0},{x=0,y=1,z=0},{x=0,y=-1,z=0}}

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

local setv = function(pos,value)
	local node = minetest.get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]
	
	if value and string.ends(node.name, "_off") then
		minetest.swap_node(pos, {name = nodedef.__mesecon_basename .. "_on", param2 = node.param2})
		mesecon.receptor_on(pos, m_rules)
	elseif not value and string.ends(node.name, "_on") then
		minetest.swap_node(pos, {name = nodedef.__mesecon_basename .. "_off", param2 = node.param2})
		mesecon.receptor_off(pos, m_rules)
	end
end

local run = function(pos, node)
	local meta         = minetest.get_meta(pos)
	local eu_input     = meta:get_int("LV_EU_input")
	local demand       = 50
	
	-- Setup meta data if it does not exist.
	if not eu_input then
		meta:set_int("LV_EU_demand", demand)
		meta:set_int("LV_EU_input", 0)
		return
	end
	
	if eu_input < demand then
		meta:set_string("infotext", "Unpowered")
		setv(pos,false)
	elseif eu_input >= demand then
		meta:set_string("infotext", "Active")
		setv(pos,true)
	end
	meta:set_int("LV_EU_demand", demand)
end


mesecon.register_node("technic_meseconverter:converter",
{
	description = "Mesecon Converter",
	
	sounds = default.node_sound_wood_defaults(),
	technic_run = run,
	technic_on_disable = function(pos)
		setv(pos,false)
	end,
},{
	tiles = {"jeija_mesecon_switch_off.png", "jeija_mesecon_switch_off.png", "jeija_mesecon_switch_off.png",
	         "jeija_mesecon_switch_off.png", "jeija_mesecon_switch_off.png", "jeija_mesecon_switch_off.png"},
	mesecons = { receptor = { state = mesecon.state.off, rules = m_rules } },
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2, technic_machine=1, mesecon = 2},
},{
	tiles = {"jeija_mesecon_switch_on.png", "jeija_mesecon_switch_on.png", "jeija_mesecon_switch_on.png",
	         "jeija_mesecon_switch_on.png", "jeija_mesecon_switch_on.png", "jeija_mesecon_switch_on.png"},
	mesecons = { receptor = { state = mesecon.state.on, rules = m_rules } },
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2, technic_machine=1, mesecon = 2, not_in_creative_inventory=1},
	paramtype = "light",
	light_source = 10
})


technic.register_machine("LV", "technic_meseconverter:converter_on", technic.receiver)
technic.register_machine("LV", "technic_meseconverter:converter_off", technic.receiver)