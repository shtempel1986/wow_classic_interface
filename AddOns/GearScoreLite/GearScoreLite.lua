--[[

                               GearScoreLite                                 
                              Version 3x04y01                            
						   	    Mirrikat45                          
						2.4.3 port by xarthasskrillexx
						 TBCC fix by Джанит@Пламегор



Change Log 0.1 
-TBCC Classic Fix
-Pvp trinket item levels fixed
-Mouseover hook fixed for tbcc inspection event
-Double inspection players to fix invalid gear data bug 
-Classic gear score fixed
-New feature: gearscore + itemlevel data while inspection
-Some options keys disabled

Change Log 3x04y05
-adjusted item quality estimation (only affects the colour of the text)

Change Log 3x04y04
-fixed the formula used for calculation (scores appear slightly different than before but are more accurate)
-added (rudimentary) gem detection and changed enchant detection:
 -having gems or enchants now gives you a 2% bonus to GS for each gem/enchant
 -does not detect if they're shitty gems/enchants or anything
 -a better system would require having a database of every gem/enchant in the game (and also a database of every item with socket),
  and would thus be way out of the scope of the addon for now
						
Change Log 3x04y03
-removed Heirloom calculation
-fixed hunter score calculation
						
Change Log 3x04y02
-actual release
-polished stuff
-removed titan grip handling because no titan grip here boss
						
Change Log 3x04y01
-Initial port non-release
-Quick and dirty hack to the original to make it function under 2.4.3
 -changed the calculation (quickly and dirtily) to sort of reflect how the addon functioned in wotlk:
  -the very best gear around should give you something like 6000 GS give or take
  -the very best single items around (ilvl 164 for TBC and 284 for WotLK) should have similar individual GS
  -fresh 70 people have about 2000 GS which is similar to what fresh 80's had in wotlk
-removed the "Special" feature that gave people special titles in the tooltips for donating etc, as it was unnecessary on private servers


]]
------------------------------------------------------------------------------

function GearScore_OnEvent(GS_Nil, GS_EventName, GS_Prefix, GS_AddonMessage, GS_Whisper, GS_Sender)
	if ( GS_EventName == "PLAYER_REGEN_ENABLED" ) then GS_PlayerIsInCombat = false; return; end
	if ( GS_EventName == "PLAYER_REGEN_DISABLED" ) then GS_PlayerIsInCombat = true; return; end
	if ( GS_EventName == "PLAYER_EQUIPMENT_CHANGED" ) then
	    local MyGearScore, MyItemLevel = GearScore_GetScore(UnitName("player"), "player");
		local Red, Blue, Green = GearScore_GetQuality(MyGearScore)
    	PersonalGearScore:SetText(MyGearScore); PersonalGearScore:SetTextColor(Red, Green, Blue, 1)
		PersonalItemLevel:SetText(MyItemLevel); PersonalItemLevel:SetTextColor(Red, Green, Blue, 1)
  	end
	if ( GS_EventName == "ADDON_LOADED" ) then
		if ( GS_Prefix == "GearScoreLite" ) then
      		if not ( GS_Settings ) then	GS_Settings = GS_DefaultSettings end
			if not ( GS_Data ) then GS_Data = {}; end; if not ( GS_Data[GetRealmName()] ) then GS_Data[GetRealmName()] = { ["Players"] = {} }; end
  			for i, v in pairs(GS_DefaultSettings) do if not ( GS_Settings[i] ) then GS_Settings[i] = GS_DefaultSettings[i]; end; end
			LoadAddOn("Blizzard_InspectUI")
			C_Timer.After(2, function() 
				GearScoreInspect()
			end)

        end
	end
	if (GS_EventName == "UPDATE_MOUSEOVER_UNIT") then
		MouseoverName = UnitName("mouseover")
		if (MouseoverName == nil) then
			if (GSTimer ~= nil) then
				GSTimer:Cancel()
			end
			--[[if (GSTimer2 ~= nil) then
				GSTimer2:Cancel()
			end]]
		end
	end
end

