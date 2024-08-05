local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


ArkInventory.LDB = {
	Loaded = false
}

local ldb = { }


function ArkInventory.LDB.Update( )
	
	if ArkInventory.LDB.Loaded then
		
		ArkInventory.LDB.Bags:Update( )
		ArkInventory.LDB.Money:Update( )
		
		ArkInventory:SendMessage( "EVENT_ARKINV_LDB_PET_UPDATE_BUCKET" )
		ArkInventory:SendMessage( "EVENT_ARKINV_LDB_MOUNT_UPDATE_BUCKET" )
		ArkInventory:SendMessage( "EVENT_ARKINV_LDB_CURRENCY_UPDATE_BUCKET" )
		ArkInventory:SendMessage( "EVENT_ARKINV_LDB_ITEM_UPDATE_BUCKET" )
		ArkInventory:SendMessage( "EVENT_ARKINV_LDB_REPUTATION_UPDATE_BUCKET" )
		
	else
		
		ArkInventory.LDB.Bags = ArkInventory.Lib.DataBroker:NewDataObject( string.format( "%s_%s", ArkInventory.Const.Program.Name, "Bags" ), {
			type = "data source",
			text = BLIZZARD_STORE_LOADING,
		} )
		
		ArkInventory.LDB.Bags.Update = ldb.Bags.Update
		ArkInventory.LDB.Bags.OnClick = ldb.Bags.OnClick
		
		
		ArkInventory.LDB.Money = ArkInventory.Lib.DataBroker:NewDataObject( string.format( "%s_%s", ArkInventory.Const.Program.Name, "Money" ), {
			type = "data source",
			text = BLIZZARD_STORE_LOADING,
		} )
		
		ArkInventory.LDB.Money.Update = ldb.Money.Update
		ArkInventory.LDB.Money.OnTooltipShow = ldb.Money.OnTooltipShow
		
		
		ArkInventory.LDB.Tracking_Currency = ArkInventory.Lib.DataBroker:NewDataObject( string.format( "%s_%s_%s", ArkInventory.Const.Program.Name, "Tracking", "Currency" ), {
			type = ArkInventory.ClientCheck( ArkInventory.Global.Location[ArkInventory.Const.Location.Currency].ClientCheck ) and "data source" or "hidden",
			text = BLIZZARD_STORE_LOADING,
		} )
		
		ArkInventory.LDB.Tracking_Currency.Update = ldb.Tracking_Currency.Update
		ArkInventory.LDB.Tracking_Currency.OnClick = ldb.Tracking_Currency.OnClick
		ArkInventory.LDB.Tracking_Currency.OnTooltipShow = ldb.Tracking_Currency.OnTooltipShow
		
		
		ArkInventory.LDB.Tracking_Bronze = ArkInventory.Lib.DataBroker:NewDataObject( string.format( "%s_%s_%s", ArkInventory.Const.Program.Name, "Tracking", "Bronze" ), {
			type = ArkInventory.Global.TimerunningSeasonID > 0 and ArkInventory.ClientCheck( ArkInventory.Global.Location[ArkInventory.Const.Location.Currency].ClientCheck ) and "data source" or "hidden",
			text = BLIZZARD_STORE_LOADING,
		} )
		
		ArkInventory.LDB.Tracking_Bronze.Update = ldb.Tracking_Bronze.Update
		ArkInventory.LDB.Tracking_Bronze.OnClick = ldb.Tracking_Bronze.OnClick
		ArkInventory.LDB.Tracking_Bronze.OnTooltipShow = ldb.Tracking_Bronze.OnTooltipShow
		
		
		ArkInventory.LDB.Tracking_Reputation = ArkInventory.Lib.DataBroker:NewDataObject( string.format( "%s_%s_%s", ArkInventory.Const.Program.Name, "Tracking", "Reputation" ), {
			type = ArkInventory.ClientCheck( ArkInventory.Global.Location[ArkInventory.Const.Location.Reputation].ClientCheck ) and "data source" or "hidden",
			text = BLIZZARD_STORE_LOADING,
		} )
		
		ArkInventory.LDB.Tracking_Reputation.Update = ldb.Tracking_Reputation.Update
		ArkInventory.LDB.Tracking_Reputation.OnClick = ldb.Tracking_Reputation.OnClick
		ArkInventory.LDB.Tracking_Reputation.OnTooltipShow = ldb.Tracking_Reputation.OnTooltipShow
		
		
		ArkInventory.LDB.Tracking_Item = ArkInventory.Lib.DataBroker:NewDataObject( string.format( "%s_%s_%s", ArkInventory.Const.Program.Name, "Tracking", "Item" ), {
			type = "data source",
			text = BLIZZARD_STORE_LOADING,
		} )
		
		ArkInventory.LDB.Tracking_Item.Update = ldb.Tracking_Item.Update
		ArkInventory.LDB.Tracking_Item.OnClick = ldb.Tracking_Item.OnClick
		ArkInventory.LDB.Tracking_Item.OnTooltipShow = ldb.Tracking_Item.OnTooltipShow
		
		
		ArkInventory.LDB.Pets = ArkInventory.Lib.DataBroker:NewDataObject( string.format( "%s_%s", ArkInventory.Const.Program.Name, "Pets" ), {
			type = ArkInventory.ClientCheck( ArkInventory.Global.Location[ArkInventory.Const.Location.Pet].ClientCheck ) and "data source" or "hidden",
			text = BLIZZARD_STORE_LOADING,
		} )
		
		ArkInventory.LDB.Pets.Update = ldb.Pets.Update
		ArkInventory.LDB.Pets.OnClick = ldb.Pets.OnClick
		ArkInventory.LDB.Pets.OnTooltipShow = ldb.Pets.OnTooltipShow
		
		
		ArkInventory.LDB.Mounts = ArkInventory.Lib.DataBroker:NewDataObject( string.format( "%s_%s", ArkInventory.Const.Program.Name, "Mounts" ), {
			type = ArkInventory.ClientCheck( ArkInventory.Global.Location[ArkInventory.Const.Location.Mount].ClientCheck ) and "data source" or "hidden",
			text = BLIZZARD_STORE_LOADING,
		} )
		
		ArkInventory.LDB.Mounts.Update = ldb.Mounts.Update
		ArkInventory.LDB.Mounts.OnClick = ldb.Mounts.OnClick
		ArkInventory.LDB.Mounts.OnTooltipShow = ldb.Mounts.OnTooltipShow
		ArkInventory.LDB.Mounts.GetNext = ldb.Mounts.GetNext
		
		
		
		ArkInventory.LDB.Loaded = true
		
		return ArkInventory.LDB.Update( )
		
	end
	
