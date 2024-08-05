-- blizzzard functions that no longer exist, or have been replaced across clients

ArkInventory.CrossClient = {
	TemplateVersion = 1,
}

local C_AddOns = _G.C_AddOns
local C_AzeriteEmpoweredItem = _G.C_AzeriteEmpoweredItem
local C_Container = _G.C_Container
local C_CurrencyInfo = _G.C_CurrencyInfo
local C_CVar = _G.C_CVar
local C_GossipInfo = _G.C_GossipInfo
local C_Item = _G.C_Item
local C_MajorFactions = _G.C_MajorFactions
local C_Reputation = _G.C_Reputation
local C_Soulbinds = _G.C_Soulbinds
local C_TradeSkillUI = _G.C_TradeSkillUI
local C_TransmogCollection = _G.C_TransmogCollection



function ArkInventory.ClientCheck( id_toc_min, id_toc_max, loud )
	
	if type( id_toc_min ) == "boolean" then return id_toc_min end
	
	local tmin = id_toc_min or ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[ArkInventory.ENUM.EXPANSION.CLASSIC].TOC.MIN
	if tmin < ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[ArkInventory.ENUM.EXPANSION.CLASSIC].TOC.MIN then
		tmin = ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[tmin].TOC.MIN or ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[ArkInventory.ENUM.EXPANSION.CLASSIC].TOC.MIN
	end
	
	local tmax = id_toc_max or ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[ArkInventory.ENUM.EXPANSION.CURRENT].TOC.MAX
	if tmax < ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[ArkInventory.ENUM.EXPANSION.CLASSIC].TOC.MIN then
		tmax = ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[tmax].TOC.MAX or ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[ArkInventory.ENUM.EXPANSION.CURRENT].TOC.MAX
	end
	
	if loud then
		ArkInventory.Output( ArkInventory.Const.BLIZZARD.TOC, " / ", tmin, " / ", tmax )
	end
	
	if ArkInventory.Const.BLIZZARD.TOC >= tmin and ArkInventory.Const.BLIZZARD.TOC <= tmax then
		return true
	end
	
	return false
	
end

if ArkInventory.ClientCheck( nil, ArkInventory.ENUM.EXPANSION.SHADOWLANDS ) then
	
	-- remap bank bags back to their original values (pre reagent bag)
	ArkInventory.ENUM.BAG.INDEX.REAGENTBAG_1 = -999
	ArkInventory.ENUM.BAG.INDEX.BANKBAG_1 = 5
	ArkInventory.ENUM.BAG.INDEX.BANKBAG_2 = 6
	ArkInventory.ENUM.BAG.INDEX.BANKBAG_3 = 7
	ArkInventory.ENUM.BAG.INDEX.BANKBAG_4 = 8
	ArkInventory.ENUM.BAG.INDEX.BANKBAG_5 = 9
	ArkInventory.ENUM.BAG.INDEX.BANKBAG_6 = 10
	ArkInventory.ENUM.BAG.INDEX.BANKBAG_7 = 11
	
end


function ArkInventory.CrossClient.GetAverageItemLevel( )
	
	if GetAverageItemLevel then
		
		local overall, equipped, pvp = GetAverageItemLevel( )
		return math.floor( equipped )
		
	else
		
		return 1
		
	end
	
end

function ArkInventory.CrossClient.GetFirstBagBankSlotIndex( )
	if GetFirstBagBankSlotIndex then
		-- classic
		return GetFirstBagBankSlotIndex( )
	else
		return ArkInventory.CrossClient.GetContainerNumSlots( ArkInventory.ENUM.BAG.INDEX.BANK )
	end
end

function ArkInventory.CrossClient.GetProfessions( ... )
	
	local r = { }
	
	if GetProfessions then
		
		r = { GetProfessions( ... ) }
		
	else
		
		local good = false
		local skillnum = 0
		local header1 = string.lower( ArkInventory.Localise["TRADESKILLS"] )
		local header2 = string.lower( ArkInventory.Localise["SECONDARY_SKILLS"] )
		
		for k = 1, GetNumSkillLines( ) do
			local name, header = GetSkillLineInfo( k )
			--ArkInventory.Output( name, " / ", header )
			if header ~= nil then
				
				name = string.lower( name )
				if string.match( header1, name ) or string.match( header2, name ) then
					
					--ArkInventory.Output( "valid header = ", name )
					good = true
					
					if string.match( header2, name ) and skillnum < 2 then
						skillnum = 2
					end
					
				else
					
					good = false
					
				end
				
			else
				
				if good then
					skillnum = skillnum + 1
					--ArkInventory.Output( "r[", skillnum, "] = ", k, " [", name, "]" )
					r[skillnum] = k
				end
				
			end
		end
		
	end
	
	return r
	
end