function GearScoreInspect()
InspectPaperDollFrame:HookScript("OnShow", InspectPaperDoll)
InspectPaperDollFrame:CreateFontString("InspectGearScore")
InspectGearScore:SetFont("Fonts\\FRIZQT__.TTF", 10)
InspectGearScore:SetText("Turned off")
InspectGearScore:SetPoint("BOTTOMLEFT",InspectPaperDollFrame,"TOPLEFT",72,-360)
InspectGearScore:Show()

InspectPaperDollFrame:CreateFontString("InspectGearScoreLabel")
InspectGearScoreLabel:SetFont("Fonts\\FRIZQT__.TTF", 10)
InspectGearScoreLabel:SetText("GearScore")
InspectGearScoreLabel:SetPoint("BOTTOMLEFT",InspectPaperDollFrame,"TOPLEFT",72,-370)
InspectGearScoreLabel:Show()

InspectPaperDollFrame:CreateFontString("InspectItemLevel")
InspectItemLevel:SetFont("Fonts\\FRIZQT__.TTF", 10)
InspectItemLevel:SetText("Turned off")
InspectItemLevel:SetPoint("BOTTOMRIGHT",InspectPaperDollFrame,"TOPRIGHT",-90,-360)
InspectItemLevel:Show()

InspectPaperDollFrame:CreateFontString("InspectItemLevelLabel")
InspectItemLevelLabel:SetFont("Fonts\\FRIZQT__.TTF", 10)
InspectItemLevelLabel:SetText("ItemLevel")
InspectItemLevelLabel:SetPoint("BOTTOMRIGHT",InspectPaperDollFrame,"TOPRIGHT",-90,-370)
InspectItemLevelLabel:Show()
end

function GearScore_GetScoreFix(Name, Target)
	--print(Name);
	if ( UnitIsPlayer(Target) ) then
	    local PlayerClass, PlayerEnglishClass = UnitClass(Target);
		local GearScore = 0; local  TempScore = 0; local PVPScore = 0; local ItemCount = 0; local LevelTotal = 0; local TempEquip = {}; local TempPVPScore = 0
		local ItemLink;
		for i = 1, 18 do
			if ( i ~= 4 ) then
        		ItemLink = GetInventoryItemLink(Target, i)
        		local GS_ItemLinkTable = {}
				if ( ItemLink ) then
        			local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(ItemLink)
        			if ( GS_Settings["Detail"] == 1 ) then GS_ItemLinkTable[i] = ItemLink; end
     				TempScore, ItemLevel = GearScore_GetItemScore(ItemLink);
					if ( i == 16 or i == 17 ) and ( PlayerEnglishClass == "HUNTER" ) then TempScore = TempScore * 0.3164; end
					if ( i == 18 ) and ( PlayerEnglishClass == "HUNTER" ) then TempScore = TempScore * 5.3224; end
					GearScore = GearScore + TempScore;	ItemCount = ItemCount + 1; LevelTotal = LevelTotal + ItemLevel
				end
			end;
		end
		if ( GearScore <= 0 ) and ( Name ~= UnitName("player") ) then
			GearScore = 0; return 0,0;
		elseif ( Name == UnitName("player") ) and ( GearScore <= 0 ) then
		    GearScore = 0; end
	if ( ItemCount == 0 ) then LevelTotal = 0; end		    
	return floor(GearScore), floor(LevelTotal/ItemCount)
	end
end

-------------------------- Get Mouseover Score -----------------------------------
function GearScore_GetScore(Name, Target)
	local TargetName = UnitName(Target)
	if (Name ~=TargetName) then return 0,0; end
	--print(Name);
	if ( UnitIsPlayer(Target) ) then
	    local PlayerClass, PlayerEnglishClass = UnitClass(Target);
		local GearScore = 0; local  TempScore = 0; local PVPScore = 0; local ItemCount = 0; local LevelTotal = 0; local TempEquip = {}; local TempPVPScore = 0
		local ItemLink;
		for i = 1, 18 do
			if ( i ~= 4 ) then
        		ItemLink = GetInventoryItemLink(Target, i)
        		GS_ItemLinkTable = {}
				if ( ItemLink ) then
        			local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(ItemLink)
        			if ( GS_Settings["Detail"] == 1 ) then GS_ItemLinkTable[i] = ItemLink; end
     				TempScore, ItemLevel = GearScore_GetItemScore(ItemLink);
					if ( i == 16 or i == 17 ) and ( PlayerEnglishClass == "HUNTER" ) then TempScore = TempScore * 0.3164; end
					if ( i == 18 ) and ( PlayerEnglishClass == "HUNTER" ) then TempScore = TempScore * 5.3224; end
					GearScore = GearScore + TempScore;	ItemCount = ItemCount + 1; LevelTotal = LevelTotal + ItemLevel
				end
			end;
		end
		if ( GearScore <= 0 ) and ( Name ~= UnitName("player") ) then
			GearScore = 0; return 0,0;
		elseif ( Name == UnitName("player") ) and ( GearScore <= 0 ) then
		    GearScore = 0; end
	if ( ItemCount == 0 ) then LevelTotal = 0; end		    
	return floor(GearScore), floor(LevelTotal/ItemCount)
	end