end

ldb.Bags = {
	
	Update = function( self )
		
		local icon = string.format( "|T%s:0|t", ArkInventory.Global.Location[ArkInventory.Const.Location.Bag].Texture )
		local hasText
		
		local me = ArkInventory.Codex.GetPlayer( )
		local loc_id_window = ArkInventory.Const.Location.Bag
		
		hasText = ArkInventory.Frame_Status_Update_Empty( loc_id_window, me, true )
		
		if hasText then
			self.text = string.trim( string.format( "%s %s", icon, hasText ) )
		else
			self.text = icon
		end
		
	end,
	
	OnClick = function( self, button )
		if button == "RightButton" then
			ArkInventory.MenuLDBBagsOpen( self )
		else
			ArkInventory.Frame_Main_Toggle( ArkInventory.Const.Location.Bag )
		end
	end,
	
}

ldb.Money = {
	
	Update = function( self )
		
		local icon = string.format( "|T%s:0|t", ArkInventory.Const.Texture.Money )
		local hasText
		
		hasText = ArkInventory.MoneyText( GetMoney( ) )
		
		if hasText then
			self.text = string.trim( hasText )
		else
			self.text = icon
		end
		
	end,
	
	OnTooltipShow = function( self )
		ArkInventory.MoneyFrame_Tooltip( self )
	end,
	
}

function ArkInventory:EVENT_ARKINV_LDB_CURRENCY_UPDATE_BUCKET( )
	if InCombatLockdown( ) then
		ArkInventory:SendMessage( "EVENT_ARKINV_LDB_CURRENCY_UPDATE_BUCKET", "IN_COMBAT" )
	else
		ArkInventory.LDB.Tracking_Currency:Update( )
		ArkInventory.LDB.Tracking_Bronze:Update( )
	end
end

ldb.Tracking_Currency = {
	
	Update = function( self )
		
		local loc_id = ArkInventory.Const.Location.Currency
		local icon = string.format( "|T%s:0|t", ArkInventory.Global.Location[loc_id].Texture )
		local hasText
		
		if ArkInventory.isLocationMonitored( loc_id ) then
			if ArkInventory.Collection.Currency.IsReady( ) then
				if ArkInventory.Collection.Currency.GetCount( ) > 0 then
					
					local codex = ArkInventory.Codex.GetPlayer( )
					
					for _, object in ArkInventory.Collection.Currency.ListIterate( ) do
						
						local data = object.data
						if data and codex.player.data.ldb.tracking.currency.watched[data.id] then
							hasText = string.format( "%s |T%s:0|t %s", hasText or "", data.iconFileID, FormatLargeNumber( data.quantity ) )
						end
						
					end
					
				end
			else
				ArkInventory:SendMessage( "EVENT_ARKINV_LDB_CURRENCY_UPDATE_BUCKET" )
			end
		end
		
		if hasText then
			self.text = string.trim( hasText )
		else
			self.text = icon
		end
		
	end,
	
	OnClick = function( frame, button )
		
		local loc_id = ArkInventory.Const.Location.Currency
		
		if button == "RightButton" then
			ArkInventory.MenuLDBTrackingCurrencyOpen( frame )
		else
			ArkInventory.Frame_Main_Toggle( ArkInventory.Const.Location.Currency )
		end
		
	end,
	
	OnTooltipShow = function( self )
		
		local loc_id = ArkInventory.Const.Location.Currency
		
		if ArkInventory.isLocationMonitored( loc_id ) then
			
			self:AddLine( string.format( "%s: %s", ArkInventory.Localise["TRACKING"], ArkInventory.Localise["CURRENCY"] ) )
			self:AddLine( " " )
			
			if ArkInventory.Collection.Currency.IsReady( ) then
				if ArkInventory.Collection.Currency.GetCount( ) > 0 then
					
					local codex = ArkInventory.Codex.GetPlayer( )
					
					for _, entry in ArkInventory.Collection.Currency.ListIterate( ) do
						
						local data = entry.data
						if data then
							
							if codex.player.data.ldb.tracking.currency.tracked[data.id] then
								
								local txt = FormatLargeNumber( data.quantity )
								
								if data.maxQuantity > 0 then
									txt = string.format( "%s/%s", FormatLargeNumber( data.quantity ), FormatLargeNumber( data.maxQuantity ) )
								end
								
								self:AddDoubleLine( data.name, txt, 1, 1, 1, 1, 1, 1 )
								
								if data.canEarnPerWeek and data.quantityEarnedThisWeek and data.quantityEarnedThisWeek > 0 then
									txt = string.format( "%s/%s", FormatLargeNumber( data.quantityEarnedThisWeek ), FormatLargeNumber( data.canEarnPerWeek ) )
									self:AddDoubleLine( string.format( "  * %s", ArkInventory.Localise["WEEKLY"] ), txt, 1, 1, 1, 1, 1, 1 )
								end
							
							end
							
						end
						
					end
					
				else
					self:AddLine( ArkInventory.Localise["LDB_CURRENCY_NONE"], 1, 0, 0 )
				end
			else
				self:AddLine( string.format( ArkInventory.Localise["LDB_LOCATION_NOT_READY"], ArkInventory.Global.Location[loc_id].Name ), 1, 0, 0 )
				ArkInventory:SendMessage( "EVENT_ARKINV_LDB_CURRENCY_UPDATE_BUCKET" )
			end
		else
			self:AddLine( string.format( ArkInventory.Localise["LDB_LOCATION_NOT_MONITORED"], ArkInventory.Global.Location[loc_id].Name ), 1, 0, 0 )
		end
		
		self:Show( )
		
	end,
	
}

