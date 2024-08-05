local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


local function Restack_Yield( loc_id )
	ArkInventory.ThreadYield( ArkInventory.Global.Thread.Format.Restack )
end

function ArkInventory.RestackString( )
	return ArkInventory.Const.ButtonData[ArkInventory.ENUM.BUTTONID.Restack].Name( )
end

local function RestackMessageStart( loc_id )
	
	if ArkInventory.db.option.message.restack[loc_id] then
		ArkInventory.Output( ArkInventory.RestackString( ), ": ", ArkInventory.Global.Location[loc_id].Name, " - " , ArkInventory.Localise["START"] )
	end
	
end

local function RestackMessageComplete( loc_id )
	
	if ArkInventory.db.option.message.restack[loc_id] then
		ArkInventory.Output( ArkInventory.RestackString( ), ": ", ArkInventory.Global.Location[loc_id].Name, " - " , ArkInventory.Localise["COMPLETE"] )
	end
	
	if ArkInventory.db.option.restack.refresh then
		--ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
	end
	
end

local function RestackMessageAbort( loc1, loc2 )
	
	local loc2 = loc2 or loc1
	
	if loc1 == loc2 then
		ArkInventory.OutputWarning( ArkInventory.RestackString( ), ": ", ArkInventory.Global.Location[loc1].Name, " - ", ArkInventory.Localise["ABORTED"] )
	else
		ArkInventory.OutputWarning( ArkInventory.RestackString( ), ": ", ArkInventory.Global.Location[loc1].Name, " - ", ArkInventory.Localise["ABORTED"], ": ", string.format( ArkInventory.Localise["RESTACK_FAIL_CLOSED"], ArkInventory.Global.Location[loc2].Name ) )
	end
	
end

local function RestackBagCheck( blizzard_id )
	
	local abort = false
	local numSlots = ArkInventory.CrossClient.GetContainerNumSlots( blizzard_id )
	local numFreeSlots, bagFamily = ArkInventory.CrossClient.GetContainerNumFreeSlots( blizzard_id )
	
	local map = ArkInventory.Util.MapGetBlizzard( blizzard_id )
	
	if map.loc_id_storage == ArkInventory.Const.Location.ReagentBank and not ArkInventory.CrossClient.IsReagentBankUnlocked( ) then
		-- reagent bank always returns its number of slots even if you havent unlocked it
		numSlots = 0
		numFreeSlots = 0
	end
	
	if map.loc_id_storage == ArkInventory.Const.Location.AccountBank then
		-- we are not touching the account bank yet so just abort
		abort = map.loc_id_window
	end
	
	if ( map.loc_id_window == ArkInventory.Const.Location.Bank and not ArkInventory.Global.Mode.Bank ) or ( map.loc_id_window == ArkInventory.Const.Location.Vault and not ArkInventory.Global.Mode.Vault ) then
		-- no longer at the location
		--ArkInventory.OutputWarning( "aborting, no longer at location" )
		abort = map.loc_id_window
	end
	
	return abort, bagFamily or 0, numSlots or 0
	
end


local function FindItem( loc_id, cl, cb, bp, cs, id, ct )
	
	-- working from left to right
	-- find the matching item in your bag
	
	--ArkInventory.OutputDebug( "FindItem( ", loc_id, ", ", cl, ".", cb, ".", cs, ", ", id, " )" )
	
	local me = ArkInventory.Codex.GetPlayer( )
	local abort = false
	local recheck = false
	
	local cl = cl or loc_id
	local cb = cb or 9999
	local bp = bp or -1
	local cs = cs or -1
	local ct = ct or 0
	
	
	for bag_pos, map in ipairs( ArkInventory.Util.MapGetWindow( loc_id ) ) do
		
		local blizzard_id = map.blizzard_id
		
		if not me.player.data.option[loc_id].bag[bag_pos].restack.ignore then
			
			Restack_Yield( cl )
			
			local ab, bt, count = RestackBagCheck( blizzard_id )
			if ab then
				return cl, recheck, false
			end
			
			local ok
			
			for slot_id = 1, count do
				
				ok = false
				
				if RestackBagCheck( blizzard_id ) then
					return cl, recheck, false
				end
				
				if loc_id ~= cl then
					--ArkInventory.OutputDebug( "different location" )
					ok = true
				elseif loc_id == cl and bag_pos < bp then
					--ArkInventory.OutputDebug( "same location and lower bag" )
					ok = true
				elseif loc_id == cl and bag_pos == bp and slot_id < cs then
					--ArkInventory.OutputDebug( "same location and same bag and lower slot" )
					ok = true
				elseif ( ct ~= 0 and bag_pos ~= bp and bt == 0 ) and ( map.loc_id_storage ~= ArkInventory.Const.Location.ReagentBank ) then
					--ArkInventory.OutputDebug( "full scan (bag type) and different bag and normal bag" )
					-- not at the bank?
					-- not the reagent bank (or it will loop endlessly)
					ok = true
				end
				
				if ok then
					
					local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
					if itemInfo.isLocked then
						-- this slot is locked, move on and check it again next time
						--ArkInventory.Output( "locked> ", loc_id, ".", blizzard_id, ".", slot_id )
						recheck = true
						
					else
						
						if itemInfo.hyperlink then
							
							local osd = ArkInventory.ObjectStringDecode( itemInfo.hyperlink )
							
							if osd.id == id then
								
								--ArkInventory.OutputDebug( "found> ", loc_id, ".", blizzard_id, ".", slot_id )
								return abort, recheck, true, blizzard_id, slot_id
								
							end
							
						end
						
					end
					
				end
				
			end
		
		end
		
	end
	
	if recheck then
		return FindItem( loc_id, cl, cb, bp, cs, id, ct )
	end
	
	if loc_id == ArkInventory.Const.Location.Bank and ArkInventory.db.option.restack.topup then
		-- we were restacking the bank and found nothing
		-- now checking the bags because topup is enabled
		return FindItem( ArkInventory.Const.Location.Bag, cl, cb, bp, cs, id, ct )
	end
	
	--ArkInventory.Output( "no stacks found" )
	return abort, recheck, false
	
end