end

------------------------cool n dirty enchant and gem calc--------------------------
function GearScorePvPTrinketFix(ItemID, ItemLevel)
		if (ItemID == 18852 ) or (ItemID == 18849 ) or (ItemID == 18846 ) or (ItemID == 18834 ) or (ItemID == 18851 ) or (ItemID == 18850 ) or (ItemID == 29592 ) or (ItemID == 18845 ) or (ItemID == 18853 ) or
		(ItemID == 18854 ) or (ItemID == 18858 ) or (ItemID == 29593 ) or (ItemID == 18857 ) or (ItemID == 18856 ) or (ItemID == 18862 ) or (ItemID == 18859 ) or (ItemID == 18864 ) or (ItemID == 18863 ) then
			return 90
		else
			return ItemLevel
		end
end

function GearScore_GetEnchantInfo(ItemLink, ItemEquipLoc)
	local found, _, ItemSubString = string.find(ItemLink, "^|c%x+|H(.+)|h%[.*%]");
	local ItemSubStringTable = {}
	local bonusPercent = 1
	local enchCount = 0

	for v in string.gmatch(ItemSubString, "[^:]+") do tinsert(ItemSubStringTable, v); end
	if ( ItemSubStringTable[3] == "0" ) and( GS_ItemTypes[ItemEquipLoc]["Enchantable"] ) then
		enchCount = enchCount - 1
	end
	for i = 4, 7 do
		if ( ItemSubStringTable[i] ~= "0" ) then
			enchCount = enchCount + 1
		end
	end
	bonusPercent = (floor(2 * (GS_ItemTypes[ItemEquipLoc]["SlotMOD"]) * 100 * enchCount) / 100);
	return(1 + (bonusPercent/100));	
end						

------------------------------ Get Item Score ---------------------------------
function GearScore_GetItemScore(ItemLink)
	local QualityScale = 1; local PVPScale = 1; local PVPScore = 0; local GearScore = 0
	if not ( ItemLink ) then return 0, 0; end
	local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(ItemLink); local Table = {}; local Scale = 2.97
	local ItemID = GetItemInfoFromHyperlink(ItemLink)
	ItemLevel = GearScorePvPTrinketFix(ItemID, ItemLevel)
 	if ( ItemRarity == 5 ) then QualityScale = 1.3; ItemRarity = 4;
	elseif ( ItemRarity == 1 ) then QualityScale = 0.005;  ItemRarity = 2
	elseif ( ItemRarity == 0 ) then QualityScale = 0.005;  ItemRarity = 2 end
    if ( GS_ItemTypes[ItemEquipLoc] ) then
        if ( ItemLevel > 92 ) then Table = GS_Formula["A"]; else Table = GS_Formula["B"]; end
		if ( ItemRarity >= 2 ) and ( ItemRarity <= 4 )then
            local Red, Green, Blue = GearScore_GetQuality((floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * 1 * Scale)) * 16.98 )
            GearScore = floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * GS_ItemTypes[ItemEquipLoc].SlotMOD * Scale * QualityScale)
			if ( GearScore < 0 ) then GearScore = 0;   Red, Green, Blue = GearScore_GetQuality(1); end
			if ( PVPScale == 0.75 ) then PVPScore = 1; GearScore = GearScore * 1; 
			else PVPScore = GearScore * 0; end
			local percent = (GearScore_GetEnchantInfo(ItemLink, ItemEquipLoc) or 1)
			GearScore = floor(GearScore * percent )
			PVPScore = floor(PVPScore)
			return GearScore, ItemLevel, GS_ItemTypes[ItemEquipLoc].ItemSlot, Red, Green, Blue, PVPScore, ItemEquipLoc, percent ;
		end
  	end
  	return -1, ItemLevel, 50, 1, 1, 1, PVPScore, ItemEquipLoc, 1