ldb.Tracking_Bronze = {
	
	Update = function( self )
		
		local loc_id = ArkInventory.Const.Location.Currency
		local icon = string.format( "|T%s:0|t", ArkInventory.Global.Location[loc_id].Texture )
		local hasText
		
		if ArkInventory.isLocationMonitored( loc_id ) then
			if ArkInventory.Collection.Currency.IsReady( ) then
				
				local codex = ArkInventory.Codex.GetPlayer( )
				
				local data = ArkInventory.Collection.Currency.GetByID( codex.player.data.ldb.tracking.bronze.tracked )
				if data then
					hasText = string.format( "%s |T%s:0|t %s", hasText or "", data.iconFileID, FormatLargeNumber( data.quantity ) )
				end
			else
				ArkInventory:SendMessage( "EVENT_ARKINV_LDB_CURRENCY_UPDATE_BUCKET" )
			end
		end
		
		if hasText then
			self.text = string.trim( hasText )
		else
			self.text = icon
		end
		
	end,
	
	OnClick = function( self, button )
		
		local loc_id = ArkInventory.Const.Location.Currency
		
		if button == "RightButton" then
			--ArkInventory.MenuLDBTrackingCurrencyOpen( self )
		else
			ArkInventory.Frame_Main_Toggle( ArkInventory.Const.Location.Currency )
		end
		
	end,

	OnTooltipShow = function( self )
		
		local loc_id = ArkInventory.Const.Location.Currency
		
		if ArkInventory.isLocationMonitored( loc_id ) then
			
			self:AddLine( string.format( "%s: %s", ArkInventory.Localise["TRACKING"], "Bronze" ) )
			
			if ArkInventory.Collection.Currency.IsReady( ) then
				local codex = ArkInventory.Codex.GetPlayer( )
				local tracked = ArkInventory.Collection.Currency.GetByID( codex.player.data.ldb.tracking.bronze.tracked )
				if tracked then
					ArkInventory.TooltipAddItemCount( self, tracked.link )
				else
					self:AddLine( ArkInventory.Localise["LDB_CURRENCY_NONE"], 1, 0, 0 )
				end
			else
				self:AddLine( string.format( ArkInventory.Localise["LDB_LOCATION_NOT_READY"], ArkInventory.Global.Location[loc_id].Name ), 1, 0, 0 )
				ArkInventory:SendMessage( "EVENT_ARKINV_LDB_CURRENCY_UPDATE_BUCKET" )
			end
		else
			self:AddLine( string.format( ArkInventory.Localise["LDB_LOCATION_NOT_MONITORED"], ArkInventory.Global.Location[loc_id].Name ), 1, 0, 0 )
		end
		
		self:Show( )
		
	end,
	
}

function ArkInventory:EVENT_ARKINV_LDB_REPUTATION_UPDATE_BUCKET( )
	if InCombatLockdown( ) then
		ArkInventory:SendMessage( "EVENT_ARKINV_LDB_REPUTATION_UPDATE_BUCKET" )
	else
		ArkInventory.LDB.Tracking_Reputation:Update( )
	end
end