local function FindPartialStack( loc_id, cl, cb, bp, cs, id )
	
	-- loc_id = location to search in for partial stack to pull from
	-- cl = current location of partial stack to fill
	-- cb = current bag of partial stack to fill
	-- bp = bag position in the food chain, can only pull from lower bags
	-- cs = current slot of partial stack to fill
	-- id = item id to search for
	
	--ArkInventory.OutputDebug( "FindPartialStack( ", loc_id, " / ", cl, ".", cb, "(", bp, ").", cs, " / ", id, " )" )
	
	local me = ArkInventory.Codex.GetPlayer( )
	local abort = false
	local recheck = false
	
	local cl = cl or loc_id
	local cb = cb or 9999
	local bp = bp or -1
	local cs = cs or -1
	
	
	if cl == ArkInventory.Const.Location.Vault then
		
		Restack_Yield( cl )
		
		local tab_id = cb
		
		for slot_id = 1, ArkInventory.Const.BLIZZARD.GLOBAL.GUILDBANK.SLOTS_PER_TAB do
			
			if not ArkInventory.Global.Mode.Vault or tab_id ~= GetCurrentGuildBankTab( ) then
				-- no longer at the vault or changed tabs, abort
				--ArkInventory.OutputWarning( "aborting, no longer at location" )
				abort = cl
				return abort, recheck, false
			end
			
			if slot_id < cs then
				
				if select( 3, GetGuildBankItemInfo( tab_id, slot_id ) ) then
					
					-- this slot is locked, move on and check it again next time
					--ArkInventory.OutputDebug( "locked> ", loc_id, ".", tab_id, ".", slot_id )
					recheck = true
					
				else
					
					local h = GetGuildBankItemLink( tab_id, slot_id )
					
					if h then
						
						local info = ArkInventory.GetObjectInfo( h )
						
						if info.id == id then
						
							local count = select( 2, GetGuildBankItemInfo( tab_id, slot_id ) )
							
							if count < info.stacksize then
								--ArkInventory.OutputDebug( "found > ", tab_id, ".", slot_id )
								return abort, recheck, true, tab_id, slot_id
							end
							
						end
						
					end
					
				end
				
			end
			
		end
		
		if recheck then
			return FindPartialStack( loc_id, cl, cb, bp, cs, id )
		end
		
		return abort, recheck, false
		
	end
	
	if cl == ArkInventory.Const.Location.Bag or cl == ArkInventory.Const.Location.Bank then
		
		for bag_pos, map in ipairs( ArkInventory.Util.MapGetWindow( loc_id ) ) do
			
			local blizzard_id = map.blizzard_id
			
			if not me.player.data.option[loc_id].bag[bag_pos].restack.ignore then
				
				Restack_Yield( cl )
				
				local ab, bt, count = RestackBagCheck( blizzard_id )
				if ab then
					return cl, recheck, false
				end
				
				for slot_id = 1, count do
					
					if RestackBagCheck( blizzard_id ) then
						return cl, recheck, false
					end
					
					if ( loc_id ~= cl ) or ( loc_id == cl and bag_pos < bp ) or ( loc_id == cl and bag_pos == bp and slot_id < cs )then
					-- ( different location ) or (same location and lower bag) or (same location and same bag and lower slot)
						
						local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
						if itemInfo.isLocked then
							
							-- this slot is locked, move on and check it again next time
							--ArkInventory.Output( "locked> ", loc_id, ".", blizzard_id, ".", slot_id )
							recheck = true
							
						else
							
							--ArkInventory.Output( "check> ", loc_id, ".", blizzard_id, ".", slot_id )
							
							if itemInfo.hyperlink then
								
								local info = ArkInventory.GetObjectInfo( itemInfo.hyperlink )
								if info.id == id then
									
									if itemInfo.stackCount < info.stacksize then
										ArkInventory.OutputDebug( "found > ", blizzard_id, ".", slot_id, " ", itemInfo.stackCount, " of ", h, " for ", cb, ".", cs )
										return abort, recheck, true, blizzard_id, slot_id
									end
									
								end
								
							end
							
						end
						
					end
					
				end
				
			end
			
		end
		
		if recheck then
			return FindPartialStack( loc_id, cl, cb, bp, cs, id )
		end
		
		local cb_map = ArkInventory.Util.MapGetBlizzard( cb )
		if cb_map.loc_id_storage == ArkInventory.Const.Location.ReagentBank then
			
			-- we were restacking the reagent bank and found nothing there
			-- need to check the bank for stacks we can take from
			
			-- reagentbank topup from bags is also done from there
			
			return FindItem( ArkInventory.Const.Location.Bank, cl, cb, bp, -1, id )
			
		end
		
		if cl == ArkInventory.Const.Location.Bank and ArkInventory.db.option.restack.topup then
			-- topup bank from bags
			return FindItem( ArkInventory.Const.Location.Bag, cl, cb, bp, cs, id )
		end
		
		return abort, recheck, false
		
	end
	
end

local function FindNormalItem( loc_id, cl, cb, bp, cs )
	
	local me = ArkInventory.Codex.GetPlayer( )
	local abort = false
	local recheck = false
	
	local cl = cl or loc_id
	local cb = cb or 9999
	local bp = bp or -1
	local cs = cs or -1
	
	for bag_pos, map in ipairs( ArkInventory.Util.MapGetWindow( loc_id ) ) do
		
		local blizzard_id = map.blizzard_id
		
		if not me.player.data.option[loc_id].bag[bag_pos].restack.ignore then
			
			Restack_Yield( cl )
			
			local ab, bt, count = RestackBagCheck( blizzard_id )
			if ab then
				return cl, recheck, false
			end
			
			if bt == 0 and map.loc_id_storage ~= ArkInventory.Const.Location.ReagentBank then
				
				for slot_id = 1, count do
					
					if RestackBagCheck( blizzard_id ) then
						return cl, recheck, false
					end
					
					if ( loc_id ~= cl ) or ( loc_id == cl and bag_pos < bp ) or ( loc_id == cl and bag_pos == bp and slot_id < cs )then
					-- ( different location ) or (same location and higher bag) or (same location and same bag and higher slot)
						
						local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
						if itemInfo.isLocked then
							
							-- this slot is locked, move on and check it again next time
							--ArkInventory.Output( "locked> ", loc_id, ".", blizzard_id, ".", slot_id )
							recheck = true
							
						else
							
							if itemInfo.hyperlink then
								--ArkInventory.Output( "found> ", loc_id, ".", blizzard_id, ".", slot_id )
								return abort, recheck, true, blizzard_id, slot_id
							end
							
						end
						
					end
					
				end
				
			end
			
		end
		
	end
	
	if recheck then
		return FindNormalItem( loc_id, cl, cb, bp, cs )
	end
	
	--ArkInventory.Output( "nothing found, all slots empty" )
	return abort, recheck, false
	