function ArkInventory.CrossClient.GetProfessionInfo( index )
	
	local r = { }
	
	if GetProfessionInfo then
		
		r.name, r.texture, r.rank, r.rankMax, r.numSpells, r.spellOffset, r.skillLine, r.rankModifier = GetProfessionInfo( index )
		
	elseif GetSkillLineInfo then
		
		local name, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType = GetSkillLineInfo( index )
		
		for k, v in pairs( ArkInventory.Const.Tradeskill.Data ) do
			if v.text == name then
				--ArkInventory.Output( "skill [", index, "] found [", name, "]=[", k, "]" )
				r.name = name
				r.texture = ""
				r.rank = skillRank
				r.rankMax = skillMaxRank
				r.numSpells = 0
				r.spellOffset = 0
				r.skillLine = k
				r.rankModifier = 0
				break
			end
		end
		
	end
	
	return r
	
end

function ArkInventory.CrossClient.UIGetProfessionInfo( )
	
	-- get the profession that the tradeskill window was set for
	
	local r = { }
	
	if C_TradeSkillUI and C_TradeSkillUI.GetChildProfessionInfo then
		
		r = C_TradeSkillUI.GetChildProfessionInfo( ) or r
		
	elseif C_TradeSkillUI and C_TradeSkillUI.GetTradeSkillLine then
		
		r.professionID, r.professionName, r.skillLevel, r.maxSkillLevel, r.skillModifier, r.parentProfessionID, r.parentProfessionName =  C_TradeSkillUI.GetTradeSkillLine( )
		
	end
	
	return r
	
end

function ArkInventory.CrossClient.GetItemReagentQuality( ... )
	if C_TradeSkillUI and C_TradeSkillUI.GetItemReagentQualityByItemInfo then
		return C_TradeSkillUI.GetItemReagentQualityByItemInfo( ... )
	end
end

function ArkInventory.CrossClient.GetItemCraftedQuality( ... )
	if C_TradeSkillUI and C_TradeSkillUI.GetItemCraftedQualityByItemInfo then
		return C_TradeSkillUI.GetItemCraftedQualityByItemInfo( ... )
	end
end

function ArkInventory.CrossClient.SetSortBagsRightToLeft( ... )
	if SetSortBagsRightToLeft then
		return SetSortBagsRightToLeft( ... )
	end
end

function ArkInventory.CrossClient.GetContainerItemQuestInfo( i, ... )
	
	local r = { }
	
	if C_Container and C_Container.GetContainerItemQuestInfo then
		
		r = C_Container.GetContainerItemQuestInfo( ... ) or r
		
	elseif GetContainerItemQuestInfo then
		
		r.isQuestItem, r.questID, r.isActive = GetContainerItemQuestInfo( ... )
		
	else
		
		if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.Quest.Start" ) then
			r.isQuestItem = true
			r.questID = true
			r.isActive = false
		end
		
	end
	
	return r
	
end

function ArkInventory.CrossClient.IsReagentBankUnlocked( ... )
	if IsReagentBankUnlocked then
		return IsReagentBankUnlocked( ... )
	end
end

function ArkInventory.CrossClient.IsItemAnima( ... )
	if C_Item and C_Item.IsAnimaItemByID then
		return C_Item.IsAnimaItemByID( ... )
	end
end

function ArkInventory.CrossClient.IsItemArtifactPower( ... )
	if C_Item and C_Item.IsArtifactPowerItem then
		return C_Item.IsArtifactPowerItem( ... )
	elseif IsArtifactPowerItem then
		return IsArtifactPowerItem( ... )
	end
end

function ArkInventory.CrossClient.IsItemAzeriteEmpowered( ... )
	if C_AzeriteEmpoweredItem and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID then
		return C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID( ... )
	end
end

function ArkInventory.CrossClient.IsItemCorrupted( ... )
	if C_Item and C_Item.IsCorruptedItem then
		return C_Item.IsCorruptedItem( ... )
	elseif IsCorruptedItem then
		return IsCorruptedItem( ... )
	end
end

function ArkInventory.CrossClient.IsItemCosmetic( ... )
	if C_Item and C_Item.IsCosmeticItem then
		return C_Item.IsCosmeticItem( ... )
	elseif IsCosmeticItem then
		return IsCosmeticItem( ... )
	end
end

function ArkInventory.CrossClient.IsItemConduit( ... )
	if C_Soulbinds and C_Soulbinds.IsItemConduitByItemInfo then
		return C_Soulbinds.IsItemConduitByItemInfo( ... )
	end
end

function ArkInventory.CrossClient.GetItemCount( ... )
	if C_Item and C_Item.GetItemCount then
		return C_Item.GetItemCount( ... )
	elseif GetItemCount then
		return GetItemCount( ... )
	end
end

function ArkInventory.CrossClient.GetCurrencyInfo( ... )
	
	local r = { }
	
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
		
		r = C_CurrencyInfo.GetCurrencyInfo( ... ) or r
		
	elseif GetCurrencyInfo then
		
		r.name, r.quantity, r.iconFileID, r.quantityEarnedThisWeek, r.maxWeeklyQuantity, r.maxQuantity, r.discovered, r.quality = GetCurrencyInfo( ... )
		
	end
	
	return r
	
end

