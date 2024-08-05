local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


ArkInventory.Action = { }

local actiondata = {
	vendor = {
		name = ArkInventory.Localise["VENDOR"],
		addons = { "Scrap", "SellJunk", "ReagentRestocker", "Peddler" },
		addon = nil,
		conflict = false,
		limit = BUYBACK_ITEMS_PER_PAGE or 12,
		
		running = false,
		bypass = false, -- shift key down on open
		sold = 0,
		money = 0,
	},
	mail = {
		name = ArkInventory.Localise["MAIL"],
		addons = { },
		addon = nil,
		conflict = false,
		limit = ATTACHMENTS_MAX_SEND or 12,
		
		running = false,
		bypass = false,
		status = nil,
	},
	use = {
		name = ArkInventory.Localise["USE"],
		addons = { },
		addon = nil,
		conflict = false,
		limit = 0,
		
		running = false,
		combatnotify = nil,
		runaftercombat = nil,
		lootnotify = nil,
		runafterlooting = nil,
	},
	delete = {
		name = ArkInventory.Localise["DELETE"],
		addons = { },
		addon = nil,
		conflict = false,
		limit = 1,
		
		running = false,
	},
	scrap = {
		ClientCheck = ArkInventory.ClientCheck( ArkInventory.ENUM.EXPANSION.BFA ),
		name = ArkInventory.Localise["SCRAP"],
		addons = { },
		addon = nil,
		conflict = false,
		limit = 9,
		spellID = ArkInventory.CrossClient.GetScrapSpellID( ),
		
		running = false,
		bypass = false,
		status = nil,
	},
}

function ArkInventory.Action.ConflictCheck( )
	for _, action in pairs( actiondata ) do
		for _, a in pairs( action.addons ) do
			if _G[a] and ArkInventory.CrossClient.IsAddOnLoaded( a ) then
				action.conflict = true
				action.addon = a
				ArkInventory.OutputWarning( string.format( ArkInventory.Localise["CONFIG_ACTION_CONFLICT"], action.name, action.addon ) )
			end
		end
	end
end



ArkInventory.Action.Vendor = { data = actiondata.vendor }

function ArkInventory.Action.Vendor.Check( codex, blizzard_id, slot_id, manual, delete )
	
	-- do not call from rules or youll get an infinite loop
	
	
	local isMatch = false
	local vendorPrice = -1
	
	local map = ArkInventory.Util.MapGetBlizzard( blizzard_id )
	
	local loc_id_window = map.loc_id_window
	if ( loc_id_window == ArkInventory.Const.Location.Bag or loc_id_window == ArkInventory.Const.Location.Bank ) then
		
		local bag_id_window = map.bag_id_window
		
		local loc_id_storage = map.loc_id_storage
		local bag_id_storage = map.bag_id_storage
		
		local player_id = codex.player.data.info.player_id
		local storage = ArkInventory.Codex.GetStorage( player_id, loc_id_storage )
		local bag = storage.data.location[loc_id_storage].bag[bag_id_storage]
		local i = bag.slot[slot_id]
		
		if i.h then
			
			local info = ArkInventory.GetObjectInfo( i.h )
			if info.ready and info.id then
				
				local ignore = false
				
				if delete then
					
					ignore = ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, nil, ArkInventory.Localise["WOW_TOOLTIP_BIND_REFUNDABLE"], false, true, true, 0 )
					
					if not ArkInventory.db.option.action.delete.partyloot then
						ignore = ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, nil, ArkInventory.Localise["WOW_TOOLTIP_BIND_PARTYLOOT"], false, true, true, 0 )
					end
					
				else
					
					ignore = ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, nil, ArkInventory.Localise["WOW_TOOLTIP_BIND_REFUNDABLE"], false, true, true, 0 )
					
					if not ArkInventory.db.option.action.vendor.partyloot then
						ignore = ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, nil, ArkInventory.Localise["WOW_TOOLTIP_BIND_PARTYLOOT"], false, true, true, 0 )
					end
					
				end
				
				if not ignore then
					
					if ArkInventory.CrossClient.IsAddOnLoaded( "Scrap" ) and Scrap then
						if Scrap:IsJunk( info.id ) then
							isMatch = true
						end
					elseif ArkInventory.CrossClient.IsAddOnLoaded( "SellJunk" ) and SellJunk then
						if ( info.q == ArkInventory.ENUM.ITEM.QUALITY.POOR and not SellJunk:isException( info.h ) ) or ( info.q ~= ArkInventory.ENUM.ITEM.QUALITY.POOR and SellJunk:isException( info.h ) ) then
							isMatch = true
						end
					elseif ArkInventory.CrossClient.IsAddOnLoaded( "ReagentRestocker" ) and ReagentRestocker then
						if ReagentRestocker:isToBeSold( info.id ) then
							isMatch = true
						end
					elseif ArkInventory.CrossClient.IsAddOnLoaded( "Peddler" ) and PeddlerAPI then
						if PeddlerAPI.itemIsToBeSold( info.id ) then
							isMatch = true
						end
					else
						
						local cat_id = ArkInventory.ItemCategoryGet( i )
						local cat_type, cat_num = ArkInventory.CategoryIdSplit( cat_id )
						local catset = codex.catset.ca[cat_type][cat_num]
						
						if delete then
							if info.q <= ArkInventory.db.option.action.delete.raritycutoff then
								if catset.action.t == ArkInventory.ENUM.ACTION.TYPE.DELETE or catset.action.t == ArkInventory.ENUM.ACTION.TYPE.VENDOR then
									if catset.action.w == ArkInventory.ENUM.ACTION.WHEN.AUTO or catset.action.w == ArkInventory.ENUM.ACTION.WHEN.MANUAL then
										isMatch = true
									end
								end
							end
						else
							if info.q <= ArkInventory.db.option.action.vendor.raritycutoff then
								if catset.action.t == ArkInventory.ENUM.ACTION.TYPE.VENDOR then
									if catset.action.w == ArkInventory.ENUM.ACTION.WHEN.AUTO then
										isMatch = true
									elseif catset.action.w == ArkInventory.ENUM.ACTION.WHEN.MANUAL and manual then
										isMatch = true
									end
								end
							end
						end
						
					end
					
				end
				
			end
			
			--ArkInventory.Output( "vendor check [", loc_id_window, "].[", bag_id_window, "].[", slot_id, "] = ", isMatch, " [", vendorPrice, "]" )
			
			if isMatch then
				
				vendorPrice = info.vendorprice
				
				if vendorPrice == -1 then
					isMatch = false
				end
				
			end
			
		end
		
	end
	
	
	return isMatch, vendorPrice
	