end

local function FindProfessionItem( src_loc_id, dst_loc_id, dst_blizzard_id, dst_bag_pos, dst_slot_id, dst_bag_type )
	
	local me = ArkInventory.Codex.GetPlayer( )
	local abort = false
	local recheck = false
	
	local dst_loc_id = dst_loc_id or src_loc_id -- destiantion loc_id
	local dst_blizzard_id = dst_blizzard_id or 9999 -- destination blizzard_id
	local dst_bag_pos = dst_bag_pos or -1 -- destination bag position
	local dst_slot_id = dst_slot_id or -1 -- destination slot_id
	local dst_bag_type = dst_bag_type or 0 -- destination bag type
	
	--ArkInventory.Output( "find prof item>", ArkInventory.Global.Location[src_loc_id].Name, ", ", dst_loc_id, ".", dst_blizzard_id, ".", dst_slot_id, " ", dst_bag_type )
	
	if dst_bag_type == 0 then
		ArkInventory.OutputError( "code failure: checking for profession item of type 0" )
		abort = dst_loc_id
		return abort, recheck, false
	end
	
	local restack_priority = ArkInventory.db.option.restack.priority
	if restack_priority and not ArkInventory.Global.Location[ArkInventory.Const.Location.ReagentBank].ClientCheck then
		-- the regent bank doesnt exist in this client so we turn it off
		restack_priority = false
	end
	
	-- find a profession item from one of the locations storage bags
	
	for bag_pos, map in ipairs( ArkInventory.Util.MapGetWindow( src_loc_id ) ) do
		
		local blizzard_id = map.blizzard_id
		
		local ab, bt, count = RestackBagCheck( blizzard_id )
		if ab then
			return dst_loc_id, recheck, false
		end
		
		--ArkInventory.Output( "checking ", ArkInventory.Global.Location[src_loc_id].Name, ".", blizzard_id, " type = ", bt )
		
		if not me.player.data.option[src_loc_id].bag[bag_pos].restack.ignore then
			
			Restack_Yield( dst_loc_id )
			
			local pri_ok = false
			
			--ArkInventory.Output( blizzard_id )
			
			if restack_priority then
				--ArkInventory.Output( "priority reagent bank" )
				-- priority is reagent bank
				if ( map.loc_id_storage ~= ArkInventory.Const.Location.ReagentBank ) and ( bt == 0 or bt == dst_bag_type ) then
					-- do not steal from a reagent container
					-- do not steal from a profession bag unless its for a reagent container
					pri_ok = true
				end
			else
				--ArkInventory.Output( "priority profession bag" )
				-- priority is profession bags
--				if ( map.loc_id_storage == ArkInventory.Const.Location.ReagentBank ) or ( bt == 0 or bt == dst_bag_type ) then
					--ArkInventory.Output( "search this bag> ", ArkInventory.Global.Location[src_loc_id].Name, ".", blizzard_id )
					pri_ok = true
--				end
			end
			
			--ArkInventory.Output( pri_ok, " to steal from " )
			
			if pri_ok then
				
				--ArkInventory.Output( "searching ", ArkInventory.Global.Location[src_loc_id].Name, ".", blizzard_id )
				
				for slot_id = 1, count do
					
					if RestackBagCheck( blizzard_id ) then
						return dst_loc_id, recheck, false
					end
					
					if ( src_loc_id ~= dst_loc_id ) or ( src_loc_id == dst_loc_id and bag_pos < dst_bag_pos ) or ( src_loc_id == dst_loc_id and bag_pos > dst_bag_pos and bt == 0 ) or ( src_loc_id == dst_loc_id and bag_pos == dst_bag_pos and slot_id < dst_slot_id ) then
					-- ( different location ) or (same location and lower bag) or (same location and same bag and lower slot)
						
						local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
						if itemInfo.isLocked then
							
							-- this slot is locked, move on and check it again next time
							--ArkInventory.Output( "locked> ", src_loc_id, ".", blizzard_id, ".", slot_id )
							recheck = true
							
						else
							
							--ArkInventory.Output( "chk> ", itemInfo.hyperlink )
							
							if itemInfo.hyperlink then
								
								--ArkInventory.Output( "chk> ", src_loc_id, ".", blizzard_id, ".", slot_id )
								
								-- ignore bags
								local info = ArkInventory.GetObjectInfo( itemInfo.hyperlink )
								if info.itemtypeid == ArkInventory.ENUM.ITEM.TYPE.CONTAINER.PARENT then
									
									local check_item = true
									if src_loc_id ~= dst_loc_id and not info.craft then
										-- only allow crafting reagents to be selected from bags when depositing to the bank (dont steal the pick/hammer/army knife/etc)
										check_item = false
									end
									
									if check_item then
										
										local it = ArkInventory.CrossClient.GetItemFamily( itemInfo.hyperlink ) or 0
										
										if ArkInventory.ClientCheck( ArkInventory.ENUM.EXPANSION.WRATH ) then -- FIX ME
											
											if bit.band( it, dst_bag_type ) > 0 then
												--ArkInventory.Output( "found prof> ", ArkInventory.Global.Location[src_loc_id].Name, ".", blizzard_id, ".", slot_id, " " , itemInfo.hyperlink )
												return abort, recheck, true, blizzard_id, slot_id
											end
											
										else
											
											if it == dst_bag_type then
												--ArkInventory.Output( "found prof> ", ArkInventory.Global.Location[src_loc_id].Name, ".", blizzard_id, ".", slot_id, " " , itemInfo.hyperlink )
												return abort, recheck, true, blizzard_id, slot_id
											end
											
										end
										
									end
									
								end
								
							end
							
						end
						
					end
					
				end
				
			end
			
		end
		
	end
	
	if src_loc_id == ArkInventory.Const.Location.Bank and ArkInventory.db.option.restack.bank then
		
		-- find profession item from bag
		
		local ab, rc, ok, sb, ss = FindProfessionItem( ArkInventory.Const.Location.Bag, src_loc_id, nil, nil, nil, dst_bag_type )
		
		if ab then
			abort = dst_loc_id
		end
		
		if rc then
			recheck = true
		end
		
		return abort, recheck, ok, sb, ss
		
	end
	
	--ArkInventory.Output( "no profession items found in ", ArkInventory.Global.Location[src_loc_id].Name )
	return abort, recheck, false
	