function ArkInventory.CrossClient.GetCurrencyLink( ... )
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyLink then
		return C_CurrencyInfo.GetCurrencyLink( ... )
	elseif GetCurrencyLink then
		return GetCurrencyLink( ... )
	end
end

function ArkInventory.CrossClient.GetCurrencyListSize( ... )
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListSize then
		return C_CurrencyInfo.GetCurrencyListSize( ... )
	elseif GetCurrencyListSize then
		return GetCurrencyListSize( ... )
	end
end

function ArkInventory.CrossClient.GetCurrencyListLink( ... )
	local index = ...
	if index then
		if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListLink then
			return C_CurrencyInfo.GetCurrencyListLink( ... )
		elseif GetCurrencyListLink then
			return GetCurrencyListLink( ... )
		end
	end
end

function ArkInventory.CrossClient.GetCurrencyIDFromLink( ... )
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyIDFromLink then
		return C_CurrencyInfo.GetCurrencyIDFromLink( ... )
	else
		local osd = ArkInventory.ObjectStringDecode( ... )
		if osd.class == "currency" then
			return osd.id
		end
	end
end

function ArkInventory.CrossClient.GetCurrencyListInfo( ... )
	
	local r = { }
	
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListInfo then
		
		r = C_CurrencyInfo.GetCurrencyListInfo( ... ) or r
		r.link = ArkInventory.CrossClient.GetCurrencyListLink( ... )
		r.description = C_CurrencyInfo.GetCurrencyDescription( ... )
		
	elseif GetCurrencyListInfo then
		
		r.name, r.isHeader, r.isHeaderExpanded, r.isTypeUnused, r.isShowInBackpack, r.quantity, r.iconFileID, r.maxQuantity, r.canEarnPerWeek, r.quantityEarnedThisWeek, r.arg11, r.itemID = GetCurrencyListInfo( ... )
		r.link = ArkInventory.CrossClient.GetCurrencyListLink( ... )
		
	end
	
	if not r.isHeader then
		r.hasCurrency = true
	end
	
	if r.link then
		local currencyID = ArkInventory.CrossClient.GetCurrencyIDFromLink( r.link )
		if currencyID then
			r.currencyID = currencyID
		end
	end
	
	return r
	
end

function ArkInventory.CrossClient.GetPlayerAuraBySpellID( ... )
	
	if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
		
		return C_UnitAuras.GetPlayerAuraBySpellID( ... )
		
	elseif GetPlayerAuraBySpellID then
		
		local r = { }
		r.name, r.icon, r.charges, r.dispelName, r.duration, r.expirationTime, r.sourceUnit, r.isStealable, r.nameplateShowPersonal, r.spellId, r.canApplyAura, r.isBossAura, r.isFromPlayerOrPlayerPet, r.nameplateShowAll, r.timeMod = GetPlayerAuraBySpellID( ... )
		return r
		
	end
	
end

function ArkInventory.CrossClient.GetBackpackCurrencyInfo( ... )
	
	local r = { }
	
	if C_CurrencyInfo and C_CurrencyInfo.GetBackpackCurrencyInfo then
		
		r = C_CurrencyInfo.GetBackpackCurrencyInfo( ... ) or r
		
	elseif GetBackpackCurrencyInfo then
		
		r.name, r.quantity, r.iconFileID, r.currencyTypesID = GetBackpackCurrencyInfo( ... )
		
	end
	
	return r
	
end

function ArkInventory.CrossClient.SetCurrencyUnused( index, unused )
	if C_CurrencyInfo and C_CurrencyInfo.SetCurrencyUnused then
		return C_CurrencyInfo.SetCurrencyUnused( index, unused )
	elseif SetCurrencyUnused then
		if unused then
			unused = 1
		else
			unused = 0
		end
		return SetCurrencyUnused( index, unused )
	end
end

function ArkInventory.CrossClient.ExpandCurrencyHeader( index )
	if C_CurrencyInfo and C_CurrencyInfo.ExpandCurrencyList then
		return C_CurrencyInfo.ExpandCurrencyList( index, true )
	elseif ExpandCurrencyList then
		return ExpandCurrencyList( index, 1 )
	end
end

function ArkInventory.CrossClient.CollapseCurrencyHeader( index )
	if C_CurrencyInfo and C_CurrencyInfo.ExpandCurrencyList then
		return C_CurrencyInfo.ExpandCurrencyList( index, false )
	elseif ExpandCurrencyList then
		return ExpandCurrencyList( index, 0 )
	end
end

function ArkInventory.CrossClient.GetNumFactions( ... )
	if C_Reputation and C_Reputation.GetNumFactions then
		return C_Reputation.GetNumFactions( ... )
	elseif GetNumFactions then
		return GetNumFactions( ... )
	end
end

function ArkInventory.CrossClient.ExpandFactionHeader( ... )
	if C_Reputation and C_Reputation.ExpandFactionHeader then
		return C_Reputation.ExpandFactionHeader( ... )
	elseif ExpandFactionHeader then
		return ExpandFactionHeader( ... )
	end
end