end
-------------------------------------------------------------------------------

-------------------------------- Get Quality ----------------------------------

function GearScore_GetQuality(ItemScore)
	if ( ItemScore > 5999 ) then ItemScore = 5999; end
	local Red = 0.1; local Blue = 0.1; local Green = 0.1; local GS_QualityDescription = "Legendary"
   	if not ( ItemScore ) then return 0, 0, 0, "Trash"; end
	for i = 0,6 do
		if ( ItemScore > i * 1000 ) and ( ItemScore <= ( ( i + 1 ) * 1000 ) ) then
		    local Red = GS_Quality[( i + 1 ) * 1000].Red["A"] + (((ItemScore - GS_Quality[( i + 1 ) * 1000].Red["B"])*GS_Quality[( i + 1 ) * 1000].Red["C"])*GS_Quality[( i + 1 ) * 1000].Red["D"])
            local Blue = GS_Quality[( i + 1 ) * 1000].Green["A"] + (((ItemScore - GS_Quality[( i + 1 ) * 1000].Green["B"])*GS_Quality[( i + 1 ) * 1000].Green["C"])*GS_Quality[( i + 1 ) * 1000].Green["D"])
            local Green = GS_Quality[( i + 1 ) * 1000].Blue["A"] + (((ItemScore - GS_Quality[( i + 1 ) * 1000].Blue["B"])*GS_Quality[( i + 1 ) * 1000].Blue["C"])*GS_Quality[( i + 1 ) * 1000].Blue["D"])
			--if not ( Red ) or not ( Blue ) or not ( Green ) then return 0.1, 0.1, 0.1, nil; end
			return Red, Green, Blue, GS_Quality[( i + 1 ) * 1000].Description
		end
	end
return 255, 255, 255
end
-------------------------------------------------------------------------------

----------------------------- Hook Set Unit -----------------------------------
function GearScore_HookSetUnit(arg1, arg2)
    if ( GS_PlayerIsInCombat ) then return; end
	if ( GS_Settings["Player"] ~= 1 ) then return; end
	--if UnitIsUnit("target", "mouseover") then return;end
    local Name = GameTooltip:GetUnit()
	local MouseOverGearScore, MouseOverAverage = 0, 0
    if ( CheckInteractDistance("mouseover", 1) ) and ( UnitName("mouseover") == Name ) and not (GS_PlayerIsInCombat ) then
        GSTimer = C_Timer.NewTimer(2, function()
				local NameAfter1 = GameTooltip:GetUnit()
				if (NameAfter1 ~= Name) then return; end
                NotifyInspect("mouseover")
				--GSTimer2 = C_Timer.NewTimer(1, function()
                InspectF:RegisterEvent("INSPECT_READY")
                InspectF:SetScript("OnEvent", function(self, event, arg1)
						ClearInspectPlayer()
						NotifyInspect("mouseover")
						InspectF2:RegisterEvent("INSPECT_READY")
						InspectF2:SetScript("OnEvent", function(self, event, arg1)
							local NameAfter = GameTooltip:GetUnit()
							MouseOverGearScore, MouseOverAverage = GearScore_GetScore(NameAfter, "mouseover") 
							if (MouseOverGearScore == nil) or (MouseOverAverage == nil) then return; end
							if ( MouseOverGearScore > 0 ) and ( MouseOverGearScore > 0 ) and ( GS_Settings["Player"] == 1 ) then
								if ( GS_Settings["Player"] == 1 ) then                    
										local Red, Blue, Green = GearScore_GetQuality(MouseOverGearScore)
										GearScore_UpdateGTData(MouseOverGearScore, MouseOverAverage, Red, Blue, Green)
										--if ( GS_Settings["Level"] == 1 ) then                        
											--GameTooltip:AddDoubleLine("GearScore: " .. MouseOverGearScore, "(ItemLevel: " .. MouseOverAverage .. ")", Red, Green, Blue, Red, Green, Blue)
											--GameTooltip:Show()
										--[[else
											GameTooltip:AddLine("GearScore: " .. MouseOverGearScore, Red, Green, Blue)
											GameTooltip:Show()
										end]]                             
								end
							end
						end)
				if InspectF:IsEventRegistered("INSPECT_READY") then
					InspectF:UnregisterEvent("INSPECT_READY")
				end
				end)
				--end)
        end)
    end
	--ClearInspectPlayer()