end

function ArkInventory.Action.Vendor.Iterate( manual )
	
	local loc_id_window = ArkInventory.Const.Location.Bag
	local loc_data = ArkInventory.Global.Location[loc_id_window]
	
	local codex = ArkInventory.Codex.GetPlayer( loc_id_window )
	
	local bags = ArkInventory.Util.MapGetWindow( loc_id_window )
	local bag_id_window = 1
	local slot_id = 0
	
	local isMatch, blizzard_id, isLocked, itemCount, itemLink, vendorPrice
	
	
	return function( )
		
		isMatch = false
		blizzard_id = nil
		itemLink = nil
		itemCount = 0
		vendorPrice = -1
		
		while not isMatch do
			
			if slot_id < ( loc_data.maxSlot[bag_id_window] or 0 ) then
				
				slot_id = slot_id + 1
				
			elseif bag_id_window < #bags then
				
				bag_id_window = bag_id_window + 1
				slot_id = 1
				
			else
				
				return
				
			end
			
			--ArkInventory.Output( "vendor check [", loc_id_window, "].[", bag_id_window, "].[", slot_id, "]" )
			
			local map = ArkInventory.Util.MapGetWindow( loc_id_window, bag_id_window )
			blizzard_id = map.blizzard_id
			
			local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
			itemCount = itemInfo.stackCount
			isLocked = itemInfo.isLocked
			itemLink = itemInfo.hyperlink
			
			if itemCount and not isLocked and itemLink then
				
				isMatch, vendorPrice = ArkInventory.Action.Vendor.Check( codex, blizzard_id, slot_id, manual )
				
				--ArkInventory.Output( "vendor result [", loc_id_window, "].[", bag_id_window, "].[", slot_id, "] = ", isMatch, " [", vendorPrice, "]" )
				
				if isMatch and vendorPrice == 0 then
					isMatch = false
				end
				
			end
			
		end
		
		return blizzard_id, slot_id, itemLink, itemCount, vendorPrice
		
	end
	
end

function ArkInventory.Action.Vendor.Thread( thread_id, manual )
	
	if not ArkInventory.Global.Mode.Merchant then
		--ArkInventory.Output( "ABORTED (NOT MERCHANT)" )
		return
	end
	
--	ArkInventory.Output( "start amount ", GetMoney( ) )
	ArkInventory.Action.Vendor.data.money = GetMoney( )
	
	local limit = ( ArkInventory.db.option.action.vendor.limit and ArkInventory.Action.Vendor.data.limit ) or 0
	
	-- build the queue
	local queue = { }
	for blizzard_id, slot_id, itemLink, itemCount, vendorPrice in ArkInventory.Action.Vendor.Iterate( manual ) do
		table.insert( queue, { blizzard_id, slot_id, itemLink, itemCount, vendorPrice } )
	end
	
	local qsize = ArkInventory.Table.Elements( queue )
	local runtype = ArkInventory.Localise["AUTOMATIC"]
	if manual then
		runtype = ArkInventory.Localise["MANUAL"]
	end
	
	local test = ""
	if ArkInventory.db.option.action.vendor.test then
		test = string.format( "(%s)", ArkInventory.Localise["CONFIG_ACTION_TESTING"] )
	end

	if manual or qsize > 0 and ArkInventory.db.option.action.vendor.list then
		ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_BOOKEND"], ArkInventory.Localise["ACTION"], ArkInventory.Localise["CONFIG_ACTION_VENDOR"], runtype, ArkInventory.Localise["START"] ) )
	end
	
	
	-- process the queue
	for _, item in pairs( queue ) do
		
		if InCombatLockdown( ) then
			
			if not ArkInventory.Action.Vendor.data.combatnotify then
				ArkInventory.Action.Vendor.data.combatnotify = true
				ArkInventory.OutputWarning( string.format( ArkInventory.Localise["CONFIG_ACTION_ABORT_COMBAT"], ArkInventory.Localise["CONFIG_ACTION_USE"] ) )
			end
			
			if not manual then
				ArkInventory.Action.Vendor.data.runaftercombat = true
			end
			
			break
			
		else
			
			ArkInventory.Action.Vendor.data.combatnotify = nil
			
		end
		
		ArkInventory.Action.Vendor.data.sold = ArkInventory.Action.Vendor.data.sold + 1
		
		if limit > 0 and ArkInventory.Action.Vendor.data.sold > limit then
			-- limited to buyback page
			ArkInventory.Action.Vendor.data.sold = limit
			ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, string.format( ArkInventory.Localise["CONFIG_ACTION_VENDOR_LIMIT_ABORT"], limit ) )
			break
		end
		
		if not ArkInventory.db.option.action.vendor.test then
			if ArkInventory.Global.Mode.Merchant then
				ArkInventory.CrossClient.UseContainerItem( item[1], item[2] )
				ArkInventory.ThreadYield( thread_id )
			end
		end
		
		if ArkInventory.db.option.action.vendor.list then
			ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_VENDOR_LIST"], test, item[4], item[3], ArkInventory.MoneyText( item[4] * item[5], true ) ) )
		end
		
	end
	
	if manual or qsize > 0 then
		if ArkInventory.db.option.action.vendor.list then
			ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_BOOKEND"], ArkInventory.Localise["ACTION"], ArkInventory.Localise["CONFIG_ACTION_VENDOR"], runtype, ArkInventory.Localise["COMPLETE"] ) )
		end
	end
	
	if qsize > 0 and ArkInventory.Action.Vendor.data.sold > 0 then
		if ArkInventory.db.option.action.vendor.test then
			ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.Localise["CONFIG_ACTION_VENDOR_TEST"] )
		end
	end
	
	if manual and limit > 0 and qsize > limit then
		ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, string.format( ArkInventory.Localise["CONFIG_ACTION_VENDOR_MORE"], qsize - 1 ) )
	end
	
	-- this will sometimes fail, without any notifcation, so you cant just add up the values as you go
	-- GetMoney doesnt update in real time so also cannot be used here
	-- next best thing, record how much money we had beforehand and how much we have at the next PLAYER_MONEY event, then output it there
	
	-- notifcation is at EVENT_ARKINV_PLAYER_MONEY, call it in case it tripped before the final yield came back