end

local function FindCraftingItem( loc_id, cl, cb, bp, cs )
	
	local me = ArkInventory.Codex.GetPlayer( )
	local abort = false
	local recheck = false
	
	local cl = cl or loc_id
	local cb = cb or 9999
	local bp = bp or -1
	local cs = cs or -1
	
	--ArkInventory.Output( "find crafting item in ", ArkInventory.Global.Location[loc_id].Name, " for slot ", ArkInventory.Global.Location[cl].Name, ".", cb, ".", cs )
	
	local restack_priority = ArkInventory.db.option.restack.priority
	if restack_priority and not ArkInventory.Const.Slot.Data[ArkInventory.Const.Slot.Type.Reagent].ClientCheck then
		-- the regent bank doesnt exist until draenor so in the older clients this stops things going to profession bags, so we turn it off
		restack_priority = false
	end
	
	for bag_pos, map in ipairs( ArkInventory.Util.MapGetWindow( loc_id ) ) do
		
		local blizzard_id = map.blizzard_id
		
		local ab, bt, count = RestackBagCheck( blizzard_id )
		if ab then
			return cl, recheck, false
		end
		
		--ArkInventory.Output( "checking ", ArkInventory.Global.Location[loc_id].Name, ".", blizzard_id, " type = ", bt )
		
		if not me.player.data.option[loc_id].bag[bag_pos].restack.ignore then
			
			Restack_Yield( cl )
			
			local pri_ok
			
			if restack_priority then
				-- priority is the reagent bank
				local cb_map = ArkInventory.Util.MapGetBlizzard( blizzard_id )
				if ( map.loc_id_storage ~= ArkInventory.Const.Location.ReagentBank ) and ( bt == 0 or cb_map.loc_id_storage == ArkInventory.Const.Location.ReagentBank ) then
					-- do not steal from a reagent container
					-- do not steal from a profession bag unless its for a reagent container
					pri_ok = true
				end
			else
				-- priority is profession bags
				if bt == 0 then
					--ArkInventory.Output( "search this bag> ", ArkInventory.Global.Location[loc_id].Name, ".", blizzard_id )
					pri_ok = true
				end
			end
			
			if pri_ok then
				
				--ArkInventory.Output( "searching ", ArkInventory.Global.Location[loc_id].Name, ".", blizzard_id )
				
				for slot_id = 1, count do
					
					if RestackBagCheck( blizzard_id ) then
						return cl, recheck, false
					end
					
					if ( loc_id ~= cl ) or ( loc_id == cl and bag_pos < bp ) or ( loc_id == cl and bag_pos == bp and slot_id < cs )then
						-- ( different location ) or (same location and higher bag) or (same location and same bag and higher slot)
						
						--ArkInventory.Output( "check> ", loc_id, ".", blizzard_id, ".", slot_id )
						
						local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
						if itemInfo.isLocked then
							
							-- this slot is locked, move on and check it again next time
							--ArkInventory.Output( "locked> ", loc_id, ".", blizzard_id, ".", slot_id )
							recheck = true
							
						else
							
							if itemInfo.hyperlink then
								
								local info = ArkInventory.GetObjectInfo( itemInfo.hyperlink )
								if info.craft then
									--ArkInventory.Output( "found> [", ArkInventory.Global.Location[loc_id].Name, ".", blizzard_id, ".", slot_id, "]" )
									return abort, recheck, true, blizzard_id, slot_id
								end
								
							end
							
						end
						
					end
					
				end
				
			else
				--ArkInventory.Output( "do not steal from ", ArkInventory.Global.Location[loc_id].Name, ".", blizzard_id )
			end
			
		else
			--ArkInventory.Output( "ignored for restack ", ArkInventory.Global.Location[loc_id].Name, ".", blizzard_id )
		end
		
		--ArkInventory.Output( "nothing found in ", ArkInventory.Global.Location[loc_id].Name, ".", blizzard_id )
		
	end
	
	if loc_id == ArkInventory.Const.Location.Bank and ArkInventory.db.option.restack.deposit then
		
		local ab, rc, ok, sb, ss = FindCraftingItem( ArkInventory.Const.Location.Bag, loc_id )
		
		if ab then
			abort = cl
		end
		
		if rc then
			recheck = true
		end
		
		return abort, recheck, ok, sb, ss
		
	end
	
	--ArkInventory.Output( "exit> no crafting items found in ", loc_id )
	return abort, recheck, false
	
end