end

function GearScore_UpdateGTData(GearScore, ItemLevel, Red, Blue, Green)
	local i, TooltipFound = 0, 0
	 for i=2, GameTooltip:NumLines() do
		if (_G["GameTooltipTextLeft" .. i]:GetText(""):find("GearScore")) then
			TooltipFound = i
			break
		end
    end
	if (TooltipFound > 0) then
		_G["GameTooltipTextLeft"..TooltipFound]:SetText("GearScore: " .. GearScore)
		_G["GameTooltipTextLeft"..TooltipFound]:SetTextColor(Red, Green, Blue) 
		_G["GameTooltipTextRight"..TooltipFound]:SetText("(ItemLevel: "..ItemLevel..")")
		_G["GameTooltipTextRight"..TooltipFound]:SetTextColor(Red, Green, Blue) 
	else
		GameTooltip:AddDoubleLine("GearScore: " .. GearScore, "(ItemLevel: " .. ItemLevel .. ")", Red, Green, Blue, Red, Green, Blue)
		GameTooltip:Show()
	end
	
end

function GearScore_GetScoreInspect(Name)
    if ( GS_PlayerIsInCombat ) then return; end
    local IGearScore, IItemLevel = 0, 0
    if ( CheckInteractDistance("target", 1) ) and not (GS_PlayerIsInCombat ) then

        local GSTimerInspect = C_Timer.NewTimer(1, function()    
			        ClearInspectPlayer()
        NotifyInspect("target")
			InspectFT:RegisterEvent("INSPECT_READY")
			InspectFT:SetScript("OnEvent", function(self, event, arg1)
				IGearScore, IItemLevel = GearScore_GetScoreFix(Name, "target")            
				GearScore_SetTargetData(IGearScore, IItemLevel)
				if InspectFT:IsEventRegistered("INSPECT_READY") then
					InspectFT:UnregisterEvent("INSPECT_READY")
				end
			end)
        end)
    end
end


function GearScore_HookSetUnitEvent(arg1, arg2)
    if ( GS_PlayerIsInCombat ) then return; end
    local Name = GameTooltip:GetUnit();local MouseOverGearScore, MouseOverAverage = 0, 0
    if ( CheckInteractDistance("mouseover", 1) ) and ( UnitName("mouseover") == Name ) and not ( GS_PlayerIsInCombat ) then      
		C_Timer.After(3, function()	
			local NameAfter = GameTooltip:GetUnit()
			if (NameAfter == Name) then	
				NotifyInspect("mouseover")
				InspectF:RegisterEvent("INSPECT_READY")
				InspectF:SetScript("OnEvent", function(self, event, arg1)
					MouseOverGearScore, MouseOverAverage = GearScore_GetScore(Name, "mouseover")           
					if ( MouseOverGearScore > 0 ) and ( MouseOverGearScore > 0 ) and ( GS_Settings["Player"] == 1 ) then
						if ( GS_Settings["Player"] == 1 ) then                    
								local Red, Blue, Green = GearScore_GetQuality(MouseOverGearScore)
								--if ( GS_Settings["Level"] == 1 ) then                        
									GameTooltip:AddDoubleLine("GearScore: " .. MouseOverGearScore, "(ItemLevel: " .. MouseOverAverage .. ")", Red, Green, Blue, Red, Green, Blue)
									GameTooltip:Show()
								--[[else
									GameTooltip:AddLine("GearScore: " .. MouseOverGearScore, Red, Green, Blue)
									GameTooltip:Show()
								end]]
								ClearInspectPlayer()
						end
					end
				end)
			end
		end)
    end