--	ArkInventory:SendMessage( "EVENT_ARKINV_PLAYER_MONEY_BUCKET", "JUNK" )
	
end

function ArkInventory.Action.Vendor.Ready( manual )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	if not ArkInventory.Global.Mode.Merchant then return end
	
	if ArkInventory.Action.Vendor.data.conflict then return end
		
	if not ArkInventory.db.option.action.vendor.enable then return end
	
	if ArkInventory.Action.Vendor.data.bypass then return end
	
	if ArkInventory.Action.Vendor.data.wait then return end
	
	if InCombatLockdown( ) then return end
	
	if not ArkInventory.Global.Thread.Use then
		ArkInventory.OutputWarning( ArkInventory.Localise["CONFIG_ACTION_VENDOR"], " aborted, as threads are currently disabled." )
		return
	end
	
	if manual then
		if not ArkInventory.db.option.action.vendor.manual then return end
	else
		if not ArkInventory.db.option.action.vendor.auto then return end
	end
	
	if ArkInventory.Action.Vendor.data.running then
		ArkInventory.OutputWarning( string.format( ArkInventory.Localise["CONFIG_ACTION_RUNNING"], ArkInventory.Localise["CONFIG_ACTION_VENDOR"] ) )
		return
	end
	
	
	return true
	
end

function ArkInventory.Action.Vendor.Run( manual )
	
	if not ArkInventory.Action.Vendor.Ready( manual ) then return end
	
	
	ArkInventory.Action.Vendor.data.sold = 0
	ArkInventory.Action.Vendor.data.money = 0
	
	local thread_id = ArkInventory.Global.Thread.Format.ActionVendor
	
	local thread_func = function( )
		ArkInventory.Action.Vendor.data.running = true
		ArkInventory.Action.Vendor.Thread( thread_id, manual )
		ArkInventory.Action.Vendor.data.running = false
	end
	
	ArkInventory.ThreadStart( thread_id, thread_func )
	
end


ArkInventory.Action.Delete = { data = actiondata.delete }

function ArkInventory.Action.Delete.Check( blizzard_id, slot_id, codex )
	
	local isMatch, vendorPrice = ArkInventory.Action.Vendor.Check( codex, blizzard_id, slot_id, true, true )
	
	--ArkInventory.Output( "vendor check [", isMatch, "] [", vendorPrice, "]" )
	
	if isMatch and vendorPrice ~= 0 then
		isMatch = false
	end
	
	
	return isMatch
	
end

function ArkInventory.Action.Delete.Iterate( )
	
	local loc_id_window = ArkInventory.Const.Location.Bag
	local loc_data = ArkInventory.Global.Location[loc_id_window]
	
	local codex = ArkInventory.Codex.GetPlayer( loc_id_window )
	
	local bags = ArkInventory.Util.MapGetWindow( loc_id_window )
	local bag_id_window = 1
	local slot_id = 0
	
	local isMatch, blizzard_id, isLocked, itemCount, itemLink
	
	
	return function( )
		
		isMatch = false
		blizzard_id = nil
		itemLink = nil
		itemCount = 0
		
		while not isMatch do
			
			if slot_id < ( loc_data.maxSlot[bag_id_window] or 0 ) then
				
				slot_id = slot_id + 1
				
			elseif bag_id_window < #bags then
				
				bag_id_window = bag_id_window + 1
				slot_id = 1
				
			else
				
				return
				
			end
			
			--ArkInventory.Output( "delete check [", loc_id_window, "].[", bag_id_window, "].[", slot_id, "]" )
			
			local map = ArkInventory.Util.MapGetWindow( loc_id_window, bag_id_window )
			blizzard_id = map.blizzard_id
			
			local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
			itemCount = itemInfo.stackCount
			isLocked = itemInfo.isLocked
			itemLink = itemInfo.hyperlink
			
			if itemCount and not isLocked and itemLink then
				isMatch = ArkInventory.Action.Delete.Check( blizzard_id, slot_id, codex )
			end
			
		end
		
		return blizzard_id, slot_id, itemLink, itemCount
		
	end
	
end

