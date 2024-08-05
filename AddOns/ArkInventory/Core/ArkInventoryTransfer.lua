local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


function ArkInventory.BarTransfer( loc_id, bar_id, dst_id )
	
	if not ArkInventory.Global.Mode.Bank then return end
	if not ( loc_id == ArkInventory.Const.Location.Bag or loc_id == ArkInventory.Const.Location.Bank ) then return end
	
	ArkInventory.OutputWarning( "not yet implemented - moving all items in bar ", bar_id, " to the ", ArkInventory.Global.Location[dst_id].Name )
	
end