end

function GearScore_HookSetUnit2(arg1, arg2)
	return GearScore_HookSetUnit(arg1, arg2)
end

function GearScore_SetDetails(tooltip, Name)
    if not ( UnitName("mouseover") ) or ( UnitName("mouseover") ~= Name )then return; end
  	for i = 1,18 do
  	    if not ( i == 4 ) then
    		local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(GS_ItemLinkTable[i])
			if ( ItemLink ) then
				local GearScore, ItemLevel, ItemType, Red, Green, Blue = GearScore_GetItemScore(ItemLink)
				--local Red, Green, Blue = GearScore_GetQuality((floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * 1 * 1.8618)) * 11.25 )
				if ( GearScore ) and ( i ~= 4 ) then
    			   	local Add = ""
	        		if ( GS_Settings["Level"] == 1 ) then Add = " (iLevel "..tostring(ItemLevel)..")"; end
    	         	tooltip:AddDoubleLine("["..ItemName.."]", tostring(GearScore)..Add, GS_Rarity[ItemRarity].Red, GS_Rarity[ItemRarity].Green, GS_Rarity[ItemRarity].Blue, Red, Blue, Green)
        		end
			end
		end
	end
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function GearScore_HookSetItem() ItemName, ItemLink = GameTooltip:GetItem(); GearScore_HookItem(ItemName, ItemLink, GameTooltip); end
function GearScore_HookRefItem() ItemName, ItemLink = ItemRefTooltip:GetItem(); GearScore_HookItem(ItemName, ItemLink, ItemRefTooltip); end
function GearScore_HookCompareItem() ItemName, ItemLink = ShoppingTooltip1:GetItem(); GearScore_HookItem(ItemName, ItemLink, ShoppingTooltip1); end
function GearScore_HookCompareItem2() ItemName, ItemLink = ShoppingTooltip2:GetItem(); GearScore_HookItem(ItemName, ItemLink, ShoppingTooltip2); end
function GearScore_HookItem(ItemName, ItemLink, Tooltip)
	if ( GS_PlayerIsInCombat ) then return; end
	local PlayerClass, PlayerEnglishClass = UnitClass("player");
	if not ( IsEquippableItem(ItemLink) ) then return; end
	local ItemScore, ItemLevel, EquipLoc, Red, Green, Blue, PVPScore, ItemEquipLoc, enchantPercent = GearScore_GetItemScore(ItemLink);
 	if ( ItemScore >= 0 ) then
		if ( GS_Settings["Item"] == 1 ) then
  			if ( ItemLevel ) --[[and ( GS_Settings["Level"] == 1 )]] then Tooltip:AddDoubleLine("GearScore: "..ItemScore, "(iLevel "..ItemLevel..")", Red, Blue, Green, Red, Blue, Green);
				if ( PlayerEnglishClass == "HUNTER" ) then
					if ( ItemEquipLoc == "INVTYPE_RANGEDRIGHT" ) or ( ItemEquipLoc == "INVTYPE_RANGED" ) then
						Tooltip:AddLine("HunterScore: "..floor(ItemScore * 5.3224), Red, Blue, Green)
					end
					if ( ItemEquipLoc == "INVTYPE_2HWEAPON" ) or ( ItemEquipLoc == "INVTYPE_WEAPONMAINHAND" ) or ( ItemEquipLoc == "INVTYPE_WEAPONOFFHAND" ) or ( ItemEquipLoc == "INVTYPE_WEAPON" ) or ( ItemEquipLoc == "INVTYPE_HOLDABLE" )  then
						Tooltip:AddLine("HunterScore: "..floor(ItemScore * 0.3164), Red, Blue, Green)
					end
				end
			else
				Tooltip:AddLine("GearScore: "..ItemScore, Red, Blue, Green)
				if ( PlayerEnglishClass == "HUNTER" ) then
					if ( ItemEquipLoc == "INVTYPE_RANGEDRIGHT" ) or ( ItemEquipLoc == "INVTYPE_RANGED" ) then
						Tooltip:AddLine("HunterScore: "..floor(ItemScore * 5.3224), Red, Blue, Green)
					end
					if ( ItemEquipLoc == "INVTYPE_2HWEAPON" ) or ( ItemEquipLoc == "INVTYPE_WEAPONMAINHAND" ) or ( ItemEquipLoc == "INVTYPE_WEAPONOFFHAND" ) or ( ItemEquipLoc == "INVTYPE_WEAPON" ) or ( ItemEquipLoc == "INVTYPE_HOLDABLE" )  then
						Tooltip:AddLine("HunterScore: "..floor(ItemScore * 0.3164), Red, Blue, Green)
					end
				end
    		end