function ArkInventory.Action.Delete.Ready( manual )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	if ArkInventory.Action.Delete.data.conflict then return end
	
	if not ArkInventory.db.option.action.delete.enable then return end
	
	if InCombatLockdown( ) then return end
	
	if not manual then return end
	
	if ArkInventory.Action.Delete.data.running then
		ArkInventory.OutputWarning( string.format( ArkInventory.Localise["CONFIG_ACTION_RUNNING"], ArkInventory.Localise["CONFIG_ACTION_DELETE"] ) )
		return
	end
	
	return true
	
end

function ArkInventory.Action.Delete.Thread( manual )
	
	local limit = ArkInventory.Action.Delete.data.limit
	
	
	-- build the queue
	local queue = { }
	for blizzard_id, slot_id, itemLink, itemCount in ArkInventory.Action.Delete.Iterate( ) do
		table.insert( queue, { blizzard_id, slot_id, itemLink, itemCount } )
	end
	
	local qsize = ArkInventory.Table.Elements( queue )
	local runtype = ArkInventory.Localise["AUTOMATIC"]
	if manual then
		runtype = ArkInventory.Localise["MANUAL"]
	end
	
	if manual or qsize > 0 then
		if ArkInventory.db.option.action.delete.list then
			ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_BOOKEND"], ArkInventory.Localise["ACTION"], ArkInventory.Localise["CONFIG_ACTION_DELETE"], runtype, ArkInventory.Localise["START"] ) )
		end
	end
	
	local test = ""
	if ArkInventory.db.option.action.delete.test then
		test = string.format( "(%s)", ArkInventory.Localise["CONFIG_ACTION_TESTING"] )
	end
	
	
	-- process queue
	for index, item in ipairs( queue ) do
		
		if InCombatLockdown( ) then
			ArkInventory.OutputWarning( string.format( ArkInventory.Localise["CONFIG_ACTION_ABORT_COMBAT"], ArkInventory.Localise["CONFIG_ACTION_DELETE"] ) )
			break
		end
		
		if index <= limit then
			
			if not ArkInventory.db.option.action.delete.test then
				ArkInventory.CrossClient.PickupContainerItem( item[1], item[2] )
				DeleteCursorItem( )
			end
			
			if ArkInventory.db.option.action.delete.list then
				ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_DELETE_LIST"], test, item[3], item[4] ) )
			end
			
		else
			
			break -- dont process more than the limit
			
		end
		
	end
	
	if manual or qsize > 0 then
		if ArkInventory.db.option.action.delete.list then
			ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_BOOKEND"], ArkInventory.Localise["ACTION"], ArkInventory.Localise["CONFIG_ACTION_DELETE"], runtype, ArkInventory.Localise["COMPLETE"] ) )
		end
	end
	
	if qsize > 0 then
		if ArkInventory.db.option.action.vendor.test then
			ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.Localise["CONFIG_ACTION_DELETE_TEST"] )
		end
	end
	
	if manual and limit > 0 and qsize > limit then
		ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, string.format( ArkInventory.Localise["CONFIG_ACTION_DELETE_MORE"], qsize - limit ) )
	end
	
end

function ArkInventory.Action.Delete.Run( manual )
	
	if not ArkInventory.Action.Delete.Ready( manual ) then return end
	
	
	ArkInventory.Action.Delete.Thread( manual )
	
end


ArkInventory.Action.Mail = { data = actiondata.mail }

function ArkInventory.Action.Mail.Check( i, codex, manual )
	
	local recipient = nil
	local info = i.info or ArkInventory.GetObjectInfo( i.h, i )
	
	if codex and i and i.h and i.sb ~= ArkInventory.ENUM.ITEM.BINDING.PICKUP and info.q <= ArkInventory.db.option.action.mail.raritycutoff then
		
		local info = i.info or ArkInventory.GetObjectInfo( i.h )
		if info.ready and info.id then
			
			local cat_id = ArkInventory.ItemCategoryGet( i )
			local cat_type, cat_num = ArkInventory.CategoryIdSplit( cat_id )
			
			local action = codex.catset.ca[cat_type][cat_num].action
			if action.t == ArkInventory.ENUM.ACTION.TYPE.MAIL then
				
				if action.w == ArkInventory.ENUM.ACTION.WHEN.AUTO then
					recipient = action.recipient
				elseif manual and action.w == ArkInventory.ENUM.ACTION.WHEN.MANUAL then
					recipient = action.recipient
				end
				
				if recipient then
					local me = string.gsub( codex.player.current, "%s+", "" )
					me = string.lower( me )
					
					if recipient == me then
						recipient = nil
					end
					
				end
				
			end
			
		end
		
	end
	
	return recipient
	
end

function ArkInventory.Action.Mail.Iterate( manual )
	
	local loc_id_window = ArkInventory.Const.Location.Bag
	local loc_data = ArkInventory.Global.Location[loc_id_window]
	
	local codex = ArkInventory.Codex.GetPlayer( loc_id_window )
	
	local bags = ArkInventory.Util.MapGetWindow( loc_id_window )
	local bag_id_window = 1
	local slot_id = 0
	
	local recipient, blizzard_id, isLocked, itemCount, itemLink
	
	
	return function( )
		
		recipient = nil
		blizzard_id = nil
		itemLink = nil
		itemCount = 0
		
		while not recipient do
			
			if slot_id < ( loc_data.maxSlot[bag_id_window] or 0 ) then
				
				slot_id = slot_id + 1
				
			elseif bag_id_window < #bags then
				
				bag_id_window = bag_id_window + 1
				slot_id = 1
				
			else
				
				return
				
			end
			
			--ArkInventory.Output( "mail check [", loc_id_window, "].[", bag_id_window, "].[", slot_id, "]" )
			
			local map = ArkInventory.Util.MapGetWindow( loc_id_window, bag_id_window )
			blizzard_id = map.blizzard_id
			
			--ArkInventory.Output( "mail check [", blizzard_id, "].[", slot_id, "]" )
			
			local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
			itemCount = itemInfo.stackCount
			isLocked = itemInfo.isLocked
			itemLink = itemInfo.hyperlink
			
			if itemCount and not isLocked and itemLink then
				local loc_id_storage = map.loc_id_storage
				local bag_id_storage = map.bag_id_storage
				local storage = ArkInventory.Codex.GetStorage( nil, loc_id_storage )
				local bag = storage.data.location[loc_id_storage].bag[bag_id_storage]
				local i = bag.slot[slot_id]
				recipient = ArkInventory.Action.Mail.Check( i, codex, manual )
			end
			
		end
		
		return recipient, blizzard_id, slot_id, itemLink, itemCount
		
	end
	