ldb.Tracking_Reputation = {
	
	Update = function( self )
		
		local loc_id = ArkInventory.Const.Location.Reputation
		
		local icon = string.format( "|T%s:0|t", ArkInventory.Global.Location[loc_id].Texture )
		local hasText
		
		if ArkInventory.isLocationMonitored( loc_id ) then
			if ArkInventory.Collection.Reputation.IsReady( ) then
				if ArkInventory.Collection.Reputation.GetCount( ) > 0 then
				
					local codex = ArkInventory.Codex.GetPlayer( )
					
					local style_default = ArkInventory.Const.Reputation.Style.OneLineWithName
					local style = style_default
					if ArkInventory.db.option.tracking.reputation.custom ~= ArkInventory.Const.Reputation.Custom.Default then
						style = ArkInventory.db.option.tracking.reputation.style.ldb
						if string.trim( style ) == "" then
							style = style_default
						end
					end
					
					local data = ArkInventory.Collection.Reputation.GetByID( codex.player.data.ldb.tracking.reputation.watched )
					if data then
						local txt = ArkInventory.Collection.Reputation.LevelText( data.id, style )
						hasText = string.format( "|T%s:0|t %s", data.icon, txt )
					end
					
					if not hasText then
						codex.player.data.ldb.tracking.reputation.watched = nil
					end
				
			end
			else
				ArkInventory:SendMessage( "EVENT_ARKINV_LDB_REPUTATION_UPDATE_BUCKET" )
			end
		end
		
		if hasText then
			self.text = string.trim( hasText )
		else
			self.text = icon
		end
		
	end,
	
	OnClick = function( self, button )
		
		local loc_id = ArkInventory.Const.Location.Reputation
		
		if not ArkInventory.isLocationMonitored( loc_id ) or ArkInventory.Collection.Reputation.GetCount( ) <= 0 then
			return
		end
		
		if button == "RightButton" then
			ArkInventory.MenuLDBTrackingReputationOpen( self )
		else
			ArkInventory.Frame_Main_Toggle( ArkInventory.Const.Location.Reputation )
			--ToggleCharacter( "ReputationFrame" )
		end
		
	end,
	
	OnTooltipShow = function( self )
		
		local loc_id = ArkInventory.Const.Location.Reputation
		
		if ArkInventory.isLocationMonitored( loc_id ) then
			
			self:AddLine( string.format( "%s: %s", ArkInventory.Localise["TRACKING"], ArkInventory.Localise["REPUTATION"] ) )
			self:AddLine( " " )
			
			if ArkInventory.Collection.Reputation.IsReady( ) then
				
				if ArkInventory.Collection.Reputation.GetCount( ) > 0 then
					
					local codex = ArkInventory.Codex.GetPlayer( )
					
					local style_default = ArkInventory.Const.Reputation.Style.OneLine
					local style = style_default
					if ArkInventory.db.option.tracking.reputation.custom ~= ArkInventory.Const.Reputation.Custom.Default then
						style = ArkInventory.db.option.tracking.reputation.style.tooltip
						if string.trim( style ) == "" then
							style = style_default
						end
					end
					
					for _, entry in ArkInventory.Collection.Reputation.ListIterate( ) do
						
						local data = entry.data
						if data then
							
							if codex.player.data.ldb.tracking.reputation.tracked[data.id] then
								
								local txt = ArkInventory.Collection.Reputation.LevelText( data.id, style )
								
								if codex.player.data.ldb.tracking.reputation.watched == data.id then
									self:AddDoubleLine( data.name, txt, 0, 1, 0, 0, 1, 0 )
								else
									self:AddDoubleLine( data.name, txt, 1, 1, 1, 1, 1, 1 )
								end
								
							else
								
								codex.player.data.ldb.tracking.reputation.tracked[data.id] = false
								
							end
							
						end
						
					end
					
				else
					self:AddLine( ArkInventory.Localise["LDB_REPUTATION_NONE"], 1, 0, 0 )
				end
				
			else
				self:AddLine( string.format( ArkInventory.Localise["LDB_LOCATION_NOT_READY"], ArkInventory.Global.Location[loc_id].Name ), 1, 0, 0 )
				ArkInventory:SendMessage( "EVENT_ARKINV_LDB_REPUTATION_UPDATE_BUCKET" )
			end
		else
			self:AddLine( string.format( ArkInventory.Localise["LDB_LOCATION_NOT_MONITORED"], ArkInventory.Global.Location[loc_id].Name ), 1, 0, 0 )
		end
		
		self:Show( )
		
	end,
	
}

function ArkInventory:EVENT_ARKINV_LDB_ITEM_UPDATE_BUCKET( )
	if InCombatLockdown( ) then
		ArkInventory:SendMessage( "EVENT_ARKINV_LDB_ITEM_UPDATE_BUCKET" )
	else
		ArkInventory.LDB.Tracking_Item:Update( )
	end
end

ldb.Tracking_Item = {
	
	Update = function( self )
		
		local icon = string.format( "|T%s:0|t", [[Interface\Icons\Ability_Tracking]] )
		local hasText
		
		local ready = true
		local codex = ArkInventory.Codex.GetPlayer( )
		
		for k in ArkInventory.spairs( ArkInventory.db.option.tracking.items )  do
			
			local info = ArkInventory.GetObjectInfo( k )
			ready = ready and info.ready
			
			if codex.player.data.ldb.tracking.item.tracked[k] then
				local count = ArkInventory.CrossClient.GetItemCount( k, true ) or 0
				if count > 0 or ( count == 0 and ArkInventory.db.option.tracking.item.showzero ) then
					hasText = string.format( "%s  |T%s:0|t %s", hasText or "", info.texture or ArkInventory.Const.Texture.Missing, FormatLargeNumber( count ) )
				end
			end
			
		end
		
		if hasText then
			self.text = string.trim( hasText )
		else
			self.text = icon
		end
		
		if not ready then
			ArkInventory:SendMessage( "EVENT_ARKINV_LDB_ITEM_UPDATE_BUCKET" )
		end
		
	end,
	
	OnClick = function( self, button )
		
		if button == "RightButton" then
			ArkInventory.MenuLDBTrackingItemOpen( self )
		end
		
	end,
	
	OnTooltipShow = function( self )
		
		self:AddLine( string.format( "%s: %s", ArkInventory.Localise["TRACKING"], ArkInventory.Localise["ITEMS"] ) )
		self:AddLine( " " )
		
		local codex = ArkInventory.Codex.GetPlayer( )
		
		for k in ArkInventory.spairs( ArkInventory.db.option.tracking.items ) do
			
			local info = ArkInventory.GetObjectInfo( k )
			
			local count = ArkInventory.CrossClient.GetItemCount( k, true )
			local checked = codex.player.data.ldb.tracking.item.tracked[k]
			
			if checked then
				self:AddDoubleLine( info.name, count, 0, 1, 0, 0, 1, 0 )
			else
				self:AddDoubleLine( info.name, count, 1, 1, 1, 1, 1, 1 )
			end
			
		end
		
		self:Show( )
		
	end,
	
}

function ArkInventory:EVENT_ARKINV_LDB_PET_UPDATE_BUCKET( )
	if InCombatLockdown( ) then
		ArkInventory:SendMessage( "EVENT_ARKINV_LDB_PET_UPDATE_BUCKET" )
	else
		ArkInventory.LDB.Pets:Update( )
	end
end