--RebuildThis            if ( GS_Settings["ML"] == 1 ) then GearScore_EquipCompare(Tooltip, ItemScore, EquipLoc, ItemLink); end
  		end
	else
	    if --[[( GS_Settings["Level"] == 1 ) and]] ( ItemLevel ) then
	        Tooltip:AddLine("iLevel "..ItemLevel)
		end
    end
end
function GearScore_OnEnter(Name, ItemSlot, Argument)
	if ( UnitName("target") ) then NotifyInspect("target"); GS_LastNotified = UnitName("target"); end
	local OriginalOnEnter = GearScore_Original_SetInventoryItem(Name, ItemSlot, Argument); return OriginalOnEnter
end
function MyPaperDoll()
	if ( GS_PlayerIsInCombat ) then return; end
	local MyGearScore, MyItemLevel  = GearScore_GetScore(UnitName("player"), "player");
	local Red, Blue, Green = GearScore_GetQuality(MyGearScore)
    PersonalGearScore:SetText(MyGearScore); PersonalGearScore:SetTextColor(Red, Green, Blue, 1)
	PersonalItemLevel:SetText(MyItemLevel); PersonalItemLevel:SetTextColor(Red, Green, Blue, 1)
end

function InspectPaperDoll()
	if ( GS_PlayerIsInCombat ) then return; end
	if ( GS_Settings["Player"] == 1 ) then 	GearScore_GetScoreInspect(UnitName("target"))	end
end

function GearScore_SetTargetData(IGearScore, IItemLevel)
local Red, Blue, Green = GearScore_GetQuality(IGearScore)
	InspectGearScore:SetText(IGearScore); InspectGearScore:SetTextColor(Red, Green, Blue, 1)
	InspectItemLevel:SetText(IItemLevel); InspectItemLevel:SetTextColor(Red, Green, Blue, 1)
end
-------------------------------------------------------------------------------

----------------------------- Reports -----------------------------------------

---------------GS-SPAM Slasch Command--------------------------------------
function GS_MANSET(Command)
	local output
	if ( strlower(Command) == "" ) or ( strlower(Command) == "options" ) or ( strlower(Command) == "option" ) or ( strlower(Command) == "help" ) then for i,v in ipairs(GS_CommandList) do DEFAULT_CHAT_FRAME:AddMessage(v); end; 
	for i,v in pairs(GS_Settings) do if (v == 1) then output = i..": On" else output = i..": Off" end; DEFAULT_CHAT_FRAME:AddMessage(output); end; return; end;
	--if ( strlower(Command) == "show" ) then GS_Settings["Player"] = GS_ShowSwitch[GS_Settings["Player"]]; if ( GS_Settings["Player"] == 1 ) or ( GS_Settings["Player"] == 2 ) then DEFAULT_CHAT_FRAME:AddMessage("Player Scores: On"); else DEFAULT_CHAT_FRAME:AddMessage("Player Scores: Off"); end; return; end
	if ( strlower(Command) == "player" ) then GS_Settings["Player"] = GS_ShowSwitch[GS_Settings["Player"]]; if ( GS_Settings["Player"] == 1 ) or ( GS_Settings["Player"] == 2 ) then DEFAULT_CHAT_FRAME:AddMessage("Player Scores: On"); else DEFAULT_CHAT_FRAME:AddMessage("Player Scores: Off"); end; return; end
    if ( strlower(Command) == "item" ) then GS_Settings["Item"] = GS_ItemSwitch[GS_Settings["Item"]]; if ( GS_Settings["Item"] == 1 ) or ( GS_Settings["Item"] == 3 ) then DEFAULT_CHAT_FRAME:AddMessage("Item Scores: On"); else DEFAULT_CHAT_FRAME:AddMessage("Item Scores: Off"); end; return; end
	--if ( strlower(Command) == "level" ) then GS_Settings["Level"] = GS_Settings["Level"] * -1; if ( GS_Settings["Level"] == 1 ) then DEFAULT_CHAT_FRAME:AddMessage("Item Levels: On"); else DEFAULT_CHAT_FRAME:AddMessage("Item Levels: Off"); end; return; end
	--if ( strlower(Command) == "compare" ) then GS_Settings["Compare"] = GS_Settings["Compare"] * -1; if ( GS_Settings["Compare"] == 1 ) then DEFAULT_CHAT_FRAME:AddMessage("Comparisons: On"); else DEFAULT_CHAT_FRAME:AddMessage("Comparisons: Off"); end; return; end
	DEFAULT_CHAT_FRAME:AddMessage("GearScore: Unknown Command. Type '/gs' for a list of options")