local function StackBags( loc_id_window )
	
	-- move items into complete stacks
	
	ArkInventory.OutputDebug( "StackBags: ", ArkInventory.Global.Location[loc_id_window].Name )
	
	local codex = ArkInventory.Codex.GetPlayer( )
	
	local abort = false
	local recheck = false
	
	for bag_id_window, map in ArkInventory.rpairs( ArkInventory.Util.MapGetWindow( loc_id_window ) ) do
		
		local blizzard_id = map.blizzard_id
		
		--ArkInventory.Output( "[", loc_id_window, "].[", bag_id_window, "] - [", blizzard_id, "]" )
		
		local isAbort, bt, slot_count = RestackBagCheck( blizzard_id )
		if isAbort then
			return loc_id_window, recheck, false
		end
		
		ArkInventory.OutputDebug( "[", loc_id_window, "].[", bag_id_window, "] - [", blizzard_id, "] [", bt, "]" )
		
		if not codex.player.data.option[loc_id_window].bag[bag_id_window].restack.ignore then
			
			--ArkInventory.Output( "StackBags( ", loc_id_window, ".", blizzard_id, " )" )
			
			if slot_count > 0 then
				
				for slot_id = slot_count, 1, -1 do
					
					if RestackBagCheck( blizzard_id ) then
						return loc_id_window, recheck, false
					end
					
					Restack_Yield( loc_id_window )
					--ArkInventory.Output( "checking ", loc_id_window, ".", blizzard_id, ".", slot_id )
					
					local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
					if itemInfo.isLocked then
						
						-- this slot is locked, move on and check it again next time
						--ArkInventory.Output( "locked> ", loc_id_window, ".", blizzard_id, ".", slot_id )
						recheck = true
						
					else
						
						--ArkInventory.Output( "unlocked> ", loc_id_window, ".", blizzard_id, ".", slot_id )
						
						if itemInfo.hyperlink then
							
							local info = ArkInventory.GetObjectInfo( itemInfo.hyperlink )
							
							if itemInfo.stackCount < info.stacksize then
								
								--ArkInventory.Output( "partial stack of ", itemInfo.hyperlink, " x ", itemInfo.stackCount, " found at ", blizzard_id, ".", slot_id, " bt=", bt )
								
								local isAbort, isRecheck, ok, blizzard_id_partial, slot_id_partial
								if bt == 0 then
									isAbort, isRecheck, ok, blizzard_id_partial, slot_id_partial = FindPartialStack( loc_id_window, loc_id_window, blizzard_id, bag_id_window, slot_id, info.id )
								else
									-- non normal bag - allow it to pull from normal bags that are higher
									isAbort, isRecheck, ok, blizzard_id_partial, slot_id_partial = FindItem( loc_id_window, loc_id_window, blizzard_id, bag_id_window, slot_id, info.id, bt )
								end
								
								if isRecheck then
									recheck = true
								end
								
								if isAbort then
									return loc_id_window, recheck
								end
								
								if ok then
									
									--ArkInventory.OutputDebug( "merge> ", blizzard_id, ".", slot_id, " + ", blizzard_id_partial, ".", slot_id_partial )
									
									ClearCursor( )
									ArkInventory.CrossClient.PickupContainerItem( blizzard_id_partial, slot_id_partial )
									ArkInventory.CrossClient.PickupContainerItem( blizzard_id, slot_id )
									ClearCursor( )
									
									Restack_Yield( loc_id_window )
									
									recheck = true
									
								end
								
							end
							
						end
						
					end
					
				end
				
			end
			
		end
		
	end
	
	return abort, recheck
	
end

local function StackVault( )
	
	local loc_id = ArkInventory.Const.Location.Vault
	local tab_id = GetCurrentGuildBankTab( )
	
	local abort = false
	local recheck = false
	
	Restack_Yield( loc_id )
	
	local _, _, canView, canDeposit = GetGuildBankTabInfo( tab_id )
	
	if not ( IsGuildLeader( ) or ( canView and canDeposit ) ) then
		ArkInventory.Output( string.format( ArkInventory.Localise["RESTACK_FAIL_ACCESS"], ArkInventory.Localise["VAULT"], tab_id ) )
		return abort, recheck
	end
	
	Restack_Yield( loc_id )
	
	for slot_id = ArkInventory.Const.BLIZZARD.GLOBAL.GUILDBANK.SLOTS_PER_TAB, 1, -1 do
		
		if not ArkInventory.Global.Mode.Vault or tab_id ~= GetCurrentGuildBankTab( ) then
			-- no longer at the vault or changed tabs, abort
			--ArkInventory.OutputWarning( "aborting, no longer at location" )
			abort = loc_id
			return abort, recheck
		end
		
		--ArkInventory.OutputDebug( "checking vault ", tab_id, ".", slot_id )
		
		if select( 3, GetGuildBankItemInfo( tab_id, slot_id ) ) then
			
			-- this slot is locked, move on and check it again next time
			--ArkInventory.Output( "locked> ", loc_id, ".", tab_id, ".", slot_id )
			recheck = true
			
		else
			
			local h = GetGuildBankItemLink( tab_id, slot_id )
			
			--ArkInventory.OutputDebug( "tab=[", tab_id, "], slot=[", slot_id, "] count=[", count, "] locked=[", locked, "] item=", h )
			
			if h then
				
				local info = ArkInventory.GetObjectInfo( h )
				local count = select( 2, GetGuildBankItemInfo( tab_id, slot_id ) )
				
				if count < info.stacksize then
					
					--ArkInventory.OutputDebug( "partial > ", tab_id, ".", slot_id )
					
					local ab, rc, ok, pb, ps = FindPartialStack( loc_id, loc_id, tab_id, nil, slot_id, info.id )
					
					if ab then
						abort = loc_id
						return abort
					end
					
					if rc then
						recheck = true
					end
					
					if ok then
						
						--ArkInventory.OutputDebug( "merge > ", tab_id, ".", slot_id, " + ", pb, ".", ps )
						
						ClearCursor( )
						PickupGuildBankItem( pb, ps )
						PickupGuildBankItem( tab_id, slot_id )
						ClearCursor( )
						
						Restack_Yield( loc_id )
						
						recheck = true
						
					end
					
				end
			
			end
			
		end
		
	end
	
	return abort, recheck
	
end

