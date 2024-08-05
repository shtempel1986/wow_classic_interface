
ArkInventory.API = { }

function ArkInventory.TooltipBuildBattlepet( ... )
--[[
	deprecated - use ArkInventory.API.CustomBattlePetTooltipReady instead
	
	exists only to support any mods that are still hooking this instead of the new function
		BattlePetBreedID
]]--
end

function ArkInventory.API.CustomBattlePetTooltipReady( ... )
--[[
	
	called after the custom battlepet tooltip is shown
	it's behind all the arkinventory option checks so you dont have to check those
	you can add whatever you want at this point
	
	usage
		hooksecurefunc( ArkInventory.API, "CustomBattlePetTooltipReady", YourMod.YourFunctionNameGoesHere )
		
	args
		[1] tooltip
		[2] battlepet hyperlink string
		
		remaining args are from unpack( ArkInventory.ObjectStringDecode( h ) )
		[3] class (should always be battlepet)
		[4] speciesid
		[5] level
		[6] quality
		[7] maxhealth
		[8] power
		[9] speed
		
]]--
	
	-- to cover any mods that have not been updated yet, call the old function so they get called
	ArkInventory.TooltipBuildBattlepet( ... )
	
end

function ArkInventory.API.helper_CustomBattlePetTooltipReady( tooltip, h )
	--ArkInventory.OutputDebug( { ArkInventory.ObjectStringDecode( h ) } )
	ArkInventory.API.CustomBattlePetTooltipReady( tooltip, h, unpack( ArkInventory.ObjectStringDecode( h ) ) )
end

function ArkInventory.API.CustomReputationTooltipReady( ... )
--[[
	
	called after the custom reputation tooltip is shown
	
	usage
		hooksecurefunc( ArkInventory.API, "CustomReputationTooltipReady", YourMod.YourFunctionNameGoesHere )
		
	args
		[1] tooltip
		[2] custom "hyperlink" string - reputation:factionID:standingText:barValue:barMin:barMax:isCapped:paragonLevel:paragonRewardPending:rankValue:rankMax
	
]]--
end

function ArkInventory.API.ReloadedTooltipReady( tooltip, fn, ... )
--[[
	
	called after a tooltip has been forcibly reloaded - its effectively like opening the tooltip if you only hook onshow and none of the set functions
	runs before the arkinventory item counts are added
	required for AllTheThings
	
	usage
		hooksecurefunc( ArkInventory.API, "ReloadedTooltipReady", YourMod.YourFunctionNameGoesHere )
		
	args
		[1] the tooltip that was just reloaded
		[2] name of the function that was called to set the original tooltip
		[...] original functions arguments 
	
]]--
end

function ArkInventory.API.ReloadedTooltipCleared( tooltip )
--[[
	
	called after a tooltip that is reloading has been cleared - its effectively like closing the tooltip if you only hook onclose
	required for AllTheThings
	
	usage
		hooksecurefunc( ArkInventory.API, "ReloadedTooltipCleared", YourMod.YourFunctionNameGoesHere )
		
	args
		[1] the tooltip that was cleared
	
]]--
end

function ArkInventory.API.ItemFrameLoaded( ... )
--[[
	
	called after a clean (untainted) item frame is created/loaded
	
	usage
		hooksecurefunc( ArkInventory.API, "ItemFrameLoaded", YourMod.YourFunctionNameGoesHere )
		
	args
		[1] frame
		[2] loc_id - arkinventory location id
		[3] bag_id - arkinventory bag id
		[4] slot_id - slot id
	
]]--
end

function ArkInventory.API.ItemFrameUpdated( ... )
--[[
	
	called after an item frame is updated
	
	usage
		hooksecurefunc( ArkInventory.API, "ItemFrameUpdated", YourMod.YourFunctionNameGoesHere )
		
	args
		[1] frame
		[2] loc_id - arkinventory location id
		[3] bag_id - arkinventory bag id
		[4] slot_id - slot id
	
]]--
end