function ArkInventory.CrossClient.CollapseFactionHeader( ... )
	if C_Reputation and C_Reputation.CollapseFactionHeader then
		return C_Reputation.CollapseFactionHeader( ... )
	elseif CollapseFactionHeader then
		return CollapseFactionHeader( ... )
	end
end

function ArkInventory.CrossClient.SetFactionActive( ... )
	if C_Reputation and C_Reputation.SetFactionActive then
		return C_Reputation.SetFactionActive( ... )
	elseif SetFactionActive then
		return SetFactionActive( ... )
	end
end

function ArkInventory.CrossClient.SetFactionInactive( ... )
	if C_Reputation and C_Reputation.SetFactionInactive then
		return C_Reputation.SetFactionInactive( ... )
	elseif SetFactionInactive then
		return SetFactionInactive( ... )
	end
end

function ArkInventory.CrossClient.SetWatchedFactionByIndex( ... )
	if C_Reputation and C_Reputation.SetWatchedFactionByIndex then
		return C_Reputation.SetWatchedFactionByIndex( ... )
	elseif SetWatchedFactionIndex then
		return SetWatchedFactionIndex( ... )
	end
end

function ArkInventory.CrossClient.GetFactionInfo( ... )
	
	if C_Reputation and C_Reputation.GetFactionDataByIndex then
		
		return C_Reputation.GetFactionDataByIndex( ... )
		
	elseif GetFactionInfo then
		
		local r = { }
		
		r.name, r.description, r.standingID, r.barMin, r.barMax, r.barValue, r.atWarWith, r.canToggleAtWar, r.isHeader, r.isCollapsed, r.hasRep, r.isWatched, r.isChild, r.factionID, r.hasBonusRepGain, r.canSetInactive = GetFactionInfo( ... )
		
		r.standingID = r.standingID or 0
		r.barMin = r.barMin or 0
		r.barMax = r.barMax or 0
		r.barValue = r.barValue or 0
		
		return r
		
	end
	
end

function ArkInventory.CrossClient.GetFactionInfoByID( ... )
	
	if C_Reputation and C_Reputation.GetFactionDataByID then
		
		return C_Reputation.GetFactionDataByID( ... )
		
	elseif GetFactionInfoByID then
		
		local r = { }
		
		r.name, r.description, r.standingID, r.barMin, r.barMax, r.barValue, r.atWarWith, r.canToggleAtWar, r.isHeader, r.isCollapsed, r.hasRep, r.isWatched, r.isChild, r.factionID, r.hasBonusRepGain, r.canSetInactive = GetFactionInfoByID( ... )
		
		return r
		
	end
	
end

function ArkInventory.CrossClient.GetFriendshipReputation( ... )
	if C_GossipInfo and C_GossipInfo.GetFriendshipReputation then
		local r = C_GossipInfo.GetFriendshipReputation( ... )
		if r.friendshipFactionID > 0 then
			return r
		end
	end
end

function ArkInventory.CrossClient.GetFriendshipReputationRanks( ... )
	if C_GossipInfo and C_GossipInfo.GetFriendshipReputationRanks then
		return C_GossipInfo.GetFriendshipReputationRanks( ... )
	end
end

function ArkInventory.CrossClient.IsMajorFaction( ... )
	if C_Reputation and C_Reputation.IsMajorFaction then
		return C_Reputation.IsMajorFaction( ... )
	end
end

function ArkInventory.CrossClient.GetMajorFactionData( ... )
	if C_MajorFactions and C_MajorFactions.GetMajorFactionData then
		return C_MajorFactions.GetMajorFactionData( ... )
	end
end

function ArkInventory.CrossClient.HasMaximumRenown( ... )
	if C_MajorFactions and C_MajorFactions.HasMaximumRenown then
		return C_MajorFactions.HasMaximumRenown( ... )
	end
end

function ArkInventory.CrossClient.IsFactionParagon( ... )
	if C_Reputation and C_Reputation.IsFactionParagon then
		return C_Reputation.IsFactionParagon( ... )
	end
end

function ArkInventory.CrossClient.GetFactionParagonInfo( ... )
	
	if C_Reputation and C_Reputation.GetFactionParagonInfo then
		
		local r = { }
		
		r.value, r.threshold, r.rewardQuestID, r.rewardPending, r.tooLowLevel = C_Reputation.GetFactionParagonInfo( ... )
		
		return r
		
	end
	
end

function ArkInventory.CrossClient.GetRenownLevels( ... )
	
	local r = { }
	
	if C_MajorFactions and C_MajorFactions.GetRenownLevels then
		r = C_MajorFactions.GetRenownLevels( ... )
	end
	
	return r
end

function ArkInventory.CrossClient.GetCVar( ... )
	if C_CVar and C_CVar.GetCVar then
		return C_CVar.GetCVar( ... )
	elseif GetCVar then
		return GetCVar( ... )
	end
end

function ArkInventory.CrossClient.SetCVar( ... )
	if C_CVar and C_CVar.SetCVar then
		return C_CVar.SetCVar( ... )
	elseif SetCVar then
		return SetCVar( ... )
	end
end