local function ConsolidateBag( blizzard_id, loc_id_window, bag_id_window )
	
	-- move stacks into empty slots
	-- start at the last slot and move things down from bags further in
	
	ArkInventory.OutputDebug( "ConsolidateBag: ", "[", blizzard_id, "] ", ArkInventory.Global.Location[loc_id_window].Name, " [", bag_id_window, "]" )
	
	local codex = ArkInventory.Codex.GetPlayer( )
	local abort = false
	local recheck = false
	
	local cl = loc_id_window
	
	if not codex.player.data.option[loc_id_window].bag[bag_id_window].restack.ignore then
		
		Restack_Yield( loc_id_window )
		
		local ab, bt, count = RestackBagCheck( blizzard_id )
		--ArkInventory.Output( "RestackBagCheck( ", loc_id_window, ", ", blizzard_id, " ) = [", ab, "] [", bt, "] [", count, "]" )
		
		if ab then
			return cl, recheck, false
		end
		
		--ArkInventory.Output( "bag> ", ArkInventory.Global.Location[loc_id_window].Name, ".", blizzard_id, " (#", bag_id_window, ") ", bt, " / ", count )
		
		local ok = true
		
		for slot_id = count, 1, -1 do
			
			if RestackBagCheck( blizzard_id ) then
				return cl, recheck, false
			end
			
			--ArkInventory.Output( "chk> ", loc_id_window, ".", blizzard_id, ".", slot_id )
			
			local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
			if itemInfo.isLocked then
				
				-- this slot is locked, move on and check it again next time
				recheck = true
				--ArkInventory.Output( "locked> ", loc_id_window, ".", blizzard_id, ".", slot_id )
				
			else
				
				if not itemInfo.hyperlink then
					
					--ArkInventory.Output( "empty> ", ArkInventory.Global.Location[loc_id_window].Name, ".", blizzard_id, ".", slot_id )
					
					local ab, rc, sb, ss
					if bt == 0 then
						ab, rc, ok, sb, ss = FindCraftingItem( loc_id_window, loc_id_window, blizzard_id, bag_id_window, slot_id )
					else
						ab, rc, ok, sb, ss = FindProfessionItem( loc_id_window, loc_id_window, blizzard_id, bag_id_window, slot_id, bt )
					end
					
					if rc then
						recheck = true
					end
					
					if ok then
						
						--ArkInventory.Output( "moving> ", sb, ".", ss, " to ", blizzard_id, ".", slot_id )
						
						--if true then return end
						
						ClearCursor( )
						ArkInventory.CrossClient.PickupContainerItem( sb, ss )
						ArkInventory.CrossClient.PickupContainerItem( blizzard_id, slot_id )
						ClearCursor( )
						
						Restack_Yield( loc_id_window )
						
						recheck = true
						
					end
					
				else
					
					--ArkInventory.Output( "item> ", loc_id_window, ".", blizzard_id, ".", slot_id, " ", h )
					
				end
				
			end
			
			if not ok then
				--ArkInventory.Output( "exit > no reagent/profession item found so no point checking the rest of the slots for this bag" )
				break
			end
			
		end
		
	end
	
	return abort, recheck
	
end

local function Consolidate( loc_id_window )
	
	ArkInventory.OutputDebug( "Consolidate: ", ArkInventory.Global.Location[loc_id_window].Name )
	
	local codex = ArkInventory.Codex.GetPlayer( )
	local abort = false
	local recheck = false
	
	local cl = loc_id_window
	
	--ArkInventory.Output( "fill up profession bags with profession items" )
	
	for bag_id_window, map in ArkInventory.rpairs( ArkInventory.Util.MapGetWindow( loc_id_window ) ) do
		
		local blizzard_id = map.blizzard_id
		local loc_id_storage = map.loc_id_storage
		
		if not codex.player.data.option[loc_id_window].bag[bag_id_window].restack.ignore then
			
			Restack_Yield( loc_id_window )
			
			local ab, bt, count = RestackBagCheck( blizzard_id )
			if ab then
				return cl, recheck, false
			end
			
			if count > 0 and ( loc_id_storage == ArkInventory.Const.Location.ReagentBank or bt ~= 0 ) then
				
				--ArkInventory.Output( "Consolidate ", loc_id_window, ".", blizzard_id, " ", bt )
				
				local ab, rc = ConsolidateBag( blizzard_id, loc_id_window, bag_id_window )
				
				if ab then
					return ab, recheck
				end
				
				if rc then
					recheck = true
				end
				
			end
			
		end
		
	end
	
	if loc_id_window == ArkInventory.Const.Location.Bank then
		
		if ArkInventory.db.option.restack.deposit and ArkInventory.CrossClient.IsReagentBankUnlocked( ) then
			
			-- fill up reagent bank with crafting items
			
			for bag_id, map in ipairs( ArkInventory.Util.MapGetStorage( ArkInventory.Const.Location.ReagentBank ) ) do
				
				local blizzard_id = map.blizzard_id
				local bag_id_window = map.bag_id_window
				
				if not codex.player.data.option[loc_id_window].bag[bag_id_window].restack.ignore then
					
					Restack_Yield( loc_id_window )
					
					if RestackBagCheck( blizzard_id ) then
						return cl, recheck, false
					end
					
					local ab, rc = ConsolidateBag( blizzard_id, loc_id_window, bag_id_window )
					
					if ab then
						return ab, recheck
					end
					
					if rc then
						recheck = true
					end
					
				end
				
			end
			
		end
		
		if ArkInventory.db.option.restack.bank then
			
			--ArkInventory.OutputDebug( "fill up normal bank slots with crafting items" )
			
			for bag_id_window, map in ArkInventory.rpairs( ArkInventory.Util.MapGetWindow( loc_id_window ) ) do
				
				local blizzard_id = map.blizzard_id
				
				if not codex.player.data.option[loc_id_window].bag[bag_id_window].restack.ignore then
					
					local ab, bt, count = RestackBagCheck( blizzard_id )
					if ab then
						return cl, recheck, false
					end
					
					if bt == 0 and map.loc_id_storage ~= ArkInventory.Const.Location.ReagentBank then
						
						local ab, rc = ConsolidateBag( blizzard_id, loc_id_window, bag_id_window )
						
						if ab then
							return ab, recheck
						end
						
						if rc then
							recheck = true
						end
						
					end
					
				end
				
			end
			
		end
		
	end
	
	return abort, recheck
	
end