end

function ArkInventory.Action.Mail.Ready( manual )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	if not ArkInventory.Global.Mode.Mailbox then return end
	
	if ArkInventory.Action.Mail.data.conflict then return end
	
	if not ArkInventory.db.option.action.mail.enable then return end
	
	if ArkInventory.Action.Mail.data.bypass then return end
	
	if InCombatLockdown( ) then return end
	
	if not ArkInventory.Global.Thread.Use then
		ArkInventory.OutputWarning( ArkInventory.Localise["CONFIG_ACTION_MAIL"], " aborted, as threads are currently disabled." )
		return
	end
	
	if ArkInventory.CrossClient.TimerunningSeasonID( ) > 0 then
		if manual then
			ArkInventory.OutputWarning( ArkInventory.Localise["CONFIG_ACTION_MAIL"], " aborted, you are timerunning." )
		end
		return
	end
	
	if manual then
		if not ArkInventory.db.option.action.mail.manual then return end
	else
		if not ArkInventory.db.option.action.mail.auto then return end
	end
	
	if ArkInventory.Action.Mail.data.running then
		ArkInventory.OutputWarning( string.format( ArkInventory.Localise["CONFIG_ACTION_RUNNING"], ArkInventory.Localise["CONFIG_ACTION_MAIL"] ) )
		return
	end
	
	
	return true
	
end

function ArkInventory.Action.Mail.Process( thread_id, recipient, batch )
	
	local test = ""
	if ArkInventory.db.option.action.mail.test then
		test = string.format( "(%s)", ArkInventory.Localise["CONFIG_ACTION_TESTING"] )
	end
	
	if ArkInventory.db.option.action.mail.list then
		ArkInventory.Output( test, " Sending message #", batch )
	end
	
	if ArkInventory.db.option.action.mail.test then
		ArkInventory.Action.Mail.data.status = true
	else
		ArkInventory.Action.Mail.data.status = nil
		SendMail( recipient, "Mail Action for category in ArkInventory", "" )
	end
	
	--do until true
	for c = 1, ArkInventory.db.option.thread.timeout.mailsend do
		ArkInventory.ThreadYield( thread_id )
		if ArkInventory.Action.Mail.data.status ~= nil then
			ArkInventory.OutputDebug( "Exited wait for send on pass ", c, " of ", ArkInventory.db.option.action.mail.timeout )
			break
		end
	end
	
	-- check result of send
	
	if ArkInventory.Action.Mail.data.status == true then
		
		if ArkInventory.db.option.action.mail.list then
			ArkInventory.Output( "Message #", batch, " was successful" )
		end
		
		return true
		
	elseif ArkInventory.Action.Mail.data.status == false then
		
		if ArkInventory.db.option.action.mail.list then
			ArkInventory.OutputError( "Message #", batch, " failed to send" )
		end
		
	else
		
		ArkInventory.OutputError( "Send did not succeed, or fail, still in progress??" )
		
	end
	
end

function ArkInventory.Action.Mail.Thread( thread_id, manual )
	
	local limit = ArkInventory.Action.Mail.data.limit
	local batch = 0
	local total = 0
	local index = 0
	
	ArkInventory.Action.Mail.data.status = nil
	
	
	-- build queue
	local queue = { }
	for recipient, blizzard_id, slot_id, itemLink, itemCount in ArkInventory.Action.Mail.Iterate( manual ) do
		if not queue[recipient] then
			queue[recipient] = { }
		end
		table.insert( queue[recipient], { blizzard_id, slot_id, itemLink, itemCount } )
	end
	
	local qsize = ArkInventory.Table.Elements( queue )
	local runtype = ArkInventory.Localise["AUTOMATIC"]
	if manual then
		runtype = ArkInventory.Localise["MANUAL"]
	end
	
	if manual or qsize > 0 then
		if ArkInventory.db.option.action.mail.list then
			ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_BOOKEND"], ArkInventory.Localise["ACTION"], ArkInventory.Localise["CONFIG_ACTION_MAIL"], runtype, ArkInventory.Localise["START"] ) )
		end
	end
	
	local test = ""
	if ArkInventory.db.option.action.mail.test then
		test = string.format( "(%s)", ArkInventory.Localise["CONFIG_ACTION_TESTING"] )
	end
	
	-- process queue by recipient
	for recipient, items in pairs( queue ) do
		
		if ArkInventory.db.option.action.mail.list then
			ArkInventory.Output( ArkInventory.Localise["RECIPIENT"], ": ", recipient )
		end
		
		for _, item in pairs( items ) do
			
			if ArkInventory.Global.Mode.Mailbox then
				
				index = index + 1
				total = total + 1
				
				if index <= limit then
					
					if not ArkInventory.db.option.action.mail.test then
						--ArkInventory.Output( index, ": ", item )
						ArkInventory.CrossClient.PickupContainerItem( item[1], item[2] )
						ClickSendMailItemButton( )
					end
					
					if ArkInventory.db.option.action.mail.list then
						ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_MAIL_LIST_ATTATCH"], test, index, item[3], item[4] ) )
					end
					
				else
					
					batch = batch + 1
					
					if not ArkInventory.Action.Mail.Process( thread_id, recipient, batch ) then
						break
					end
					
					index = 0
					
				end
				
			end
			
		end
		
		if ArkInventory.Global.Mode.Mailbox then
			if index > 0 and index <= limit then
				batch = batch + 1
				ArkInventory.Action.Mail.Process( thread_id, recipient, batch )
				index = 0
			end
		end
		
	end
	
	if total > 0 then
		if ArkInventory.db.option.action.mail.list then
			ArkInventory.Output( total, " items sent in ", batch, " messages" )
		end
	end
	
	if manual or qsize > 0 then
		if ArkInventory.db.option.action.mail.list then
			ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_BOOKEND"], ArkInventory.Localise["ACTION"], ArkInventory.Localise["CONFIG_ACTION_MAIL"], runtype, ArkInventory.Localise["COMPLETE"] ) )
		end
	end
	
	if qsize > 0 then
		if ArkInventory.db.option.action.mail.test then
			ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.Localise["CONFIG_ACTION_MAIL_TEST"] )
		end
	end
	