end


------------------------ GUI PROGRAMS -------------------------------------------------------

local f = CreateFrame("Frame", "GearScore", UIParent)
local InspectF = CreateFrame("Frame", "InspectF", UIParent)
local InspectF2 = CreateFrame("Frame", "InspectF2", UIParent)
local InspectFT = CreateFrame("Frame", "InspectFT", UIParent)

f:SetScript("OnEvent", GearScore_OnEvent)
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
GameTooltip:HookScript("OnTooltipSetUnit", GearScore_HookSetUnit2)
GameTooltip:HookScript("OnTooltipSetItem", GearScore_HookSetItem)
ItemRefTooltip:HookScript("OnTooltipSetItem", GearScore_HookRefItem)

ShoppingTooltip1:HookScript("OnTooltipSetItem", GearScore_HookCompareItem)
ShoppingTooltip2:HookScript("OnTooltipSetItem", GearScore_HookCompareItem2)
PaperDollFrame:HookScript("OnShow", MyPaperDoll)


--[[
GameTooltip:CreateFontString("GameTooltipScore")
GameTooltipScore:SetFont("Fonts\\FRIZQT__.TTF", 10)
GameTooltipScore:SetText("xx: 0")
GameTooltipScore:SetPoint("TOPLEFT",GameTooltip,"TOPLEFT",5,-60)
GameTooltipScore:Show()]]

PaperDollFrame:CreateFontString("PersonalGearScore")
PersonalGearScore:SetFont("Fonts\\FRIZQT__.TTF", 10)
PersonalGearScore:SetText("gs: 0")
PersonalGearScore:SetPoint("BOTTOMLEFT",PaperDollFrame,"TOPLEFT",72,-253)
PersonalGearScore:Show()

PaperDollFrame:CreateFontString("GearScore2")
GearScore2:SetFont("Fonts\\FRIZQT__.TTF", 10)
GearScore2:SetText("GearScore")
GearScore2:SetPoint("BOTTOMLEFT",PaperDollFrame,"TOPLEFT",72,-265)
GearScore2:Show()

PaperDollFrame:CreateFontString("PersonalItemLevel")
PersonalItemLevel:SetFont("Fonts\\FRIZQT__.TTF", 10)
PersonalItemLevel:SetText("ilvl: 0")
PersonalItemLevel:SetPoint("BOTTOMRIGHT",PaperDollFrame,"TOPRIGHT",-90,-253)
PersonalItemLevel:Show()

PaperDollFrame:CreateFontString("ItemLevelLabel")
ItemLevelLabel:SetFont("Fonts\\FRIZQT__.TTF", 10)
ItemLevelLabel:SetText("ItemLevel")
ItemLevelLabel:SetPoint("BOTTOMRIGHT",PaperDollFrame,"TOPRIGHT",-90,-265)
ItemLevelLabel:Show()

--GearScore_Original_SetInventoryItem = GameTooltip.SetInventoryItem
--GameTooltip.SetInventoryItem = GearScore_OnEnter

SlashCmdList["MY22SCRIPT"] = GS_MANSET
--SLASH_MY22SCRIPT1 = "/gset"
SLASH_MY22SCRIPT1 = "/gs"
SLASH_MY22SCRIPT2 = "/gearscore"