local function CompactBag( loc_id, blizzard_id, bag_pos )
	
	ArkInventory.OutputDebug( "CompactBag: ", ArkInventory.Global.Location[loc_id].Name )
	
	local me = ArkInventory.Codex.GetPlayer( )
	local abort = false
	local recheck = false
	
	local cl = loc_id
	
	if not me.player.data.option[loc_id].bag[bag_pos].restack.ignore then
		
		Restack_Yield( loc_id )
		
		--ArkInventory.Output( "CompactBag( ", loc_id, ".", blizzard_id, " )" )
		
		local ab, bt, count = RestackBagCheck( blizzard_id )
		if ab then
			return cl, recheck, false
		end
		
		--ArkInventory.Output( "bag> ", loc_id, ".", blizzard_id, " (", bag_pos, ") ", bt, " / ", count )
		
		local ok = true
		
		for slot_id = count, 1, -1 do
			
			if RestackBagCheck( blizzard_id ) then
				return cl, recheck, false
			end
			
			--ArkInventory.Output( "chk> ", loc_id, ".", blizzard_id, ".", slot_id )
			
			local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
			if itemInfo.isLocked then
				
				-- this slot is locked, move on and check it again next time
				recheck = true
				--ArkInventory.Output( "locked @ ", loc_id, ".", blizzard_id, ".", slot_id )
				
			else
				
				if not itemInfo.hyperlink then
				
					--ArkInventory.Output( "empty @ ", loc_id, ".", blizzard_id, ".", slot_id )
					
					local ab, rc, sb, ss
					ab, rc, ok, sb, ss = FindNormalItem( loc_id, loc_id, blizzard_id, bag_pos, slot_id, bt )
					
					if rc then
						recheck = true
					end
					
					if ok then
						
						--ArkInventory.Output( "moving> ", sb, ".", ss, " to ", blizzard_id, ".", slot_id )
						
						ClearCursor( )
						ArkInventory.CrossClient.PickupContainerItem( sb, ss )
						ArkInventory.CrossClient.PickupContainerItem( blizzard_id, slot_id )
						ClearCursor( )
						
						Restack_Yield( loc_id )
						
						recheck = true
						
					end
					
				else
					
					--ArkInventory.Output( "item> ", loc_id, ".", blizzard_id, ".", slot_id, " ", h )
					
				end
				
			end
			
			if not ok then
				-- no item found so no point checking the rest of the slots for this bag
				break
			end
			
		end
		
	end
	
	return abort, recheck
	
end

local function Compact( loc_id )
	
	ArkInventory.OutputDebug( "Compact: ", ArkInventory.Global.Location[loc_id].Name )
	
	local me = ArkInventory.Codex.GetPlayer( )
	local abort = false
	local recheck = false
	
	local cl = loc_id
	
	for bag_pos, map in ArkInventory.rpairs( ArkInventory.Util.MapGetWindow( loc_id ) ) do
		
		local blizzard_id = map.blizzard_id
		
		if not me.player.data.option[loc_id].bag[bag_pos].restack.ignore then
			
			local ab, bt, count = RestackBagCheck( blizzard_id )
			if ab then
				return cl, recheck, false
			end
			
			if count > 0 and bt == 0 and map.loc_id_storage ~= ArkInventory.Const.Location.ReagentBank then
				
				--ArkInventory.Output( "Compact ", loc_id, ".", blizzard_id, " ", bt )
				
				local ab, rc = CompactBag( loc_id, blizzard_id, bag_pos )
				
				if ab then
					return ab, recheck
				end
				
				if rc then
					recheck = true
				end
				
			end
			
		end
		
	end
	
	return abort, recheck
	
end



local function RestackRun_Threaded( loc_id_window )
	
	--ArkInventory.Output( "RestackRun_Threaded / ", time( ), " / ", GetTime( ) )
	
	-- DO NOT USE CACHED DATA FOR RESTACKING, PULL THE DATA DIRECTLY FROM WOW AGAIN, THE UI WILL CATCH UP
	
	local me = ArkInventory.Codex.GetPlayer( )
	local ok = false
	local abort, recheck
	
	if loc_id_window == ArkInventory.Const.Location.Bag then
		
		RestackMessageStart( loc_id_window )
		
		if ArkInventory.db.option.restack.blizzard then
			
			ArkInventory.CrossClient.SortBags( )
			Restack_Yield( loc_id_window )
			
		else
			
			repeat
				
				ok = true
				
				--ArkInventory.Output( "stackbags 1 ", time( ) )
				abort, recheck = StackBags( loc_id_window )
				--ArkInventory.Output( "stackbags 2 ", time( ) )
				
				if abort then
					RestackMessageAbort( loc_id_window )
					break
				end
				
				if recheck then
					ok = false
				end
				
				--ArkInventory.Output( "consolidate 1 ", time( ) )
				abort, recheck = Consolidate( loc_id_window )
				--ArkInventory.Output( "consolidate 2 ", time( ) )
				
				if abort then
					RestackMessageAbort( loc_id_window )
					break
				end
				
				if recheck then
					ok = false
				end
				
				