end

function ArkInventory.Action.Mail.Run( manual )
	
	if not ArkInventory.Action.Mail.Ready( manual ) then return end
	
	
	local thread_id = ArkInventory.Global.Thread.Format.ActionMail
	
	local thread_func = function( )
		ArkInventory.Action.Mail.data.running = true
		ArkInventory.Action.Mail.Thread( thread_id, manual )
		ArkInventory.Action.Mail.data.running = false
	end
	
	ArkInventory.ThreadStart( thread_id, thread_func )
	
end


ArkInventory.Action.Use = { data = actiondata.use }

function ArkInventory.Action.Use.Check( itemID, manual )
	
	local isMatch = false
	
	if ArkInventory.db.option.action.use.item[itemID] then
		isMatch = true
	end
	
	return isMatch
	
end

function ArkInventory.Action.Use.Iterate( manual )
	
	local loc_id_window = ArkInventory.Const.Location.Bag
	local loc_data = ArkInventory.Global.Location[loc_id_window]
	
	local codex = ArkInventory.Codex.GetPlayer( loc_id_window )
	
	local bags = ArkInventory.Util.MapGetWindow( loc_id_window )
	local bag_id_window = 1
	local slot_id = 0
	
	local isMatch, blizzard_id, isLocked, itemID, itemLink
	
	
	return function( )
		
		isMatch = false
		blizzard_id = nil
		itemLink = nil
		
		while not isMatch do
			
			if slot_id < ( loc_data.maxSlot[bag_id_window] or 0 ) then
				
				slot_id = slot_id + 1
				
			elseif bag_id_window < #bags then
				
				bag_id_window = bag_id_window + 1
				slot_id = 1
				
			else
				
				return
				
			end
			
			--ArkInventory.Output( "use check [", loc_id_window, "].[", bag_id_window, "].[", slot_id, "]" )
			
			local map = ArkInventory.Util.MapGetWindow( loc_id_window, bag_id_window )
			blizzard_id = map.blizzard_id
			
			local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
			isLocked = itemInfo.isLocked
			itemID = itemInfo.itemID
			itemLink = itemInfo.hyperlink
			
			if not isLocked and itemID and itemLink then
				isMatch = ArkInventory.Action.Use.Check( itemID, manual )
			end
			
		end
		
		return blizzard_id, slot_id, itemID, itemLink
		
	end
	
end

function ArkInventory.Action.Use.Thread( thread_id, manual )
	
	local limit = ArkInventory.Action.Use.data.limit
	
	
	-- build the queue
	local queue = { }
	for blizzard_id, slot_id, itemID, itemLink in ArkInventory.Action.Use.Iterate( manual ) do
		table.insert( queue, { blizzard_id, slot_id, itemID, itemLink } )
	end
	
	local qsize = ArkInventory.Table.Elements( queue )
	limit = qsize
	
	local runtype = ArkInventory.Localise["AUTOMATIC"]
	if manual then
		runtype = ArkInventory.Localise["MANUAL"]
	end
	
	local test = ""
	if ArkInventory.db.option.action.vendor.test then
		test = string.format( "(%s)", ArkInventory.Localise["CONFIG_ACTION_TESTING"] )
	end
	
	if manual and qsize > 0 and ArkInventory.db.option.action.use.list then
		ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_BOOKEND"], ArkInventory.Localise["ACTION"], ArkInventory.Localise["CONFIG_ACTION_USE"], runtype, ArkInventory.Localise["START"] ) )
	end
	
	-- process the queue
	for index, item in ipairs( queue ) do
		
		if InCombatLockdown( ) then
			
			if not ArkInventory.Action.Use.data.combatnotify then
				ArkInventory.Action.Use.data.combatnotify = true
				ArkInventory.OutputWarning( string.format( ArkInventory.Localise["CONFIG_ACTION_ABORT_COMBAT"], ArkInventory.Localise["CONFIG_ACTION_USE"] ) )
			end
			
			if not manual then
				ArkInventory.Action.Use.data.runaftercombat = true
			end
			
			break
			
		else
			
			ArkInventory.Action.Use.data.combatnotify = nil
			
		end
		
		if ArkInventory.Global.Mode.Loot then
			
			if manual then
				
				ArkInventory.OutputWarning( string.format( ArkInventory.Localise["CONFIG_ACTION_AFTER_LOOTING"], ArkInventory.Localise["CONFIG_ACTION_USE"] ) )
				
			else
				
				ArkInventory.Action.Use.data.runafterlooting = true
				
				if not ArkInventory.Action.Use.data.lootnotify then
					ArkInventory.Action.Use.data.lootnotify = true
					ArkInventory.OutputDebug( ArkInventory.Localise["CONFIG_ACTION_USE"], " has been paused, and will resume once you have completed looting" )
				end
				
				break
				
			end
			
		else
			
			ArkInventory.Action.Use.data.lootnotify = nil
			
		end
		
		if not ArkInventory.db.option.action.use.test then
			ArkInventory.CrossClient.UseContainerItem( item[1], item[2] )
			ArkInventory.ThreadYield( thread_id )
		end
		
		if ArkInventory.db.option.action.use.list then
			ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_USE_LIST"], test, item[4] ) )
		end
		
	end
	
	
	if manual and qsize > 0 and ArkInventory.db.option.action.use.list then
		ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_BOOKEND"], ArkInventory.Localise["ACTION"], ArkInventory.Localise["CONFIG_ACTION_USE"], runtype, ArkInventory.Localise["COMPLETE"] ) )
	end
	