ldb.Pets = {
	
	companionTable = { },
	next = 0,
	
	Cleanup = function( )
		
		if ArkInventory.Collection.Pet.IsReady( ) then
			
			-- check for and remove any selected companions we no longer have (theyve either been caged or released)
			local codex = ArkInventory.Codex.GetPlayer( )
			local selected = codex.player.data.ldb.pets.selected
			for k, v in pairs( selected ) do
				if v ~= nil and not ArkInventory.Collection.Pet.GetByID( k ) then
					selected[k] = nil
					ArkInventory.OutputDebug( "removing selected pet [", k, "] from LDB as we no longer have it" )
				end
			end
			
		end
		
	end,
	
	companionUpdate = function( ignoreActive )
		
		ArkInventory.Table.Wipe( ldb.Pets.companionTable )
		
		if not ArkInventory.Collection.Pet.IsReady( ) then
			return
		end
		
		local n = ArkInventory.Collection.Pet.GetCount( )
		--ArkInventory.Output( "pet count = ", n )
		if n == 0 then return end
		
		local codex = ArkInventory.Codex.GetPlayer( )
		local selected = codex.player.data.ldb.pets.selected
		local selectedCount = 0
		for k, v in pairs( selected ) do
			if v == true then
				selectedCount = selectedCount + 1
			end
		end
		
		if selectedCount < 2 then
			ignoreActive = true
		end
		
		--ArkInventory.Output( "count = ", selectedCount, ", selected = ", selected )
		
		local count = 0
		local _, _, activePet = ArkInventory.Collection.Pet.GetCurrent( )
		local activeSpecies = activePet and activePet.sd.speciesID
		
		for index, pd in ArkInventory.Collection.Pet.Iterate( ) do
			
			if ( not activePet or ignoreActive ) and ( pd.sd.speciesID ~= activeSpecies ) and ( selectedCount == 0 or selected[index] == true ) and ArkInventory.Collection.Pet.CanSummon( pd.guid ) then
				
				-- cannot be same species as the active pet, if one was active
				-- must be summonable
				
				if selected[index] == false then
					-- never summon
				else
					count = count + 1
					ldb.Pets.companionTable[count] = index
				end
				
			end
			
		end
		
	end,
	
	Update = function( self )
		
		local loc_id = ArkInventory.Const.Location.Pet
		
		local icon = string.format( "|T%s:0|t", ArkInventory.Global.Location[loc_id].Texture )
		local hasText
		
		if ArkInventory.isLocationMonitored( loc_id ) then
			
			if ArkInventory.Collection.Pet.IsReady( ) then
				ldb.Pets.Cleanup( )
			else
				ArkInventory:SendMessage( "EVENT_ARKINV_LDB_PET_UPDATE_BUCKET" )
			end
			
		end
		
		if hasText then
			self.text = string.trim( hasText )
		else
			self.text = icon
		end
		
	end,
	
	OnClick = function( self, button )
		
		local loc_id = ArkInventory.Const.Location.Pet
		
		if not ArkInventory.isLocationMonitored( loc_id ) or not ArkInventory.Collection.Pet.IsReady( ) then
			return
		end
		
		if IsModifiedClick( "CHATLINK" ) then
			-- dismiss current pet
			ArkInventory.Collection.Pet.Dismiss( )
			return
		end
		
		ldb.Pets:Update( )
		
		if button == "RightButton" then
			
			ArkInventory.MenuLDBPetsOpen( self )
			
		else
			
			if ArkInventory.Collection.Pet.GetCount( ) == 0 then
				ArkInventory.Output( string.format( ArkInventory.Localise["NONE_OWNED"], ArkInventory.Localise["PETS"] ) )
				return
			end
			
			ldb.Pets.companionUpdate( true )
			
			--ArkInventory.Output( #ldb.Pets.companionTable, " usable pets" )
			
			if #ldb.Pets.companionTable == 0 then
				
				-- you only have one pet selected, or in total
				ArkInventory.Collection.Pet.Dismiss( )
				return
				
			else
				
				local codex = ArkInventory.Codex.GetPlayer( )
				local userandom = codex.player.data.ldb.pets.randomise
				
				if #ldb.Pets.companionTable <= 3 then
					userandom = false
				end
				
				if userandom then
					ldb.Pets.next = random( 1, #ldb.Pets.companionTable )
				else
					ldb.Pets.next = ldb.Pets.next + 1
					if ldb.Pets.next > #ldb.Pets.companionTable then
						ldb.Pets.next = 1
					end
				end
				
				--ArkInventory.Output( ldb.Pets.next, " = ", ldb.Pets.companionTable[ldb.Pets.next] )
				ArkInventory.Collection.Pet.Summon( ldb.Pets.companionTable[ldb.Pets.next] )
				
			end
			
		end
		
	end,
	
	OnTooltipShow = function( self )
		
		local loc_id = ArkInventory.Const.Location.Pet
		
		if ArkInventory.isLocationMonitored( loc_id ) then
			
			self:AddLine( ArkInventory.Localise["PET"] )
			self:AddLine( " " )
			
			if ArkInventory.Collection.Pet.IsReady( ) then
				
				local numtotal = ArkInventory.Collection.Pet.GetCount( )
				if numtotal > 0 then
					
					local codex = ArkInventory.Codex.GetPlayer( )
					
					local selected = codex.player.data.ldb.pets.selected
					local numselected = 0
					for k, v in pairs( selected ) do
						if v == true then
							numselected = numselected + 1
						end
					end
					
					if codex.player.data.ldb.pets.useall then
						
						self:AddLine( string.format( "%s (%s)", ArkInventory.Localise["ALL"], numtotal ), 1, 1, 1 )
						
					elseif numselected == 0 then
						
						self:AddLine( ArkInventory.Localise["NONE"], 1, 1, 1 )
						
					elseif numselected == 1 then
						
						-- just the one selected, there may be ignored but they dont matter
						for k, v in pairs( selected ) do
							if v == true then
								local pd = ArkInventory.Collection.Pet.GetByID( k )
								local name = pd.sd.name
								if pd.cn and pd.cn ~= "" then
									name = string.format( "%s (%s)", name, pd.cn )
								end
								self:AddLine( string.format( "%s: %s", ArkInventory.Localise["SELECTION"], name ), 1, 1, 1 )
							end
						end
						
					else
						
						-- more than one selected, there may be ignored but they dont matter
						self:AddLine( string.format( "%s (%s/%s)", ArkInventory.Localise["SELECTION"], numselected, numtotal ), 1, 1, 1 )
						
					end
					
				else
					self:AddLine( ArkInventory.Localise["LDB_COMPANION_NONE"], 1, 0, 0 )
				end
				
			else
				self:AddLine( string.format( ArkInventory.Localise["LDB_LOCATION_NOT_READY"], ArkInventory.Global.Location[loc_id].Name ), 1, 0, 0 )
				ArkInventory:SendMessage( "EVENT_ARKINV_LDB_PET_UPDATE_BUCKET" )
			end
		else
			self:AddLine( string.format( ArkInventory.Localise["LDB_LOCATION_NOT_MONITORED"], ArkInventory.Global.Location[loc_id].Name ), 1, 0, 0 )
		end
		
		self:Show( )
		
	end,
	
}

function ArkInventory:EVENT_ARKINV_LDB_MOUNT_UPDATE_BUCKET( )
	if InCombatLockdown( ) then
		ArkInventory:SendMessage( "EVENT_ARKINV_LDB_MOUNT_UPDATE_BUCKET" )
	else
		ArkInventory.LDB.Mounts:Update( )
	end
end

ldb.Mounts = {
	
	companionTable = { },
	next = 0,
	
	Cleanup = function( )
		
		-- remove any selected mounts we no longer have (not sure how but just in case)
		
		local codex = ArkInventory.Codex.GetPlayer( )
		
		for mta, mt in pairs( ArkInventory.Const.Mount.Types ) do
			
			if mta ~= "x" then
				
				local selected = codex.player.data.ldb.mounts.type[mta].selected
				
				for spell, value in pairs( selected ) do
					local md = ArkInventory.Collection.Mount.GetMountBySpell( spell )
					if value ~= nil and not md then
						ArkInventory.OutputWarning( "removing a selected mount [", spell, "] as you dont have it any more" )
						selected[spell] = nil
					elseif md and md.mt ~= mt then
						ArkInventory.OutputWarning( "removing a selected mount ", md.link, " that has changed type" )
						selected[spell] = nil
					end
				end
				
			end
			
		end
		
	end,
	
	IsSubmerged = function( )
		
		-- its always right about being in the water, just not under the water
		
		if ( GetMirrorTimerInfo( 2 ) ) == "BREATH" then
			-- breath timer so were underwater
			return true
		end
		
		if not IsSubmerged( ) then
			return false
		end
		
		if not IsSwimming( ) then
			-- zone with a seabed where you can walk/mount (eg, vash'jir)
			return false
		end
		
		-- if you get here you are submerged and swimming and not holding your breath
		-- so youre either at the surface, have some sort of underwater breathing, or possibly both, theres no real way to tell
		
		return true
		
	end,
	
	companionUpdate = function( tbl )
		
		if type( tbl ) ~= "table" then return end
		
		for index, md in pairs( tbl ) do
			table.insert( ldb.Mounts.companionTable, md.index )
		end
		
	end,
	
	GetUsable = function( forceAlternative, forceDragonridingAlternative )
		
		-- builds companionTable and returns the type
		
		local forceAlternative = forceAlternative
		
		wipe( ldb.Mounts.companionTable )
		
		local codex = ArkInventory.Codex.GetPlayer( )
		--ArkInventory.Collection.Mount.UpdateDragonridingMounts( codex.player.data.ldb.mounts.dragonriding )
		
		ArkInventory.Collection.Mount.UpdateUsable( codex.player.data.ldb.mounts.dragonriding, forceDragonridingAlternative )
		
		if ldb.Mounts.IsSubmerged( ) then
			
			if not forceAlternative then
				
				ArkInventory.OutputDebug( "primary - check underwater" )
				if ArkInventory.Collection.Mount.GetCount( "u" ) > 0 then
					ArkInventory.OutputDebug( "primary - using underwater" )
					ldb.Mounts.companionUpdate( ArkInventory.Collection.Mount.GetUsable( "u" ) )
					return "u"
				end
				
	--			ArkInventory.OutputDebug( "fallback - check surface" )
	--			if ArkInventory.Collection.Mount.GetCount( "s" ) > 0 then
	--				ArkInventory.OutputDebug( "fallback - using surface" )
	--				ldb.Mounts.companionUpdate( ArkInventory.Collection.Mount.GetUsable( "s" ) )
	--				return "s"
	--			end
				
			else
				
				ArkInventory.OutputDebug( "ignore underwater, force flying (or land if you cant fly here)" )
				if ArkInventory.Collection.Mount.isFlyable( ) then
					forceAlternative = false
				end
			end
			
		else
			
			if IsSwimming( ) then
				
				if not forceAlternative then
	--				ArkInventory.OutputDebug( "primary - check surface" )
	--				if ArkInventory.Collection.Mount.GetCount( "s" ) > 0 then
	--					ArkInventory.OutputDebug( "primary - using surface" )
	--					ldb.Mounts.companionUpdate( ArkInventory.Collection.Mount.GetUsable( "s" ) )
	--					return "s"
	--				end
				else
					ArkInventory.OutputDebug( "ignore surface, force flying (or land if you cant fly here)" )
					if ArkInventory.Collection.Mount.isFlyable( ) then
						forceAlternative = false
					end
				end
				
			end
			
		end
		
		if ArkInventory.Collection.Mount.isFlyable( ) then
			ArkInventory.OutputDebug( "flight check - can fly here" )
			if not forceAlternative then
				ArkInventory.OutputDebug( "primary - check flying" )
				if ArkInventory.Collection.Mount.GetCount( "a" ) > 0 then
					ArkInventory.OutputDebug( "primary - using flying" )
					ldb.Mounts.companionUpdate( ArkInventory.Collection.Mount.GetUsable( "a" ) )
					return "a"
				end
			else
				ArkInventory.OutputDebug( "ignore flying, force land" )
				forceAlternative = false
			end
		else
			ArkInventory.OutputDebug( "flight check - cannot fly here" )
		end
		
		ArkInventory.OutputDebug( "primary - check land" )
		if not forceAlternative then
			
			if ArkInventory.Collection.Mount.GetCount( "l" ) > 0 then
				ArkInventory.OutputDebug( "primary - adding land" )
				ldb.Mounts.companionUpdate( ArkInventory.Collection.Mount.GetUsable( "l" ) )
			end
			
			local codex = ArkInventory.Codex.GetPlayer( )
			
	--		if codex.player.data.ldb.mounts.type.l.usesurface and ArkInventory.Collection.Mount.GetCount( "s" ) > 0 then
	--			ArkInventory.OutputDebug( "primary - adding surface" )
	--			ldb.Mounts.companionUpdate( ArkInventory.Collection.Mount.GetUsable( "s" ) )
	--		end
			
			if codex.player.data.ldb.mounts.type.l.useflying and ArkInventory.Collection.Mount.GetCount( "a" ) > 0 then
				ArkInventory.OutputDebug( "primary - adding flying" )
				ldb.Mounts.companionUpdate( ArkInventory.Collection.Mount.GetUsable( "a" ) )
			end
			
			if #ldb.Mounts.companionTable > 0 then
				ArkInventory.OutputDebug( "primary - using land" )
				return "l"
			end
			
		else
			
			if ArkInventory.Collection.Mount.GetCount( "a" ) > 0 then
				ArkInventory.OutputDebug( "alternative - using flying" )
				ldb.Mounts.companionUpdate( ArkInventory.Collection.Mount.GetUsable( "a" ) )
				return "a"
			end
			
		end
		
		--fallback
		
		if ArkInventory.Collection.Mount.GetCount( "l" ) > 0 then
			ArkInventory.OutputDebug( "fallback - using land" )
			ldb.Mounts.companionUpdate( ArkInventory.Collection.Mount.GetUsable( "l" ) )
			return "l"
		end
		
	--	if ArkInventory.Collection.Mount.GetCount( "s" ) > 0 then
	--		ArkInventory.OutputDebug( "fallback - using surface" )
	--		ldb.Mounts.companionUpdate( ArkInventory.Collection.Mount.GetUsable( "s" ) )
	--		return "s"
	--	end
		
		if ArkInventory.Collection.Mount.GetCount( "a" ) > 0 then
			ArkInventory.OutputDebug( "fallback - using flying" )
			ldb.Mounts.companionUpdate( ArkInventory.Collection.Mount.GetUsable( "a" ) )
			return "a"
		end
		
		if ArkInventory.Collection.Mount.GetCount( "u" ) > 0 then
			ArkInventory.OutputDebug( "fallback - underwater" )
			ldb.Mounts.companionUpdate( ArkInventory.Collection.Mount.GetUsable( "u" ) )
			return "u"
		end
		
	end,
	
	GetNext = function( )
		
		ArkInventory.OutputDebug( "----- get next mount -----" )
		
		ArkInventory.SetMountMacro( )
		
		local c, r = ArkInventory.CheckPlayerHasControl( )
		if not c then
			-- you cant mount while you are not in control
			ArkInventory.Output( r )
			return
		end
		
		if IsIndoors( ) then
			-- you shouldnt be able to mount here at all
			ArkInventory.Output( ArkInventory.Localise["LDB_MOUNTS_FAIL_NOT_ALLOWED"] )
			return
		end
		
		local codex = ArkInventory.Codex.GetPlayer( )
		
		if IsMounted( ) then
			
			if IsFlying( ) then
				if not codex.player.data.ldb.mounts.type.a.dismount then
					ArkInventory.OutputWarning( ArkInventory.Localise["LDB_MOUNTS_FLYING_DISMOUNT_WARNING"] )
					return
				end
			end
			
			ArkInventory.Collection.Mount.Dismiss( )
			
			return
			
		end
		
		if InCombatLockdown( ) or IsFlying( ) or not ArkInventory.Collection.Mount.IsReady( ) then return end
		
		
		if ArkInventory.Collection.Mount.GetCount( ) == 0 then
			--ArkInventory.Output( "you don't own any mounts" )
			return
		end
		
		local forceAlternative = IsModifiedClick( "CHATLINK" )
		ArkInventory.OutputDebug( "forceAlternative = ", forceAlternative )
		local forceDragonridingAlternative = IsModifiedClick( "DRESSUP" )
		ArkInventory.OutputDebug( "forceDragonridingAlternative = ", forceDragonridingAlternative )
		
		ldb.Mounts.GetUsable( forceAlternative, forceDragonridingAlternative )
		
		ArkInventory.OutputDebug( #ldb.Mounts.companionTable, " usable mounts", ldb.Mounts.companionTable )
		
		if #ldb.Mounts.companionTable == 0 then
			
			ArkInventory.Output( string.format( ArkInventory.Localise["NONE_USABLE"], ArkInventory.Localise["MOUNTS"] ) )
			return
			
		else
			
			local userandom = codex.player.data.ldb.mounts.randomise
			
			if #ldb.Mounts.companionTable <= 3 then
				userandom = false
			end
			
			if userandom then
				-- random
				ldb.Mounts.next = random( 1, #ldb.Mounts.companionTable )
			else
				-- cycle
				ldb.Mounts.next = ldb.Mounts.next + 1
				if ldb.Mounts.next > #ldb.Mounts.companionTable then
					ldb.Mounts.next = 1
				end
			end
			
			local i = ldb.Mounts.companionTable[ldb.Mounts.next]
			--local md = ArkInventory.Collection.Mount.GetMount( i )
			--ArkInventory.Output( "use mount ", i, ": ", md.link, " ", ldb.Mounts.next, " / ", #ldb.Mounts.companionTable, " / usable=", (ArkInventory.CrossClient.IsUsableSpell( md.spellID )), " / flight=", IsFlyableArea( ) )
			ArkInventory.Collection.Mount.Summon( i )
			
		end
		
	end,
	
	Update = function( self )
		
		local loc_id = ArkInventory.Const.Location.Mount
		
		local icon = string.format( "|T%s:0|t", ArkInventory.Global.Location[loc_id].Texture )
		local hasText
		
		if ArkInventory.isLocationMonitored( loc_id ) then
			if ArkInventory.Collection.Mount.IsReady( ) then
				ldb.Mounts.Cleanup( )
			else
				ArkInventory:SendMessage( "EVENT_ARKINV_LDB_MOUNT_UPDATE_BUCKET" )
			end
		end
		
		if hasText then
			self.text = string.trim( hasText )
		else
			self.text = icon
		end
		
	end,
	
	OnClick = function( self, button )
		
		local loc_id = ArkInventory.Const.Location.Mount
		
		if not ArkInventory.isLocationMonitored( loc_id ) then
			ArkInventory.OutputWarning( "location is not monitored" )
			return
		end
		
		if not ArkInventory.Collection.Mount.IsReady( ) then
			ArkInventory.OutputWarning( "location is not ready" )
			return
		end
		
		
		if button == "RightButton" then
			
			--ArkInventory.MenuLDBMountsOpen( self )
			ArkInventory.Frame_Config_Show( "advanced", "ldb", "mounts" )
			
		else
			
			ldb.Mounts.GetNext( )
			
		end
		
	end,
	
	OnTooltipShow = function( self )
		
		local loc_id = ArkInventory.Const.Location.Mount
		
		if ArkInventory.isLocationMonitored( loc_id ) then
			
			self:AddDoubleLine( ArkInventory.Localise["MODE"], ArkInventory.Localise["MOUNT"] )
			self:AddLine( " " )
			
			if ArkInventory.Collection.Mount.IsReady( ) then
				
				local codex = ArkInventory.Codex.GetPlayer( )
				
				ArkInventory.Collection.Mount.UpdateUsable( codex.player.data.ldb.mounts.dragonriding )
				
				for mta in pairs( ArkInventory.Const.Mount.Types ) do
					
					local mode = ArkInventory.Localise[string.upper( string.format( "LDB_MOUNTS_TYPE_%s", mta ) )]
					local numusable, numtotal = ArkInventory.Collection.Mount.GetCount( mta )
					
					--ArkInventory.Output( mta, " / ", mode, " / ", numusable, " / ", numtotal )
					
					if mta ~= "x" then
						
						if numtotal == 0 then
							
							self:AddDoubleLine( mode, ArkInventory.Localise["NONE"], 1, 1, 1, 1, 0, 0 )
							
						else
							
							local selected = codex.player.data.ldb.mounts.type[mta].selected
							local numselected = 0
							for k, v in pairs( selected ) do
								if v == true then
									numselected = numselected + 1
								end
							end
							
							if codex.player.data.ldb.mounts.type[mta].useall then
								
								self:AddDoubleLine( mode, string.format( "%s (%s)", ArkInventory.Localise["ALL"], numtotal ), 1, 1, 1, 1, 1, 1 )
								
							elseif numselected == 0 then
								
								self:AddDoubleLine( mode, ArkInventory.Localise["NONE"], 1, 1, 1, 1, 1, 1 )
								
							elseif numselected == 1 then
								
								-- just the one selected, there may be ignored but they dont matter
								for k, v in pairs( selected ) do
									if v then
										local name = ArkInventory.CrossClient.GetSpellInfo( k ).name
										self:AddDoubleLine( mode, string.format( "%s: %s", ArkInventory.Localise["SELECTION"], name ), 1, 1, 1, 1, 1, 1 )
									end
								end
								
							else
								
								-- more than one selected, there may be ignored but they dont matter
								self:AddDoubleLine( mode, string.format( "%s (%s/%s)", ArkInventory.Localise["SELECTION"], numselected, numtotal ), 1, 1, 1, 1, 1, 1 )
								
							end
							
						end
						
					end
					
				end
				
			else
				self:AddLine( string.format( ArkInventory.Localise["LDB_LOCATION_NOT_READY"], ArkInventory.Global.Location[loc_id].Name ), 1, 0, 0 )
				ArkInventory:SendMessage( "EVENT_ARKINV_LDB_MOUNT_UPDATE_BUCKET" )
			end
		else
			self:AddLine( string.format( ArkInventory.Localise["LDB_LOCATION_NOT_MONITORED"], ArkInventory.Global.Location[loc_id].Name ), 1, 0, 0 )
		end
		
		self:Show( )
		
	end,
	
}