function ArkInventory.API.ItemFrameLoadedIterate( loc, bag )
--[[
	
	call this when you need to loop through the loaded item frames for all locations, a specific location, or a specific location and bag
	
	ArkInventory.API.ItemFrameLoadedIterate( ) = everything
	ArkInventory.API.ItemFrameLoadedIterate( ArkInventory.Const.Location.Bank ) = just the bank
	
	for framename, frame, loc_id_window, bag_id_window, slot_id in ArkInventory.API.ItemFrameLoadedIterate( loc, bag ) do
		your code goes here
	end
	
]]--
	
	local locations = ArkInventory.Util.MapGetWindow( )
	local loc_id_window = next( locations, nil )
	local loc_data = ArkInventory.Global.Location[loc_id_window]
	local bags = ArkInventory.Util.MapGetWindow( loc_id_window )
	local bag_id_window = 1
	local slot_id = 0
	
	local isWanted, framename, frame
	
	
	return function( )
		
		isWanted = false
		framename = nil
		frame = nil
		
		while not isWanted do
			
			--ArkInventory.Output( "start [", loc_id_window, "].[", bag_id_window, "].[", slot_id, "] [", loc_data, "]" )
			
			if slot_id < ( loc_data.maxSlot[bag_id_window] or 0 ) then
				
				slot_id = slot_id + 1
				
			elseif bag_id_window < #bags then
				
				bag_id_window = bag_id_window + 1
				slot_id = 1
				
			elseif loc_id_window then
				
				loc_id_window = next( locations, loc_id_window )
				if not loc_id_window then return end
				
				loc_data = ArkInventory.Global.Location[loc_id_window]
				bags = ArkInventory.Util.MapGetWindow( loc_id_window )
				bag_id_window = 1
				slot_id = 1
				
			end
			
			--ArkInventory.Output( "check [", loc_id_window, "].[", bag_id_window, "].[", slot_id, "]" )
			
			if loc_id_window and bag_id_window and loc_data.canView then
				if not loc or loc_id_window == loc then
					if ( not loc ) or ( loc and ( not bag or bag_id_window == bag ) ) then
						framename, frame = ArkInventory.ContainerItemNameGet( loc_id_window, bag_id_window, slot_id )
						if frame then
							isWanted = true
						end
					end
				end
			end
			
			--ArkInventory.Output( "wanted [", isWanted, "]" )
			
		end
		
		
		return framename, frame, loc_id_window, bag_id_window, slot_id
		
	end
	
end

function ArkInventory.API.ItemFrameGet( loc_id_window, bag_id_window, slot_id )
--[[
	
	usage
		local framename, frame = ArkInventory.API.ItemFrameGet( loc_id_window, bag_id_window, slot_id )
		
]]--
	return ArkInventory.ContainerItemNameGet( loc_id_window, bag_id_window, slot_id )
end

function ArkInventory.API.ItemFrameItemTableGet( frame )
	
	-- returns the "i" table for the item assigned to the specified item frame
	-- if its not an arkinventory frame youll get nil back
	
	if frame and frame.ARK_Data then
		return ArkInventory.Frame_Item_GetDB( frame )
	end
	
end

function ArkInventory.API.getBlizzardBagIdFromWindowId( loc_id_window, bag_id_window )
--[[
	
	converts from an arkinventory loc_id_window + bag_id_window combination to a blizzard bag id that the blizzard functions will accept
	
	
	usage
		local blizzard_id = ArkInventory.API.getBlizzardBagIdFromWindowId( loc_id_window, bag_id_window )
		
	notes
		only container frame based locations/bags will have a valid blizzard id that will work with the container API
		if you already have the item frame you can also use frame.ARK_Data.blizzard_id to get the same value
		
]]--
	
	if ArkInventory.Util.MapCheckWindow( loc_id_window, bag_id_window ) then
		return ArkInventory.Util.getBlizzardBagIdFromWindowId( loc_id_window, bag_id_window )
	end
	
	ArkInventory.OutputWarning( "invalid value passed to API: ArkInventory.API.getBlizzardBagIdFromWindowId( ", loc_id_window, ", ", bag_id_window, " )" )
	
end

function ArkInventory.API.InternalIdToBlizzardBagId( loc_id_window, bag_id_window )
	-- deprecated - left here for compatibility
	return ArkInventory.API.getBlizzardBagIdFromWindowId( loc_id_window, bag_id_window )
end

function ArkInventory.API.BlizzardBagId( loc_id_window, bag_id_window )
	-- deprecated - left here for compatibility
	return ArkInventory.API.getBlizzardBagIdFromWindowId( loc_id_window, bag_id_window )
end

function ArkInventory.API.BlizzardBagIdToInternalId( blizzard_id )
	
	if ArkInventory.Util.MapCheckBlizzard( blizzard_id ) then
		return ArkInventory.Util.getWindowIdFromBlizzardBagId( blizzard_id )
	end
	
	ArkInventory.OutputWarning( "invalid value passed to API: ArkInventory.API.BlizzardBagIdToInternalId( ", blizzard_id, " )" )
	
end

function ArkInventory.API.LocationIsOffline( loc_id_window )
--[[
	
	returns
		true = location is offline
		false = location is online
		nil = invalid location id
		
]]--
	
	if loc_id_window and ArkInventory.Global.Location[loc_id_window] and ArkInventory.Global.Location[loc_id_window].isMapped and ArkInventory.Global.Location[loc_id_window].canView then
		return not not ArkInventory.Global.Location[loc_id_window].isOffline
	end
	
end

function ArkInventory.API.Version( )
	return ArkInventory.Const.Program.Version, ArkInventory.Global.Version
end
