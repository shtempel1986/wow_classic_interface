local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


local codex_data = {
	window = {
--		[loc_id] = which characters data is being displayed in each location
	},
	player = {
--		[loc_id] = the active characters data for each location
	},
}


ArkInventory.Codex = { }



local function helper_CodexInit( loc_id )
	
	codex_data.window[loc_id] = codex_data.window[loc_id] or { }
	local codex = codex_data.window[loc_id]
	
	codex.loc_id = loc_id
	codex.player = codex.player or { }
	codex.toon = codex.toon or { }
	codex.workpad = codex.workpad or { }
	codex.global = codex.global or ArkInventory.acedb.global.options
	
	return codex
	
end

function ArkInventory.Codex.GetStorage( player_id, loc_id, player )
	
	-- points player.data to the requested player_id storage
	
	local loc_id = loc_id or ArkInventory.Const.Location.Bag
	
	local codex = helper_CodexInit( loc_id )
	
	local player_id = player_id or codex.player.current or ArkInventory.PlayerIDSelf( )
	
	--ArkInventory.Output( player_id, " / ", codex.player.current )
	
	local player = player or { }
	
	player.data = ArkInventory.db.player.data[player_id]
	
	--ArkInventory.Output( "guild [", player.data.info.guild_id, "]" )
	
	if loc_id == ArkInventory.Const.Location.Vault and player.data.info.class ~= ArkInventory.Const.Class.Guild then
		
		--ArkInventory.Output( "GetGuildInfo ", { GetGuildInfo( "player" ) } )
		
--		local player_old = player_id
		player_id = player.data.info.guild_id or player_id
		
--		ArkInventory.Output( "moving ", ArkInventory.Global.Location[loc_id].Name, " from [", player_old, "] to [", player_id, "]" )
		
		player.data = ArkInventory.db.player.data[player_id]
		
--		if player.data.info.class ~= "GUILD" then
--			ArkInventory.OutputWarning( "invalid codex: ", player.data.info )
--		else
--			ArkInventory.Output( "codex: ", player.data.info )
--		end
		
	elseif ArkInventory.Global.Location[loc_id].isAccount and player.data.info.class ~= ArkInventory.Const.Class.Account then
		
--		local player_old = player_id
		player_id = ArkInventory.PlayerIDAccount( )
		
		--ArkInventory.Output( "moving ", ArkInventory.Global.Location[loc_id].Name, " from [", player_old, "] to [", player_id, "]" )
		
		--ArkInventory.Output( "moved ", ArkInventory.Global.Location[loc_id].Name, " to ", player_id )
		player.data = ArkInventory.db.player.data[player_id]
		
	end
	
	
	return player
	
end

function ArkInventory.Codex.GetLocation( loc_id, player_id )
	
	-- gets the codex for the current user being displayed at the specified location
	-- get a specific player by passing in the player_id
	
	--ArkInventory.Output( "Codex.GetLocation( ", ArkInventory.Global.Location[loc_id].Name, " )" )
	
	--error( "stop here" )
	--local tz = debugprofilestop( )
	
	ArkInventory.Util.Assert( type( loc_id ) == "number", "loc_id is [", type( loc_id ), "], should be [number]" )
	
	local changed = false
	
	local codex = helper_CodexInit( loc_id )
	
	
	local player_id = player_id or codex.player.current or ArkInventory.PlayerIDSelf( )
	codex.player.current = player_id
	
	ArkInventory.Codex.GetStorage( codex.player.current, loc_id, codex.player )
	
	if codex.player.current ~= codex.player.previous then
		--ArkInventory.Output( "codex player for ", ArkInventory.Global.Location[loc_id].Name, " changed from ", codex.player.previous, " to ", codex.player.current )
		codex.player.previous = codex.player.current
		changed = true
	end
	
	
	-- get the correct character profile to use to display the data
	if not ArkInventory.db.player.data[player_id].info.isplayer then
		player_id = ArkInventory.PlayerIDSelf( )
	end
	codex.toon.data = ArkInventory.db.player.data[player_id]
	
	codex.toon.current = codex.toon.data.info.player_id
	if codex.toon.current ~= codex.toon.previous then
		--ArkInventory.Output( "codex toon for ", ArkInventory.Global.Location[loc_id].Name, " changed from ", codex.toon.previous, " to ", codex.toon.current )
		codex.toon.previous = codex.toon.current
		changed = true
	end
	
	
	if not codex.profile_id or codex.profile_id ~= codex.toon.data.profile then
		--ArkInventory.OutputDebug( "codex profile changed for ", codex.player.current, " from ", codex.profile_id, " to ", codex.toon.data.profile )
		codex.profile_id, codex.profile = ArkInventory.ConfigInternalProfileGet( codex.toon.data.profile, true )
		changed = true
	end
	
	if not codex.style_id or codex.style_id ~= codex.profile.location[loc_id].style then
		--ArkInventory.OutputDebug( "codex style changed for ", codex.player.current, " from ", codex.style_id, " to ", codex.profile.location[loc_id].style )
		codex.style_id, codex.style = ArkInventory.ConfigInternalDesignGet( codex.profile.location[loc_id].style, true )
		changed = true
	end
	
	if not codex.layout_id or codex.layout_id ~= codex.profile.location[loc_id].layout then
		--ArkInventory.OutputDebug( "codex layout changed for ", codex.player.current, " from ", codex.layout_id, " to ", codex.profile.location[loc_id].layout )
		codex.layout_id, codex.layout = ArkInventory.ConfigInternalDesignGet( codex.profile.location[loc_id].layout, true )
		changed = true
	end
	
	if not codex.catset_id or codex.catset_id ~= codex.profile.location[loc_id].catset then
		--ArkInventory.OutputDebug( "codex catset changed for ", codex.player.current, " from ", codex.catset_id, " to ", codex.profile.location[loc_id].catset )
		codex.catset_id, codex.catset = ArkInventory.ConfigInternalCategorysetGet( codex.profile.location[loc_id].catset, true )
		changed = true
	end
	
	if changed then
		--ArkInventory.OutputWarning( "GetLocationCodex - .restart ", loc_id )
		ArkInventory.Frame_Main_DrawStatus( loc_id, ArkInventory.Const.Window.Draw.Restart )
	end
	
	--tz = debugprofilestop( ) - tz
	--print( "built location codex for " .. codex.player.current .. " / " .. loc_id .. " / ", codex.player.data.info.player_id, " in " .. tz )
	
	--ArkInventory.Output( "Codex = ", codex.player.current )
	
	
	return codex
	