function ArkInventory.CrossClient.GetCVarBool( ... )
	if C_CVar and C_CVar.GetCVarBool then
		return C_CVar.GetCVarBool( ... )
	elseif GetCVarBool then
		return GetCVarBool( ... )
	end
end

function ArkInventory.CrossClient.SetCVarBool( ... )
	
	local cv_name, cv_value = ...
	
	if cv_value then
		cv_value = "1"
	else
		cv_value = "0"
	end
	
	ArkInventory.CrossClient.SetCVar( cv_name, cv_value )
	
end

function ArkInventory.CrossClient.GetBagSlotFlag( ... )
	if C_Container and C_Container.GetBagSlotFlag then
		return C_Container.GetBagSlotFlag( ... )
	elseif GetBagSlotFlag then
		return GetBagSlotFlag( ... )
	end
end

function ArkInventory.CrossClient.SetBagSlotFlag( ... )
	if C_Container and C_Container.SetBagSlotFlag then
		return C_Container.SetBagSlotFlag( ... )
	elseif SetBagSlotFlag then
		return SetBagSlotFlag( ... )
	end
end

function ArkInventory.CrossClient.GetBankBagSlotFlag( ... )
	if C_Container and C_Container.GetBagSlotFlag then
		return C_Container.GetBagSlotFlag( ... )
	elseif GetBankBagSlotFlag then
		return GetBankBagSlotFlag( ... )
	end
end

function ArkInventory.CrossClient.SetBankBagSlotFlag( ... )
	if C_Container and C_Container.SetBagSlotFlag then
		return C_Container.SetBagSlotFlag( ... )
	elseif SetBankBagSlotFlag then
		return SetBankBagSlotFlag( ... )
	end
end

function ArkInventory.CrossClient.SetBackpackAutosortDisabled( ... )
	if C_Container and C_Container.SetBackpackAutosortDisabled then
		return C_Container.SetBackpackAutosortDisabled( ... )
	elseif SetBackpackAutosortDisabled then
		return SetBackpackAutosortDisabled( ... )
	end
end

function ArkInventory.CrossClient.SetBankAutosortDisabled( ... )
	if C_Container and C_Container.SetBankAutosortDisabled then
		return C_Container.SetBankAutosortDisabled( ... )
	elseif SetBankAutosortDisabled then
		return SetBankAutosortDisabled( ... )
	end
end

function ArkInventory.CrossClient.EnumerateBagGearFilters( ... )
	if ContainerFrameUtil_EnumerateBagGearFilters then
		return ContainerFrameUtil_EnumerateBagGearFilters( ... )
	else
		local bagGearFilters = {
			LE_BAG_FILTER_FLAG_EQUIPMENT,
			LE_BAG_FILTER_FLAG_CONSUMABLES,
			LE_BAG_FILTER_FLAG_TRADE_GOODS,
		}
		return ipairs( bagGearFilters )
	end
end

function ArkInventory.CrossClient.OptionNotAvailableExpansion( check, text )
	local disabled = not not check
	local text = text
	if disabled then
		text = string.format( "%s\n\n%s%s", text, RED_FONT_COLOR_CODE, ArkInventory.Localise["OPTION_NOT_AVILABLE_EXPANSION"] )
	end
	return disabled, text
end

function ArkInventory.CrossClient.GetContainerNumSlots( ... )
	
	if C_Container and C_Container.GetContainerNumSlots then
		return C_Container.GetContainerNumSlots( ... ) or 0
	elseif GetContainerNumSlots then
		return GetContainerNumSlots( ... ) or 0
	end
	
end

function ArkInventory.CrossClient.ContainerIDToInventoryID( ... )
	if C_Container and C_Container.ContainerIDToInventoryID then
		return C_Container.ContainerIDToInventoryID( ... )
	elseif ContainerIDToInventoryID then
		return ContainerIDToInventoryID( ... )
	end
end

function ArkInventory.CrossClient.GetContainerItemLink( ... )
	
	if C_Container and C_Container.GetContainerItemLink then
		return C_Container.GetContainerItemLink( ... )
	elseif GetContainerItemLink then
		return GetContainerItemLink( ... )
	end
	
end

function ArkInventory.CrossClient.GetContainerItemInfo( ... )
	
	local r = { }
	
	if C_Container and C_Container.GetContainerItemInfo then
		
		r = C_Container.GetContainerItemInfo( ... ) or r
		
	elseif GetContainerItemInfo then
		
		r.iconFileID, r.stackCount, r.isLocked, r.quality, r.isReadable, r.hasLoot, r.hyperlink, r.isFiltered, r.hasNoValue, r.itemID, r.isBound = GetContainerItemInfo( ... )
		
	end
	
	r.stackCount = r.stackCount or 1
	r.quality = r.quality or ArkInventory.ENUM.ITEM.QUALITY.POOR
	
	return r
	
end

function ArkInventory.CrossClient.GetContainerItemID( ... )
	
	if C_Container and C_Container.GetContainerItemID then
		return C_Container.GetContainerItemID( ... )
	elseif GetContainerItemID then
		return GetContainerItemID( ... )
	end
	