end

function ArkInventory.Action.Use.Ready( manual )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	if ArkInventory.Action.Use.data.conflict then return end
	
	if not ArkInventory.db.option.action.use.enable then return end
	
	if InCombatLockdown( ) then return end
	
	if manual then
		if not ArkInventory.db.option.action.use.manual then return end
	else
		if not ArkInventory.db.option.action.use.auto then return end
	end
	
	if ArkInventory.Action.Use.data.running then
		ArkInventory.OutputWarning( string.format( ArkInventory.Localise["CONFIG_ACTION_RUNNING"], ArkInventory.Localise["CONFIG_ACTION_USE"] ) )
		return
	end
	
	
	return true
	
end

function ArkInventory.Action.Use.Run( manual )
	
	if not ArkInventory.Action.Use.Ready( manual ) then return end
	
	
	local thread_id = ArkInventory.Global.Thread.Format.ActionUse
	
	local thread_func = function( )
		ArkInventory.Action.Use.data.running = true
		ArkInventory.Action.Use.Thread( thread_id, manual )
		ArkInventory.Action.Use.data.running = false
	end
	
	ArkInventory.ThreadStart( thread_id, thread_func )
	
end


ArkInventory.Action.Scrap = { data = actiondata.scrap }

function ArkInventory.Action.Scrap.Check( i, codex, manual )
	
	local isMatch = false
	
	local blizzard_id = ArkInventory.Util.getBlizzardBagIdFromWindowId( i.loc_id, i.bag_id )
	local blizzardLocation = ItemLocation:CreateFromBagAndSlot( blizzard_id, i.slot_id )
	
	if C_Item.CanScrapItem( blizzardLocation ) then
		
		local info = i.info or ArkInventory.GetObjectInfo( i.h, i )
		
		if codex and i and i.h and info.q <= ArkInventory.db.option.action.scrap.raritycutoff then
			
			local info = i.info or ArkInventory.GetObjectInfo( i.h )
			if info.ready and info.id then
				
				local cat_id = ArkInventory.ItemCategoryGet( i )
				local cat_type, cat_num = ArkInventory.CategoryIdSplit( cat_id )
				
				local action = codex.catset.ca[cat_type][cat_num].action
				if action.t == ArkInventory.ENUM.ACTION.TYPE.SCRAP then
					
					if action.w == ArkInventory.ENUM.ACTION.WHEN.AUTO then
						isMatch = true
					elseif manual and action.w == ArkInventory.ENUM.ACTION.WHEN.MANUAL then
						isMatch = true
					end
					
				end
				
			end
			
		end
		
	end
	
	return isMatch
	
end

function ArkInventory.Action.Scrap.Iterate( manual )
	
	local loc_id_window = ArkInventory.Const.Location.Bag
	local loc_data = ArkInventory.Global.Location[loc_id_window]
	
	local codex = ArkInventory.Codex.GetPlayer( loc_id_window )
	
	local bags = ArkInventory.Util.MapGetWindow( loc_id_window )
	local bag_id_window = 1
	local slot_id = 0
	
	local recipient, blizzard_id, isLocked, itemLink
	
	
	return function( )
		
		isMatch = false
		blizzard_id = nil
		itemLink = nil
		
		while not isMatch do
			
			if slot_id < ( loc_data.maxSlot[bag_id_window] or 0 ) then
				
				slot_id = slot_id + 1
				
			elseif bag_id_window < #bags then
				
				bag_id_window = bag_id_window + 1
				slot_id = 1
				
			else
				
				return
				
			end
			
			--ArkInventory.Output( "scrap check [", loc_id_window, "].[", bag_id_window, "].[", slot_id, "]" )
			
			local map = ArkInventory.Util.MapGetWindow( loc_id_window, bag_id_window )
			blizzard_id = map.blizzard_id
			
			local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
			itemCount = itemInfo.stackCount
			isLocked = itemInfo.isLocked
			itemLink = itemInfo.hyperlink
			
			if itemCount and not isLocked and itemLink then
				local loc_id_storage = map.loc_id_storage
				local bag_id_storage = map.bag_id_storage
				local storage = ArkInventory.Codex.GetStorage( nil, loc_id_storage )
				local bag = storage.data.location[loc_id_storage].bag[bag_id_storage]
				local i = bag.slot[slot_id]
				isMatch = ArkInventory.Action.Scrap.Check( i, codex, manual )
			end
			
		end
		
		return blizzard_id, slot_id, itemLink
		
	end
	