--[[
				abort, recheck = Compact( loc_id_window )
				
				if abort then
					RestackMessageAbort( loc_id_window )
					break
				end
				
				if recheck then
					ok = false
				end
]]--
				
			until ok
			
		end
		
		RestackMessageComplete( loc_id_window )
		
	end
	
	
	if loc_id_window == ArkInventory.Const.Location.Bank then
		
		if ArkInventory.Global.Mode.Bank then
			
			--ArkInventory.Output( "bank / ", time( ), " / ", GetTime( ) )
			
			RestackMessageStart( loc_id_window )
			
			if ArkInventory.ClientCheck( ArkInventory.ENUM.EXPANSION.WRATH ) and ArkInventory.db.option.restack.blizzard then -- FIX ME
				
				ArkInventory.CrossClient.SetSortBagsRightToLeft( ArkInventory.db.option.restack.reverse )
				ArkInventory.CrossClient.SortBankBags( )
				
				if ArkInventory.CrossClient.IsReagentBankUnlocked( ) then
					
					if ArkInventory.db.option.restack.deposit then
						
						ArkInventory.Output( ArkInventory.RestackString( ), ": ", REAGENTBANK_DEPOSIT, " " , ArkInventory.Localise["ENABLED"] )
						
						C_Timer.After(
							ArkInventory.db.option.restack.delay,
							function( )
								if ArkInventory.Global.Mode.Bank then
									DepositReagentBank( )
								else
									RestackMessageAbort( ArkInventory.Const.Location.Bank )
								end
							end
						)
						
					else
						ArkInventory.Output( ArkInventory.RestackString( ), ": ", REAGENTBANK_DEPOSIT, " " , ArkInventory.Localise["DISABLED"] )
					end
					
					for bag_id, map in ipairs( ArkInventory.Util.MapGetStorage( ArkInventory.Const.Location.ReagentBank ) ) do
						
						local blizzard_id = map.blizzard_id
						local bag_pos = map.bag_id_window
						
						if not me.player.data.option[loc_id_window].bag[bag_pos].restack.ignore then
							C_Timer.After(
								0.6,
								function( )
									if ArkInventory.Global.Mode.Bank then
										ArkInventory.CrossClient.SortReagentBankBags( )
									else
										RestackMessageAbort( ArkInventory.Const.Location.Bank )
									end
								end
							)
						end
						
					end
					
				end
				
			else
				
				repeat
					
					ok = true
					
					--ArkInventory.Output( "StackBags / ", loc_id_window, " / ", time( ), " / ", time( ) )
					abort, recheck = StackBags( loc_id_window )
					--ArkInventory.Output( "StackBags / ", loc_id_window, " / ", time( ), " / ", time( ) )
					
					if abort then
						RestackMessageAbort( loc_id_window )
						break
					end
					
					if recheck then
						ok = false
					end
					
					--ArkInventory.Output( "Consolidate / ", loc_id_window, " / ", time( ), " / ", time( ) )
					abort, recheck = Consolidate( loc_id_window )
					--ArkInventory.Output( "Consolidate / ", loc_id_window, " / ", time( ), " / ", time( ) )
					
					if abort then
						RestackMessageAbort( loc_id_window )
						break
					end
					
					if recheck then
						ok = false
					end
					
					
--[[
					abort, recheck = Compact( loc_id_window )
					
					if abort then
						RestackMessageAbort( loc_id_window )
						break
					end
					
					if recheck then
						ok = false
					end
]]--
					
				until ok
				
			end
			
			RestackMessageComplete( loc_id_window )
			
			--ArkInventory.Output( "bank / ", time( ), " / ", GetTime( ) )
			
		end
		
	end
	
	
	if loc_id_window == ArkInventory.Const.Location.Vault then
		
		if ArkInventory.Global.Mode.Vault then
			
			RestackMessageStart( loc_id_window )
			
			repeat
				
				abort, recheck = StackVault( )
				
				if abort then
					RestackMessageAbort( loc_id_window )
					break
				end
				
				-- do not yield here
				
			until not recheck
			
			RestackMessageComplete( loc_id_window )
			
		end
		
	end
	
	
	--ArkInventory.Output( "RestackRun_Threaded / ", time( ), " / ", GetTime( ) )
	
end

local function RestackRun( loc_id_window )
	
	
	if UnitIsDead( "player" ) then
		ArkInventory.OutputWarning( "cannot restack while dead.  release or resurrect first." )
		return
	end
	
	if ArkInventory.Global.Mode.Combat then
		ArkInventory.OutputWarning( "cannot restack while in combat." )
		return
	end
	
	local thread_id = ArkInventory.Global.Thread.Format.Restack
	
	if ArkInventory.ThreadRunning( thread_id ) then
		-- restack already in progress
		--ArkInventory.OutputError( ArkInventory.RestackString( ), ": ", ArkInventory.Global.Location[loc_id].Name, " " , ArkInventory.Localise["RESTACK_FAIL_WAIT"] )
		ArkInventory.OutputError( ArkInventory.RestackString( ), ": ", ArkInventory.Localise["RESTACK_FAIL_WAIT"] )
		return
	end
	
	local thread_func = function( )
		RestackRun_Threaded( loc_id_window )
	end
	
	ArkInventory.ThreadStart( thread_id, thread_func )
	
end

function ArkInventory.Restack( loc_id_window )
	if ArkInventory.db.option.restack.enable then
		if ArkInventory.Global.Thread.Use then
			RestackRun( loc_id_window )
		else
			ArkInventory.OutputWarning( "cannot restack when threads are disabled" )
		end
	else
		ArkInventory.OutputWarning( ArkInventory.RestackString( ), " is currently disabled.  Right click on the icon for options." )
	end
end

function ArkInventory.EmptyBag( loc_id, cbag )
	
	local cbag = ArkInventory.Util.getBlizzardBagIdFromWindowId( loc_id, cbag )
	
	if not ( loc_id == ArkInventory.Const.Location.Bag or loc_id == ArkInventory.Const.Location.Bank ) then
		return
	end
	
	local _, ct = ArkInventory.CrossClient.GetContainerNumFreeSlots( cbag )
	local cslot = 0
	
	--ArkInventory.Output( "empty ", cbag, " [", ct, "]" )
	
	for bag_pos, map in ipairs( ArkInventory.Util.MapGetWindow( loc_id ) ) do
		
		local blizzard_id = map.blizzard_id
		
		local _, bt = ArkInventory.CrossClient.GetContainerNumFreeSlots( blizzard_id ) -- fix me - pull from map?
		
		if blizzard_id ~= cbag and ( bt == 0 or bt == ct ) then
			
			for slot_id = 1, ArkInventory.CrossClient.GetContainerNumSlots( blizzard_id ) do
				
				if loc_id == ArkInventory.Const.Location.Bank and not ArkInventory.Global.Mode.Bank then
					-- no longer at bank, abort
					return
				end
				
				local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
				if not itemInfo.hyperlink then
					
					repeat
						cslot = cslot + 1
						itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( cbag, cslot )
					until itemInfo.hyperlink or cslot > ArkInventory.CrossClient.GetContainerNumSlots( cbag )
					
					if itemInfo.hyperlink then
						
						ClearCursor( )
						ArkInventory.CrossClient.PickupContainerItem( cbag, cslot )
						ArkInventory.CrossClient.PickupContainerItem( blizzard_id, slot_id )
						ClearCursor( )
						
						--Restack_Yield( loc_id )
						
					end
				
				end
				
			end
			
		end
		
	end
	
end