end

function ArkInventory.CrossClient.GetInventoryItemID( ... )
	
	if GetInventoryItemID then
		return GetInventoryItemID( ... )
	end
	
end

function ArkInventory.CrossClient.IsBattlePayItem( ... )
	if C_Container and C_Container.IsBattlePayItem then
		return C_Container.IsBattlePayItem( ... )
	elseif IsBattlePayItem then
		return IsBattlePayItem( ... )
	end
end

function ArkInventory.CrossClient.GetContainerItemCooldown( ... )
	if C_Container and C_Container.GetContainerItemCooldown then
		return C_Container.GetContainerItemCooldown( ... )
	elseif GetContainerItemCooldown then
		return GetContainerItemCooldown( ... )
	end
end

function ArkInventory.CrossClient.GetContainerFreeSlots( ... )
	if C_Container and C_Container.GetContainerFreeSlots then
		return C_Container.GetContainerFreeSlots( ... ) or { }
	elseif GetContainerFreeSlots then
		return GetContainerFreeSlots( ... ) or { }
	end
end

function ArkInventory.CrossClient.GetContainerNumFreeSlots( ... )
	-- return the number of free slots, and the bag type
	if C_Container and C_Container.GetContainerNumFreeSlots then
		local numFreeSlots, bagFamily = C_Container.GetContainerNumFreeSlots( ... )
		if numFreeSlots == 0 and not bagFamily then
			numFreeSlots = #ArkInventory.CrossClient.GetContainerFreeSlots( ... )
			bagFamily = 0
		end
		return numFreeSlots, bagFamily
	elseif GetContainerNumFreeSlots then
		return GetContainerNumFreeSlots( ... )
	end
end

function ArkInventory.CrossClient.PickupContainerItem( ... )
	if C_Container and C_Container.PickupContainerItem then
		return C_Container.PickupContainerItem( ... )
	elseif PickupContainerItem then
		return PickupContainerItem( ... )
	end
end

function ArkInventory.CrossClient.UseContainerItem( ... )
	if C_Container and C_Container.UseContainerItem then
		return C_Container.UseContainerItem( ... )
	elseif UseContainerItem then
		return UseContainerItem( ... )
	end
end

function ArkInventory.CrossClient.SortBags( ... )
	if C_Container and C_Container.SortBags then
		return C_Container.SortBags( ... )
	elseif SortBags then
		return SortBags( ... )
	end
end

function ArkInventory.CrossClient.SortBankBags( ... )
	if C_Container and C_Container.SortBankBags then
		return C_Container.SortBankBags( ... )
	elseif SortBankBags then
		return SortBankBags( ... )
	end
end

function ArkInventory.CrossClient.SortReagentBankBags( ... )
	if C_Container and C_Container.SortReagentBankBags then
		return C_Container.SortReagentBankBags( ... )
	elseif SortReagentBankBags then
		return SortReagentBankBags( ... )
	end
end

function ArkInventory.CrossClient.GetInsertItemsLeftToRight( ... )
	if C_Container and C_Container.GetInsertItemsLeftToRight then
		return C_Container.GetInsertItemsLeftToRight( ... )
	elseif GetInsertItemsLeftToRight then
		return GetInsertItemsLeftToRight( ... )
	end
end

function ArkInventory.CrossClient.SetInsertItemsLeftToRight( ... )
	if C_Container and C_Container.SetInsertItemsLeftToRight then
		return C_Container.SetInsertItemsLeftToRight( ... )
	elseif SetInsertItemsLeftToRight then
		return SetInsertItemsLeftToRight( ... )
	end
end

function ArkInventory.CrossClient.ClearItemOverlays( frame )
	
	local overlayKeys = { "IconOverlay", "IconOverlay2", "ProfessionQualityOverlay" }
	for _, key in pairs( overlayKeys ) do
		local overlay = frame[key]
		if overlay then
			overlay:SetVertexColor( 1, 1, 1 )
			overlay:SetAtlas( nil )
			overlay:SetTexture( nil )
			overlay:Hide( )
		end
	end
	
	
	frame.isProfessionItem = false
	frame.isCraftedItem = false
	
end

function ArkInventory.CrossClient.ShowContainerSellCursor( ... )
	if C_Container and C_Container.ShowContainerSellCursor then
		return C_Container.ShowContainerSellCursor( ... )
	elseif ShowContainerSellCursor then
		return ShowContainerSellCursor( ... )
	end
end

function ArkInventory.CrossClient.PlayerHasTransmogByItemInfo( ... )
	if C_TransmogCollection and C_TransmogCollection.PlayerHasTransmogByItemInfo then
		return C_TransmogCollection.PlayerHasTransmogByItemInfo( ... )
	end
end

function ArkInventory.CrossClient.GetItemLearnTransmogSet( ... )
	if C_Item and C_Item.GetItemLearnTransmogSet then
		return C_Item.GetItemLearnTransmogSet( ... )
	end
end

function ArkInventory.CrossClient.TransmogCollection_GetItemInfo( ... )
	if C_TransmogCollection and C_TransmogCollection.GetItemInfo then
		return C_TransmogCollection.GetItemInfo( ... )
	end