end

function ArkInventory.Action.Scrap.Thread( thread_id, manual )
	
	ArkInventory.Action.Scrap.data.status = nil
	local limit = ArkInventory.Action.Scrap.data.limit
	
	
	-- build queue
	local queue = { }
	for blizzard_id, slot_id, itemLink in ArkInventory.Action.Scrap.Iterate( manual ) do
		table.insert( queue, { blizzard_id, slot_id, itemLink } )
	end
	
	local qsize = ArkInventory.Table.Elements( queue )
	local runtype = ArkInventory.Localise["AUTOMATIC"]
	if manual then
		runtype = ArkInventory.Localise["MANUAL"]
	end
	
	if manual or qsize > 0 then
		if ArkInventory.db.option.action.scrap.list then
			ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_BOOKEND"], ArkInventory.Localise["ACTION"], ArkInventory.Localise["CONFIG_ACTION_SCRAP"], runtype, ArkInventory.Localise["START"] ) )
		end
	end
	
	local test = ""
	if ArkInventory.db.option.action.scrap.test then
		test = string.format( "(%s)", ArkInventory.Localise["CONFIG_ACTION_TESTING"] )
	end
	
	local name = C_ScrappingMachineUI.GetScrappingMachineName( )
	
	-- process queue
	for index, item in ipairs( queue ) do
		
		if InCombatLockdown( ) then
			ArkInventory.OutputWarning( string.format( ArkInventory.Localise["CONFIG_ACTION_ABORT_COMBAT"], ArkInventory.Localise["CONFIG_ACTION_SCRAP"] ) )
			return
		end
		
		if not ArkInventory.Global.Mode.Scrap then
			break
		end
		
		if ArkInventory.CrossClient.IsCurrentSpell( ArkInventory.Action.Scrap.data.spellID ) then
			-- aborted, scrapping in progress
			break
		end
		
		if index == 0 then
			C_ScrappingMachineUI.RemoveAllScrapItems( )
			ArkInventory.ThreadYield( thread_id )
		end
		
		if index <= limit then
			
			if not ArkInventory.db.option.action.scrap.test then
				ArkInventory.Action.Scrap.data.wait = true
				ArkInventory.CrossClient.UseContainerItem( item[1], item[2] )
				ArkInventory.ThreadYield( thread_id )
			end
			
			if ArkInventory.db.option.action.scrap.list then
				ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_SCRAP_LIST"], test, name, item[3] ) )
			end
			
		else
			
			break -- dont process more than the limit
			
		end
		
	end
	
	ArkInventory.ThreadYield( thread_id )
	C_ScrappingMachineUI.ValidateScrappingList( )
	ArkInventory.ThreadYield( thread_id )
	
	if manual or qsize > 0 then
		if ArkInventory.db.option.action.scrap.list then
			ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_ACTION_BOOKEND"], ArkInventory.Localise["ACTION"], ArkInventory.Localise["CONFIG_ACTION_SCRAP"], runtype, ArkInventory.Localise["COMPLETE"] ) )
		end
	end
	
	if qsize > 0 then
		if ArkInventory.db.option.action.scrap.test then
			ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.Localise["CONFIG_ACTION_SCRAP_TEST"] )
		end
	end
	
	if manual and limit > 0 and qsize > limit then
		ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, string.format( ArkInventory.Localise["CONFIG_ACTION_SCRAP_MORE"], qsize - limit ) )
	end
	
end

function ArkInventory.Action.Scrap.Ready( manual )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	if not ArkInventory.Global.Mode.Scrap then return end
	
	if ArkInventory.Action.Scrap.data.conflict then return end
	
	if not ArkInventory.db.option.action.scrap.enable then return end
	
	if ArkInventory.Action.Scrap.data.bypass then return end
	
	if ArkInventory.Action.Scrap.data.wait then return end
	
	if InCombatLockdown( ) then return end
	
	
	if manual then
		if not ArkInventory.db.option.action.scrap.manual then return end
	else
		if not ArkInventory.db.option.action.scrap.auto then return end
	end
	
	if ArkInventory.Action.Scrap.data.running then
		ArkInventory.OutputWarning( string.format( ArkInventory.Localise["CONFIG_ACTION_RUNNING"], ArkInventory.Localise["CONFIG_ACTION_SCRAP"] ) )
		return
	end
	
	
	return true
	
end

function ArkInventory.Action.Scrap.Run( manual )
	
	if not ArkInventory.Action.Scrap.Ready( manual ) then return end
	
	
	local thread_id = ArkInventory.Global.Thread.Format.ActionScrap
	
	local thread_func = function( )
		ArkInventory.Action.Scrap.data.running = true
		ArkInventory.Action.Scrap.Thread( thread_id, manual )
		ArkInventory.Action.Scrap.data.running = false
	end
	
	ArkInventory.ThreadStart( thread_id, thread_func )
	
end


function ArkInventory.Action.ManualRun( )
	
	if ArkInventory.Global.Mode.Mailbox then
		ArkInventory.Action.Mail.Run( true )
	elseif ArkInventory.Global.Mode.Bank then
		--ArkInventory.Action.Bag.Transfer( true )
		--ArkInventory.Action.Bank.Transfer( true )
	elseif ArkInventory.Global.Mode.Merchant then
		ArkInventory.Action.Vendor.Run( true )
	elseif ArkInventory.Global.Mode.Scrap then
		ArkInventory.Action.Scrap.Run( true )
	else
		ArkInventory.Action.Use.Run( true )
		ArkInventory.Action.Delete.Run( true )
	end
	
end