end

function ArkInventory.Codex.SetWindow( loc_id_window, player_id )
	
	local player_id = player_id or ArkInventory.PlayerIDSelf( )
	
	local player = ArkInventory.Codex.GetStorage( player_id, loc_id_window )
	
	for loc_id_storage in pairs( ArkInventory.Util.MapGetChildren( loc_id_window ) ) do
		
		local codex = helper_CodexInit( loc_id_storage )
		
		codex.player.previous = codex.player.current
		codex.player.current = player.data.info.player_id
		
	end
	
	return ArkInventory.Codex.GetLocation( loc_id_window )
	
end

function ArkInventory.Codex.GetPlayerStorage( loc_id )
	
	-- gets the storage for the logged on character / guild / account at the specified location
	
	local loc_id = loc_id or ArkInventory.Const.Location.Bag
	
	local player_id = ArkInventory.PlayerIDSelf( )
	
	local storage = ArkInventory.Codex.GetStorage( player_id, loc_id )
	
	
	return storage
	
end

function ArkInventory.Codex.GetPlayer( loc_id, rebuild )
	
	-- gets the codex for the logged on character / guild / account at the specified location
	
	--local tz = debugprofilestop( )
	
	local loc_id = loc_id or ArkInventory.Const.Location.Bag
	
	codex_data.player[loc_id] = codex_data.player[loc_id] or { }
	local codex = codex_data.player[loc_id]
	
	codex.loc_id = loc_id
	codex.player = codex.player or { }
	codex.global = codex.global or ArkInventory.acedb.global.options
	
	local player_id = ArkInventory.PlayerIDSelf( )
	
	ArkInventory.Codex.GetStorage( player_id, nil, codex.player )
	
	codex.player.previous = codex.player.data.info.player_id
	codex.player.current = codex.player.data.info.player_id
	
	codex.profile_id, codex.profile = ArkInventory.ConfigInternalProfileGet( codex.player.data.profile, true )
	
	ArkInventory.Codex.GetStorage( player_id, loc_id, codex.player )
	
	codex.style_id, codex.style = ArkInventory.ConfigInternalDesignGet( codex.profile.location[loc_id].style, true )
	codex.layout_id, codex.layout = ArkInventory.ConfigInternalDesignGet( codex.profile.location[loc_id].layout, true )
	codex.catset_id, codex.catset = ArkInventory.ConfigInternalCategorysetGet( codex.profile.location[loc_id].catset, true )
	
	
	
	--tz = debugprofilestop( ) - tz
	--print( "built player codex for " .. codex.player.current .. " / " .. loc_id .. " / ", codex.player.data.info.player_id, " in " .. tz )
	
	return codex
	
end

function ArkInventory.Codex.Reset( loc_id )
	
	if not loc_id then
		ArkInventory.Table.Wipe( codex_data.player )
		ArkInventory.Table.Wipe( codex_data.window )
	else
		codex_data.player[loc_id] = nil
		codex_data.window[loc_id] = nil
	end
	
	ArkInventory.ItemCacheClear( )
	
end