end

function ArkInventory.CrossClient.GetMouseFocus( )
	if GetMouseFoci then
		local regions = GetMouseFoci( )
--		for _, foci in ipairs( regions ) do
--			ArkInventory.Output( foci:GetName( ) )
--		end
--		ArkInventory.Output( "---" )
		return regions[1]
	else
		return GetMouseFocus( )
	end
end

function ArkInventory.CrossClient.IsWarbankInUseByAnotherCharacter( )
	
	if C_PlayerInfo and C_PlayerInfo.HasAccountInventoryLock then
		return not C_PlayerInfo.HasAccountInventoryLock( )
	end
	
end


function ArkInventory.CrossClient.LoadAddOn( ... )
	if C_AddOns and C_AddOns.LoadAddOn then
		return C_AddOns.LoadAddOn( ... )
	else
		return LoadAddOn( ... )
	end
end

function ArkInventory.CrossClient.GetAddOnMetadata( ... )
	if C_AddOns and C_AddOns.GetAddOnMetadata then
		return C_AddOns.GetAddOnMetadata( ... )
	else
		return GetAddOnMetadata( ... )
	end
end

function ArkInventory.CrossClient.IsAddOnLoaded( ... )
	if C_AddOns and C_AddOns.IsAddOnLoaded then
		return C_AddOns.IsAddOnLoaded( ... )
	else
		return IsAddOnLoaded( ... )
	end
end

function ArkInventory.CrossClient.TooltipSetCurrencyByID( tooltip, ... )
	if tooltip then
		if tooltip.SetCurrencyByID then
			return tooltip:SetCurrencyByID( ... )
		elseif tooltip.SetCurrencyTokenByID then
			return tooltip:SetCurrencyTokenByID( ... )
		end
	end
end

function ArkInventory.CrossClient.GetCreateFrameItemType( )
	if ArkInventory.CrossClient.TemplateVersion == 1 then
		return "ItemButton"
	end
	return "Button"
end

function ArkInventory.CrossClient.IsAdvancedFlyableArea( )
	if IsAdvancedFlyableArea then
		return IsAdvancedFlyableArea( )
	end
end

function ArkInventory.CrossClient.GetItemCooldown( ... )
	
	if C_Item and C_Item.GetItemCooldown then
		return C_Container.GetItemCooldown( ... )
	end
	
	if GetItemCooldown then
		return GetItemCooldown( ... )
	end
	
end

function ArkInventory.CrossClient.GetNumWorldPVPAreas( ... )
	if GetNumWorldPVPAreas then
		return GetNumWorldPVPAreas( ... )
	end
	return 0
end

function ArkInventory.CrossClient.TimerunningSeasonID( )
	
	local r = 0
	
	if PlayerGetTimerunningSeasonID then
		r = PlayerGetTimerunningSeasonID( ) or r
	end
	
	return r
	
end

function ArkInventory.CrossClient.KeyRingButtonIDToInvSlotID( ... )
	if KeyRingButtonIDToInvSlotID then
		return KeyRingButtonIDToInvSlotID( ... )
	end
end

function ArkInventory.CrossClient.GetScrapSpellID( )
	
	local r = -1
	
	if C_ScrappingMachineUI and C_ScrappingMachineUI.GetScrapSpellID then
		r = C_ScrappingMachineUI.GetScrapSpellID( ) or r
	end
	
	return r
	
end

function ArkInventory.CrossClient.GetSpellInfo( ... )
	
	local r = { }
	
	if C_Spell and C_Spell.GetSpellInfo then
		r = C_Spell.GetSpellInfo( ... )
	elseif GetSpellInfo then
		r.name, r.rank, r.iconID, r.castTime, r.minRange, r.maxRange, r.spellID, r.originalIconID = GetSpellInfo( ... )
	end
	
	return r
	
end

function ArkInventory.CrossClient.GetItemInfo( ... )
	
	-- r.itemName, r.itemLink, r.itemQuality, r.itemLevel, r.itemMinLevel, r.itemType, r.itemSubType, r.itemStackCount, r.itemEquipLoc, r.itemTexture, r.sellPrice, r.classID, r.subclassID, r.bindType, r.expansionID, r.setID, r.isCraftingReagent
	
	if C_Item and C_Item.GetItemInfo then
		return C_Item.GetItemInfo( ... )
	elseif GetItemInfo then
		return GetItemInfo( ... )
	end
	
end

function ArkInventory.CrossClient.GetItemInfoInstant( ... )
	
	-- r.itemID, r.itemType, r.itemSubType, r.itemEquipLoc, r.icon, r.classID, r.subClassID
	
	if C_Item and C_Item.GetItemInfoInstant then
		return C_Item.GetItemInfoInstant( ... )
	elseif GetItemInfoInstant then
		return GetItemInfoInstant( ... )
	end
	
end

function ArkInventory.CrossClient.GetItemFamily( ... )
	if C_Item and C_Item.GetItemFamily then
		return C_Item.GetItemFamily( ... )
	else
		return GetItemFamily( ... )
	end
end

function ArkInventory.CrossClient.GetItemClassInfo( ... )
	
	local r = nil
	
	if C_Item and C_Item.GetItemClassInfo then
		r = C_Item.GetItemClassInfo( ... )
	elseif GetItemClassInfo then
		r = GetItemClassInfo( ... )
	end
	
	return r
	
end

function ArkInventory.CrossClient.GetItemSubClassInfo( ... )
	
	local r = nil
	
	if C_Item and C_Item.GetItemSubClassInfo then
		r = C_Item.GetItemSubClassInfo( ... )
	elseif GetItemSubClassInfo then
		r = GetItemSubClassInfo( ... )
	end
	
	return r
	
end

function ArkInventory.CrossClient.CloseBankFrame( ... )
	if C_Bank and C_Bank.CloseBankFrame then
		return C_Bank.CloseBankFrame( ... )
	elseif CloseBankFrame then
		return CloseBankFrame( ... )
	end
	
end

function ArkInventory.CrossClient.GetDetailedItemLevelInfo( ... )
	if C_Item and C_Item.GetDetailedItemLevelInfo then
		return C_Item.GetDetailedItemLevelInfo( ... )
	elseif GetDetailedItemLevelInfo then
		return GetDetailedItemLevelInfo( ... )
	end
	
end

function ArkInventory.CrossClient.GetSpellLink( ... )
	if C_Spell and C_Spell.GetSpellLink then
		return C_Spell.GetSpellLink( ... )
	elseif GetSpellLink then
		return GetSpellLink( ... )
	end
	
end

function ArkInventory.CrossClient.GetItemSpell( ... )
	if C_Item and C_Item.GetItemSpell then
		return C_Item.GetItemSpell( ... )
	elseif GetItemSpell then
		return GetItemSpell( ... )
	end
	
end

function ArkInventory.CrossClient.GetItemIcon( ... )
	
	if C_Item and C_Item.GetItemIconByID then
		return C_Item.GetItemIconByID( ... )
	elseif GetItemIcon then
		return GetItemIcon( ... )
	end
	
end

function ArkInventory.CrossClient.GetItemQualityColor( quality )
	
	if quality then
		
		local c = { }
		local v1, v2, v3, v4, r, g, b, a
		
		if C_Item and C_Item.GetItemQualityColor then
			
			v1, v2, v3, v4 = C_Item.GetItemQualityColor( quality )
			
		elseif GetItemQualityColor then
			
			v1, v2, v3, v4 = GetItemQualityColor( quality )
			
		end
		
		if v1 then
			
			if type( v1 ) == "number" then
				c.r = v1
				c.g = v2
				c.b = v3
				c.a = 1
			elseif type( v1 ) == "table" then
				c = v1
			end
			
			return c.r, c.g, c.b, c.a
			
		end
		
	end
	
end

function ArkInventory.CrossClient.IsUsableSpell( ... )
	if C_Spell and C_Spell.IsSpellUsable then
		return C_Spell.IsSpellUsable( ... )
	elseif IsUsableSpell then
		return IsUsableSpell( ... )
	end
end

function ArkInventory.CrossClient.IsCurrentSpell( ... )
	if C_Spell and C_Spell.IsCurrentSpell then
		return C_Spell.IsCurrentSpell( ... )
	elseif IsCurrentSpell then
		return IsCurrentSpell( ... )
	end
end




local a = string.lower( ArkInventory.CrossClient.GetCVar( "agentuid" ) )
local p = string.lower( ArkInventory.CrossClient.GetCVar( "portal" ) )

for k, v in pairs( ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION ) do
	--ArkInventory.Output( k, " = ", v )
	if ArkInventory.Const.BLIZZARD.TOC >= v.TOC.MIN and ArkInventory.Const.BLIZZARD.TOC <= v.TOC.MAX then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = v.ID
		break
	end
end
ArkInventory.ENUM.EXPANSION.CURRENT = ArkInventory.Const.BLIZZARD.CLIENT.ID


if ArkInventory.Const.BLIZZARD.CLIENT.ID <= ArkInventory.ENUM.EXPANSION.WRATH then
	ArkInventory.CrossClient.TemplateVersion = 2
end

if ArkInventory.Const.BLIZZARD.CLIENT.ID == nil then
	ArkInventory.OutputError( "code error: unable to determine game client, please contact the author with the following client data: project=[", WOW_PROJECT_ID, "], agent=[", a, "], portal=[", p, "] TOC=[", ArkInventory.Const.BLIZZARD.TOC, "]")
else
	if string.match( a, "alpha" ) then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.ID + ArkInventory.Const.BLIZZARD.CLIENT.ALPHA
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: Alpha", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	elseif string.match( a, "beta" ) then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.ID + ArkInventory.Const.BLIZZARD.CLIENT.BETA
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: Beta", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	elseif string.match( a, "ptr" ) or p == "test" then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.ID + ArkInventory.Const.BLIZZARD.CLIENT.PTR
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: PTR", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	end
end
