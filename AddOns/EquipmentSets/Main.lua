-- SavedVariables
savedSet1 = {}
savedSet2 = {}
savedSet3 = {}
savedSet4 = {}
savedSet5 = {}
savedSet6 = {}
savedSet7 = {}
savedSet8 = {}
savedSet9 = {}
savedSet10 = {}

-- Default
loadSlotTitles = {"Load 1", "Load 2", "Load 3", "Load 4", "Load 5", "Load 6", "Load 7", "Load 8", "Load 9", "Load 10"}


slots = {"AmmoSlot", "HeadSlot", "NeckSlot", "ShoulderSlot", "ShirtSlot", "ChestSlot", "WaistSlot", "LegsSlot", "FeetSlot", "WristSlot", "HandsSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "BackSlot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot", "TabardSlot"}
slotsDisplay = {"Ammo: \n[", "Head: \n[", "Neck: \n[", "Shoulder: \n[", "Shirt: \n[", "Chest: \n[", "Waist: \n[", "Legs: \n[", "Feet: \n[", "Wrist: \n[", "Hands: \n[", "Finger 1: \n[", "Finger 2: \n[", "Trinket 1: \n[", "Trinket 2: \n[", "Back: \n[", "Main Hand: \n[", "Off Hand: \n[", "Ranged: \n[", "Tabard: \n["}


-- Dump function
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


function saveTheCurrentSet(currentSetNumber)
	if currentSetNumber == "1" then
		savedSet1 = {}
		for x = 1, 20 do
			local slotID = GetInventorySlotInfo(slots[x])
			local itemLink = GetInventoryItemLink("player", slotID)
			if itemLink == nil then 
				table.insert(savedSet1, tostring("EMPTY SLOT"))
			else
				local name, _, _, ilvl = GetItemInfo(itemLink)
				table.insert(savedSet1, tostring(name))
			end
		end
	elseif currentSetNumber == "2" then
		savedSet2 = {}
		for x = 1, 20 do
			local slotID = GetInventorySlotInfo(slots[x])
			local itemLink = GetInventoryItemLink("player", slotID)
			if itemLink == nil then 
				table.insert(savedSet2, tostring("EMPTY SLOT"))
			else
				local name, _, _, ilvl = GetItemInfo(itemLink)
				table.insert(savedSet2, tostring(name))
			end
		end
	elseif currentSetNumber == "3" then
		savedSet3 = {}
		for x = 1, 20 do
			local slotID = GetInventorySlotInfo(slots[x])
			local itemLink = GetInventoryItemLink("player", slotID)
			if itemLink == nil then 
				table.insert(savedSet3, tostring("EMPTY SLOT"))
			else
				local name, _, _, ilvl = GetItemInfo(itemLink)
				table.insert(savedSet3, tostring(name))
			end
		end
	elseif currentSetNumber == "4" then
		savedSet4 = {}
		for x = 1, 20 do
			local slotID = GetInventorySlotInfo(slots[x])
			local itemLink = GetInventoryItemLink("player", slotID)
			if itemLink == nil then 
				table.insert(savedSet4, tostring("EMPTY SLOT"))
			else
				local name, _, _, ilvl = GetItemInfo(itemLink)
				table.insert(savedSet4, tostring(name))
			end
		end
	elseif currentSetNumber == "5" then
		savedSet5 = {}
		for x = 1, 20 do
			local slotID = GetInventorySlotInfo(slots[x])
			local itemLink = GetInventoryItemLink("player", slotID)
			if itemLink == nil then 
				table.insert(savedSet5, tostring("EMPTY SLOT"))
			else
				local name, _, _, ilvl = GetItemInfo(itemLink)
				table.insert(savedSet5, tostring(name))
			end
		end
	elseif currentSetNumber == "6" then
		savedSet6 = {}
		for x = 1, 20 do
			local slotID = GetInventorySlotInfo(slots[x])
			local itemLink = GetInventoryItemLink("player", slotID)
			if itemLink == nil then 
				table.insert(savedSet6, tostring("EMPTY SLOT"))
			else
				local name, _, _, ilvl = GetItemInfo(itemLink)
				table.insert(savedSet6, tostring(name))
			end
		end
	elseif currentSetNumber == "7" then
		savedSet7 = {}
		for x = 1, 20 do
			local slotID = GetInventorySlotInfo(slots[x])
			local itemLink = GetInventoryItemLink("player", slotID)
			if itemLink == nil then 
				table.insert(savedSet7, tostring("EMPTY SLOT"))
			else
				local name, _, _, ilvl = GetItemInfo(itemLink)
				table.insert(savedSet7, tostring(name))
			end
		end
	elseif currentSetNumber == "8" then
		savedSet8 = {}
		for x = 1, 20 do
			local slotID = GetInventorySlotInfo(slots[x])
			local itemLink = GetInventoryItemLink("player", slotID)
			if itemLink == nil then 
				table.insert(savedSet8, tostring("EMPTY SLOT"))
			else
				local name, _, _, ilvl = GetItemInfo(itemLink)
				table.insert(savedSet8, tostring(name))
			end
		end
	elseif currentSetNumber == "9" then
		savedSet9 = {}
		for x = 1, 20 do
			local slotID = GetInventorySlotInfo(slots[x])
			local itemLink = GetInventoryItemLink("player", slotID)
			if itemLink == nil then 
				table.insert(savedSet9, tostring("EMPTY SLOT"))
			else
				local name, _, _, ilvl = GetItemInfo(itemLink)
				table.insert(savedSet9, tostring(name))
			end
		end
	elseif currentSetNumber == "10" then
		savedSet10 = {}
		for x = 1, 20 do
			local slotID = GetInventorySlotInfo(slots[x])
			local itemLink = GetInventoryItemLink("player", slotID)
			if itemLink == nil then 
				table.insert(savedSet10, tostring("EMPTY SLOT"))
			else
				local name, _, _, ilvl = GetItemInfo(itemLink)
				table.insert(savedSet10, tostring(name))
			end
		end
	end
end


function loadTheSet(currentSetNumber)
	--DEFAULT_CHAT_FRAME.editBox:SetText("/unequipall") ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
	--C_Timer.After(2, function()
		if currentSetNumber == "1" then
			if next(savedSet1) == nil then
				print("You must save a set to this slot first.")
			else
				for x = 1, 20 do
					DEFAULT_CHAT_FRAME.editBox:SetText("/equip " .. savedSet1[x]) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end
			end
		elseif currentSetNumber == "2" then
			if next(savedSet2) == nil then
				print("You must save a set to this slot first.")
			else
				for x = 1, 20 do
					DEFAULT_CHAT_FRAME.editBox:SetText("/equip " .. savedSet2[x]) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end
			end
		elseif currentSetNumber == "3" then
			if next(savedSet3) == nil then
				print("You must save a set to this slot first.")
			else
				for x = 1, 20 do
					DEFAULT_CHAT_FRAME.editBox:SetText("/equip " .. savedSet3[x]) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end
			end
		elseif currentSetNumber == "4" then
			if next(savedSet4) == nil then
				print("You must save a set to this slot first.")
			else
				for x = 1, 20 do
					DEFAULT_CHAT_FRAME.editBox:SetText("/equip " .. savedSet4[x]) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end
			end
		elseif currentSetNumber == "5" then
			if next(savedSet5) == nil then
				print("You must save a set to this slot first.")
			else
				for x = 1, 20 do
					DEFAULT_CHAT_FRAME.editBox:SetText("/equip " .. savedSet5[x]) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end
			end
		elseif currentSetNumber == "6" then
			if next(savedSet6) == nil then
				print("You must save a set to this slot first.")
			else
				for x = 1, 20 do
					DEFAULT_CHAT_FRAME.editBox:SetText("/equip " .. savedSet6[x]) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end
			end
		elseif currentSetNumber == "7" then
			if next(savedSet7) == nil then
				print("You must save a set to this slot first.")
			else
				for x = 1, 20 do
					DEFAULT_CHAT_FRAME.editBox:SetText("/equip " .. savedSet7[x]) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end
			end
		elseif currentSetNumber == "8" then
			if next(savedSet8) == nil then
				print("You must save a set to this slot first.")
			else
				for x = 1, 20 do
					DEFAULT_CHAT_FRAME.editBox:SetText("/equip " .. savedSet8[x]) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end
			end
		elseif currentSetNumber == "9" then
			if next(savedSet9) == nil then
				print("You must save a set to this slot first.")
			else
				for x = 1, 20 do
					DEFAULT_CHAT_FRAME.editBox:SetText("/equip " .. savedSet9[x]) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end
			end
		elseif currentSetNumber == "10" then
			if next(savedSet10) == nil then
				print("You must save a set to this slot first.")
			else
				for x = 1, 20 do
					DEFAULT_CHAT_FRAME.editBox:SetText("/equip " .. savedSet10[x]) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end
			end
		end
	--end)
end


-- Save
SLASH_SAVESET11 = "/saveset1"
SLASH_SAVESET21 = "/saveset2"
SLASH_SAVESET31 = "/saveset3"
SLASH_SAVESET41 = "/saveset4"
SLASH_SAVESET51 = "/saveset5"
SLASH_SAVESET61 = "/saveset6"
SLASH_SAVESET71 = "/saveset7"
SLASH_SAVESET81 = "/saveset8"
SLASH_SAVESET91 = "/saveset9"
SLASH_SAVESET101 = "/saveset10"

-- Load
SLASH_LOADSET11 = "/loadset1"
SLASH_LOADSET21 = "/loadset2"
SLASH_LOADSET31 = "/loadset3"
SLASH_LOADSET41 = "/loadset4"
SLASH_LOADSET51 = "/loadset5"
SLASH_LOADSET61 = "/loadset6"
SLASH_LOADSET71 = "/loadset7"
SLASH_LOADSET81 = "/loadset8"
SLASH_LOADSET91 = "/loadset9"
SLASH_LOADSET101 = "/loadset10"


-- Save
SlashCmdList["SAVESET1"] = function(msg)
   print("Saved set 1.")
   currentSetNumber = "1"
   saveTheCurrentSet(currentSetNumber)
end

SlashCmdList["SAVESET2"] = function(msg)
   print("Saved set 2.")
   currentSetNumber = "2"
   saveTheCurrentSet(currentSetNumber)
end

SlashCmdList["SAVESET3"] = function(msg)
   print("Saved set 3.")
   currentSetNumber = "3"
   saveTheCurrentSet(currentSetNumber)
end

SlashCmdList["SAVESET4"] = function(msg)
   print("Saved set 4.")
   currentSetNumber = "4"
   saveTheCurrentSet(currentSetNumber)
end

SlashCmdList["SAVESET5"] = function(msg)
   print("Saved set 5.")
   currentSetNumber = "5"
   saveTheCurrentSet(currentSetNumber)
end

SlashCmdList["SAVESET6"] = function(msg)
   print("Saved set 6.")
   currentSetNumber = "6"
   saveTheCurrentSet(currentSetNumber)
end

SlashCmdList["SAVESET7"] = function(msg)
   print("Saved set 7.")
   currentSetNumber = "7"
   saveTheCurrentSet(currentSetNumber)
end

SlashCmdList["SAVESET8"] = function(msg)
   print("Saved set 8.")
   currentSetNumber = "8"
   saveTheCurrentSet(currentSetNumber)
end

SlashCmdList["SAVESET9"] = function(msg)
   print("Saved set 9.")
   currentSetNumber = "9"
   saveTheCurrentSet(currentSetNumber)
end

SlashCmdList["SAVESET10"] = function(msg)
   print("Saved set 10.")
   currentSetNumber = "10"
   saveTheCurrentSet(currentSetNumber)
end


-- Load
SlashCmdList["LOADSET1"] = function(msg)
   print("Loaded set 1.")
   currentSetNumber = "1"
   for zz=0,20 do
		if tostring(savedSet1[zz]) == "EMPTY SLOT" then
			C_Timer.After(0.3, function()
				PickupInventoryItem(zz-1) PutItemInBackpack();
				C_Timer.After(0.3, function()
					PickupInventoryItem(zz-1) PutItemInBag(20);
					C_Timer.After(0.3, function()
						PickupInventoryItem(zz-1) PutItemInBag(21);
						C_Timer.After(0.3, function()
							PickupInventoryItem(zz-1) PutItemInBag(22);
							C_Timer.After(0.3, function()
								PickupInventoryItem(zz-1) PutItemInBag(23);
								return
							end)
						end)
					end)
				end)
			end)
		end
	end
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET2"] = function(msg)
   print("Loaded set 2.")
   currentSetNumber = "2"
   for zz=0,20 do
		if tostring(savedSet2[zz]) == "EMPTY SLOT" then
			C_Timer.After(0.3, function()
				PickupInventoryItem(zz-1) PutItemInBackpack();
				C_Timer.After(0.3, function()
					PickupInventoryItem(zz-1) PutItemInBag(20);
					C_Timer.After(0.3, function()
						PickupInventoryItem(zz-1) PutItemInBag(21);
						C_Timer.After(0.3, function()
							PickupInventoryItem(zz-1) PutItemInBag(22);
							C_Timer.After(0.3, function()
								PickupInventoryItem(zz-1) PutItemInBag(23);
								return
							end)
						end)
					end)
				end)
			end)
		end
	end
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET3"] = function(msg)
   print("Loaded set 3.")
   currentSetNumber = "3"
   for zz=0,20 do
		if tostring(savedSet3[zz]) == "EMPTY SLOT" then
			C_Timer.After(0.3, function()
				PickupInventoryItem(zz-1) PutItemInBackpack();
				C_Timer.After(0.3, function()
					PickupInventoryItem(zz-1) PutItemInBag(20);
					C_Timer.After(0.3, function()
						PickupInventoryItem(zz-1) PutItemInBag(21);
						C_Timer.After(0.3, function()
							PickupInventoryItem(zz-1) PutItemInBag(22);
							C_Timer.After(0.3, function()
								PickupInventoryItem(zz-1) PutItemInBag(23);
								return
							end)
						end)
					end)
				end)
			end)
		end
	end
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET4"] = function(msg)
   print("Loaded set 4.")
   currentSetNumber = "4"
   for zz=0,20 do
		if tostring(savedSet4[zz]) == "EMPTY SLOT" then
			C_Timer.After(0.3, function()
				PickupInventoryItem(zz-1) PutItemInBackpack();
				C_Timer.After(0.3, function()
					PickupInventoryItem(zz-1) PutItemInBag(20);
					C_Timer.After(0.3, function()
						PickupInventoryItem(zz-1) PutItemInBag(21);
						C_Timer.After(0.3, function()
							PickupInventoryItem(zz-1) PutItemInBag(22);
							C_Timer.After(0.3, function()
								PickupInventoryItem(zz-1) PutItemInBag(23);
								return
							end)
						end)
					end)
				end)
			end)
		end
	end
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET5"] = function(msg)
   print("Loaded set 5.")
   currentSetNumber = "5"
   for zz=0,20 do
		if tostring(savedSet5[zz]) == "EMPTY SLOT" then
			C_Timer.After(0.3, function()
				PickupInventoryItem(zz-1) PutItemInBackpack();
				C_Timer.After(0.3, function()
					PickupInventoryItem(zz-1) PutItemInBag(20);
					C_Timer.After(0.3, function()
						PickupInventoryItem(zz-1) PutItemInBag(21);
						C_Timer.After(0.3, function()
							PickupInventoryItem(zz-1) PutItemInBag(22);
							C_Timer.After(0.3, function()
								PickupInventoryItem(zz-1) PutItemInBag(23);
								return
							end)
						end)
					end)
				end)
			end)
		end
	end
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET6"] = function(msg)
   print("Loaded set 6.")
   currentSetNumber = "6"
   for zz=0,20 do
		if tostring(savedSet6[zz]) == "EMPTY SLOT" then
			C_Timer.After(0.3, function()
				PickupInventoryItem(zz-1) PutItemInBackpack();
				C_Timer.After(0.3, function()
					PickupInventoryItem(zz-1) PutItemInBag(20);
					C_Timer.After(0.3, function()
						PickupInventoryItem(zz-1) PutItemInBag(21);
						C_Timer.After(0.3, function()
							PickupInventoryItem(zz-1) PutItemInBag(22);
							C_Timer.After(0.3, function()
								PickupInventoryItem(zz-1) PutItemInBag(23);
								return
							end)
						end)
					end)
				end)
			end)
		end
	end
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET7"] = function(msg)
   print("Loaded set 7.")
   currentSetNumber = "7"
   for zz=0,20 do
		if tostring(savedSet7[zz]) == "EMPTY SLOT" then
			C_Timer.After(0.3, function()
				PickupInventoryItem(zz-1) PutItemInBackpack();
				C_Timer.After(0.3, function()
					PickupInventoryItem(zz-1) PutItemInBag(20);
					C_Timer.After(0.3, function()
						PickupInventoryItem(zz-1) PutItemInBag(21);
						C_Timer.After(0.3, function()
							PickupInventoryItem(zz-1) PutItemInBag(22);
							C_Timer.After(0.3, function()
								PickupInventoryItem(zz-1) PutItemInBag(23);
								return
							end)
						end)
					end)
				end)
			end)
		end
	end
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET8"] = function(msg)
   print("Loaded set 8.")
   currentSetNumber = "8"
   for zz=0,20 do
		if tostring(savedSet8[zz]) == "EMPTY SLOT" then
			C_Timer.After(0.3, function()
				PickupInventoryItem(zz-1) PutItemInBackpack();
				C_Timer.After(0.3, function()
					PickupInventoryItem(zz-1) PutItemInBag(20);
					C_Timer.After(0.3, function()
						PickupInventoryItem(zz-1) PutItemInBag(21);
						C_Timer.After(0.3, function()
							PickupInventoryItem(zz-1) PutItemInBag(22);
							C_Timer.After(0.3, function()
								PickupInventoryItem(zz-1) PutItemInBag(23);
								return
							end)
						end)
					end)
				end)
			end)
		end
	end
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET9"] = function(msg)
   print("Loaded set 9.")
   currentSetNumber = "9"
   for zz=0,20 do
		if tostring(savedSet9[zz]) == "EMPTY SLOT" then
			C_Timer.After(0.3, function()
				PickupInventoryItem(zz-1) PutItemInBackpack();
				C_Timer.After(0.3, function()
					PickupInventoryItem(zz-1) PutItemInBag(20);
					C_Timer.After(0.3, function()
						PickupInventoryItem(zz-1) PutItemInBag(21);
						C_Timer.After(0.3, function()
							PickupInventoryItem(zz-1) PutItemInBag(22);
							C_Timer.After(0.3, function()
								PickupInventoryItem(zz-1) PutItemInBag(23);
								return
							end)
						end)
					end)
				end)
			end)
		end
	end
   loadTheSet(currentSetNumber)
end 

SlashCmdList["LOADSET10"] = function(msg)
   print("Loaded set 10.")
   currentSetNumber = "10"
   for zz=0,20 do
		if tostring(savedSet10[zz]) == "EMPTY SLOT" then
			C_Timer.After(0.3, function()
				PickupInventoryItem(zz-1) PutItemInBackpack();
				C_Timer.After(0.3, function()
					PickupInventoryItem(zz-1) PutItemInBag(20);
					C_Timer.After(0.3, function()
						PickupInventoryItem(zz-1) PutItemInBag(21);
						C_Timer.After(0.3, function()
							PickupInventoryItem(zz-1) PutItemInBag(22);
							C_Timer.After(0.3, function()
								PickupInventoryItem(zz-1) PutItemInBag(23);
								return
							end)
						end)
					end)
				end)
			end)
		end
	end
   loadTheSet(currentSetNumber)
end 


-- Remove EMPTY slots
--[[
SLASH_REMPTYSLOTS11 = "/remptyslots1"
SlashCmdList["REMPTYSLOTS1"] = function(msg)
	--print(tostring(savedSet1[1]))
	slotsToRemove1 = {}
	for zz=0,19 do
		if tostring(savedSet1[zz]) == "EMPTY SLOT" then
			--print("Found one at " .. zz-1)
			--table.insert(slotsToRemove1, zz-1)
			C_Timer.After(0.3, function()
				PickupInventoryItem(zz-1) PutItemInBackpack();
				C_Timer.After(0.3, function()
					PickupInventoryItem(zz-1) PutItemInBag(20);
					C_Timer.After(0.3, function()
						PickupInventoryItem(zz-1) PutItemInBag(21);
						C_Timer.After(0.3, function()
							PickupInventoryItem(zz-1) PutItemInBag(22);
							C_Timer.After(0.3, function()
								PickupInventoryItem(zz-1) PutItemInBag(23);
								return
							end)
						end)
					end)
				end)
			end)
		end
	end
	print("Slots to remove: " .. dump(slotsToRemove))
end ]]--


-- UnequipAll
SLASH_UNEQUIPALL1 = "/unequipall"
SlashCmdList["UNEQUIPALL"] = function(msg)
	function removeToInv()
		for x=0,19 do
			PickupInventoryItem(x) PutItemInBackpack();
		end
	end
	function removeToBag1()
		for xx=0,19 do
			PickupInventoryItem(xx) PutItemInBag(20);
		end
	end
	function removeToBag2()
		for xxx=0,19 do
			PickupInventoryItem(xxx) PutItemInBag(21);
		end
	end
	function removeToBag3()
		for xxxx=0,19 do
			PickupInventoryItem(xxxx) PutItemInBag(22);
		end
	end
	function removeToBag4()
		for xxxxx=0,19 do
			PickupInventoryItem(xxxxx) PutItemInBag(23);
		end
	end
	C_Timer.After(0.3, function()
		removeToInv()
		C_Timer.After(0.3, function()
			removeToBag1()
			C_Timer.After(0.3, function()
				removeToBag2()
				C_Timer.After(0.3, function()
					removeToBag3()
					C_Timer.After(0.3, function()
						removeToBag4()
						return
					end)
				end)
			end)
		end)
	end)
end 


-- Dropdown menu
local favoriteNumber = "Sets"
local dropDown = CreateFrame("FRAME", "theDropDown", PaperDollFrame, "UIDropDownMenuTemplate")
dropDown:SetPoint("BOTTOMLEFT", 18, 80, 0, 0)
UIDropDownMenu_SetWidth(dropDown, 48)
--UIDropDownMenu_SetText(dropDown, "" .. favoriteNumber)
UIDropDownMenu_SetText(dropDown, "Sets")
UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	--loadSlotTitles = {"Load 1aa", "Load 2", "Load 3", "Load 4", "Load 5", "Load 6", "Load 7", "Load 8", "Load 9", "Load 10"}
	savedVars = {savedSet1, savedSet2, savedSet3, savedSet4, savedSet5, savedSet6, savedSet7, savedSet8, savedSet9, savedSet10}
	info.func = self.SetValue
	for xx=1,10 do
		info.menuList, info.hasArrow = loadSlotTitles[xx], false -- change to true to create nests
		info.text, info.arg1, info.checked = loadSlotTitles[xx], loadSlotTitles[xx], loadSlotTitles[xx] == favoriteNumber
		info.tooltipOnButton = true
		info.tooltipTitle = loadSlotTitles[xx]
		info.tooltipText = slotsDisplay[1]..tostring(savedVars[xx][1]).."]\n\n"..slotsDisplay[2]..tostring(savedVars[xx][2]).."]\n\n"..slotsDisplay[3]..tostring(savedVars[xx][3]).."]\n\n"..slotsDisplay[4]..tostring(savedVars[xx][4]).."]\n\n"..slotsDisplay[5]..tostring(savedVars[xx][5]).."]\n\n"..slotsDisplay[6]..tostring(savedVars[xx][6]).."]\n\n"..slotsDisplay[7]..tostring(savedVars[xx][7]).."]\n\n"..slotsDisplay[8]..tostring(savedVars[xx][8]).."]\n\n"..slotsDisplay[9]..tostring(savedVars[xx][9]).."]\n\n"..slotsDisplay[10]..tostring(savedVars[xx][10]).."]\n\n"..slotsDisplay[11]..tostring(savedVars[xx][11]).."]\n\n"..slotsDisplay[12]..tostring(savedVars[xx][12]).."]\n\n"..slotsDisplay[13]..tostring(savedVars[xx][13]).."]\n\n"..slotsDisplay[14]..tostring(savedVars[xx][14]).."]\n\n"..slotsDisplay[15]..tostring(savedVars[xx][15]).."]\n\n"..slotsDisplay[16]..tostring(savedVars[xx][16]).."]\n\n"..slotsDisplay[17]..tostring(savedVars[xx][17]).."]\n\n"..slotsDisplay[18]..tostring(savedVars[xx][18]).."]\n\n"..slotsDisplay[19]..tostring(savedVars[xx][19]).."]\n\n"..slotsDisplay[20]..tostring(savedVars[xx][20]).."]"
		UIDropDownMenu_AddButton(info)
	end
end)


local fSettings=CreateFrame("Frame", "TheSettingsFrame", UIParent, "BasicFrameTemplateWithInset") --Create a frame
fSettings:SetFrameStrata("TOOLTIP") --Set its strata
fSettings:SetHeight(500) --Give it height
fSettings:SetWidth(220) --and width -- old 200
fSettings:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
fSettings:Hide()
isTheSettingsFrameHidden = "1"
--fSettings:SetScript("OnHide", function(self, arg1)
	--isThePriorityFrameHidden = 1
--end)
fSettings.title = fSettings:CreateFontString(nil, "OVERLAY");
fSettings.title:SetFontObject("GameFontHighlight");
fSettings.title:SetPoint("CENTER", fSettings.TitleBg, "CENTER", 5, 0);
fSettings.title:SetText("EquipmentSets - Names");

-- Settings button
local widget = CreateFrame("Button", "TauntingButton", theDropDown, "UIPanelButtonTemplate");
widget:SetWidth(19);
widget:SetHeight(19);
widget:SetPoint("LEFT", 0, 2, 0, 0);
widget:SetNormalTexture("Interface\\Icons\\trade_engineering")
widget:SetScript("OnMouseDown", function(self, arg1)
    widget:SetSize(18.5, 18.5)
end)
widget:SetScript("OnMouseUp", function(self, arg1)
    widget:SetSize(19, 19)
end)
widget:SetScript("OnClick", function (self, button, down)
	--if isTheSettingsFrameHidden == "1" then
		fSettings:Show()
	--	isTheSettingsFrameHidden = "0"
	--elseif isTheSettingsFrameHidden == "0" then
	--	fSettings:Hide()
	--	isTheSettingsFrameHidden = "1"
	--end
end)

fSettings.introText = fSettings:CreateFontString(nil, "ARTWORK")
fSettings.introText:SetFont("Fonts\\FRIZQT__.TTF", 11)
fSettings.introText:SetText("\n\n\nSet 1\n\n\n\nSet 2\n\n\n\nSet 3\n\n\n\nSet 4\n\n\n\nSet 5\n\n\n\nSet 6\n\n\n\nSet 7\n\n\n\nSet 8\n\n\n\nSet 9\n\n\n\nSet 10")
fSettings.introText:SetTextColor(1, 1, 1)
fSettings.introText:SetAllPoints(true)
fSettings.introText:SetJustifyH("CENTER")
fSettings.introText:SetJustifyV("TOP")


C_Timer.After(1, function()
	local fSettingsTB1=EbT1 or CreateFrame("EditBox", "EbT1", TheSettingsFrame, "InputBoxTemplate")
	fSettingsTB1:SetSize(180,24)
	fSettingsTB1:SetPoint("TOP", 0, -47, 0, 0)
	fSettingsTB1:SetAutoFocus(false)
	fSettingsTB1:SetText(loadSlotTitles[1])

	local fSettingsTB2=EbT2 or CreateFrame("EditBox", "EbT2", TheSettingsFrame, "InputBoxTemplate")
	fSettingsTB2:SetSize(180,24)
	fSettingsTB2:SetPoint("TOP", 0, -91, 0, 0)
	fSettingsTB2:SetAutoFocus(false)
	fSettingsTB2:SetText(loadSlotTitles[2])

	local fSettingsTB3=EbT3 or CreateFrame("EditBox", "EbT3", TheSettingsFrame, "InputBoxTemplate")
	fSettingsTB3:SetSize(180,24)
	fSettingsTB3:SetPoint("TOP", 0, -135, 0, 0)
	fSettingsTB3:SetAutoFocus(false)
	fSettingsTB3:SetText(loadSlotTitles[3])

	local fSettingsTB4=EbT4 or CreateFrame("EditBox", "EbT4", TheSettingsFrame, "InputBoxTemplate")
	fSettingsTB4:SetSize(180,24)
	fSettingsTB4:SetPoint("TOP", 0, -179, 0, 0)
	fSettingsTB4:SetAutoFocus(false)
	fSettingsTB4:SetText(loadSlotTitles[4])

	local fSettingsTB5=EbT5 or CreateFrame("EditBox", "EbT5", TheSettingsFrame, "InputBoxTemplate")
	fSettingsTB5:SetSize(180,24)
	fSettingsTB5:SetPoint("TOP", 0, -223, 0, 0)
	fSettingsTB5:SetAutoFocus(false)
	fSettingsTB5:SetText(loadSlotTitles[5])

	local fSettingsTB6=EbT6 or CreateFrame("EditBox", "EbT6", TheSettingsFrame, "InputBoxTemplate")
	fSettingsTB6:SetSize(180,24)
	fSettingsTB6:SetPoint("TOP", 0, -267, 0, 0)
	fSettingsTB6:SetAutoFocus(false)
	fSettingsTB6:SetText(loadSlotTitles[6])

	local fSettingsTB7=EbT7 or CreateFrame("EditBox", "EbT7", TheSettingsFrame, "InputBoxTemplate")
	fSettingsTB7:SetSize(180,24)
	fSettingsTB7:SetPoint("TOP", 0, -311, 0, 0)
	fSettingsTB7:SetAutoFocus(false)
	fSettingsTB7:SetText(loadSlotTitles[7])

	local fSettingsTB8=EbT8 or CreateFrame("EditBox", "EbT8", TheSettingsFrame, "InputBoxTemplate")
	fSettingsTB8:SetSize(180,24)
	fSettingsTB8:SetPoint("TOP", 0, -355, 0, 0)
	fSettingsTB8:SetAutoFocus(false)
	fSettingsTB8:SetText(loadSlotTitles[8])

	local fSettingsTB9=EbT9 or CreateFrame("EditBox", "EbT9", TheSettingsFrame, "InputBoxTemplate")
	fSettingsTB9:SetSize(180,24)
	fSettingsTB9:SetPoint("TOP", 0, -399, 0, 0)
	fSettingsTB9:SetAutoFocus(false)
	fSettingsTB9:SetText(loadSlotTitles[9])

	local fSettingsTB10=EbT10 or CreateFrame("EditBox", "EbT10", TheSettingsFrame, "InputBoxTemplate")
	fSettingsTB10:SetSize(180,24)
	fSettingsTB10:SetPoint("TOP", 0, -443, 0, 0)
	fSettingsTB10:SetAutoFocus(false)
	fSettingsTB10:SetText(loadSlotTitles[10])



	local widgetConfirm = CreateFrame("Button", "TauntingButton", TheSettingsFrame, "UIPanelButtonTemplate");
	widgetConfirm:SetWidth(150);
	widgetConfirm:SetHeight(19);
	widgetConfirm:SetPoint("BOTTOM", 0, 9, 0, 0);
	widgetConfirm:SetText("Confirm");
	--widgetConfirm:SetNormalTexture("Interface\\Icons\\trade_engineering")
	widgetConfirm:SetScript("OnMouseDown", function(self, arg1)
	    --widgetConfirm:SetSize(18.5, 18.5)
	end)
	widgetConfirm:SetScript("OnMouseUp", function(self, arg1)
	    --widgetConfirm:SetSize(19, 19)
	end)
	widgetConfirm:SetScript("OnClick", function (self, button, down)
		savedName1 = fSettingsTB1:GetText()
		savedName2 = fSettingsTB2:GetText()
		savedName3 = fSettingsTB3:GetText()
		savedName4 = fSettingsTB4:GetText()
		savedName5 = fSettingsTB5:GetText()
		savedName6 = fSettingsTB6:GetText()
		savedName7 = fSettingsTB7:GetText()
		savedName8 = fSettingsTB8:GetText()
		savedName9 = fSettingsTB9:GetText()
		savedName10 = fSettingsTB10:GetText()
		loadSlotTitles = {tostring(savedName1), tostring(savedName2), tostring(savedName3), tostring(savedName4), tostring(savedName5), tostring(savedName6), tostring(savedName7), tostring(savedName8), tostring(savedName9), tostring(savedName10)}
		fSettings:Hide()
	end)
end)

function dropDown:SetValue(newValue)
	favoriteNumber = newValue
	--UIDropDownMenu_SetText(dropDown, favoriteNumber)
	for nn=1,10 do
		--if favoriteNumber == "Load " .. tostring(nn) then
		if favoriteNumber == loadSlotTitles[nn] then
			--print("You have selected Set " .. nn)
			DEFAULT_CHAT_FRAME.editBox:SetText("/loadset" .. nn) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
			loadTheSet()
		end
	end
	CloseDropDownMenus()
end


local dropDown2 = CreateFrame("FRAME", "theDropDown", PaperDollFrame, "UIDropDownMenuTemplate")
dropDown2:SetPoint("BOTTOMLEFT", 76, 80, 80, 80)
UIDropDownMenu_SetWidth(dropDown2, 8)
--UIDropDownMenu_SetText(dropDown2, "Load")
UIDropDownMenu_Initialize(dropDown2, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	saveSlotTitles = {"Save 1", "Save 2", "Save 3", "Save 4", "Save 5", "Save 6", "Save 7", "Save 8", "Save 9", "Save 10"}
	info.func = self.SetValue
	for xx=1,10 do
		info.menuList, info.hasArrow = saveSlotTitles[xx], false -- change to true to create nests
		info.text, info.arg1, info.checked = saveSlotTitles[xx], saveSlotTitles[xx], saveSlotTitles[xx] == favoriteNumber
		info.tooltipOnButton = true
		info.tooltipTitle = saveSlotTitles[xx]
		info.tooltipText = slotsDisplay[1]..tostring(savedVars[xx][1]).."]\n\n"..slotsDisplay[2]..tostring(savedVars[xx][2]).."]\n\n"..slotsDisplay[3]..tostring(savedVars[xx][3]).."]\n\n"..slotsDisplay[4]..tostring(savedVars[xx][4]).."]\n\n"..slotsDisplay[5]..tostring(savedVars[xx][5]).."]\n\n"..slotsDisplay[6]..tostring(savedVars[xx][6]).."]\n\n"..slotsDisplay[7]..tostring(savedVars[xx][7]).."]\n\n"..slotsDisplay[8]..tostring(savedVars[xx][8]).."]\n\n"..slotsDisplay[9]..tostring(savedVars[xx][9]).."]\n\n"..slotsDisplay[10]..tostring(savedVars[xx][10]).."]\n\n"..slotsDisplay[11]..tostring(savedVars[xx][11]).."]\n\n"..slotsDisplay[12]..tostring(savedVars[xx][12]).."]\n\n"..slotsDisplay[13]..tostring(savedVars[xx][13]).."]\n\n"..slotsDisplay[14]..tostring(savedVars[xx][14]).."]\n\n"..slotsDisplay[15]..tostring(savedVars[xx][15]).."]\n\n"..slotsDisplay[16]..tostring(savedVars[xx][16]).."]\n\n"..slotsDisplay[17]..tostring(savedVars[xx][17]).."]\n\n"..slotsDisplay[18]..tostring(savedVars[xx][18]).."]\n\n"..slotsDisplay[19]..tostring(savedVars[xx][19]).."]\n\n"..slotsDisplay[20]..tostring(savedVars[xx][20]).."]"
		UIDropDownMenu_AddButton(info)
	end
end)
function dropDown2:SetValue(newValue)
	favoriteNumber = newValue
	--UIDropDownMenu_SetText(dropDown, favoriteNumber)
	for nn=1,10 do
		if favoriteNumber == "Save " .. tostring(nn) then
			--print("You have selected Set " .. nn)

			StaticPopupDialogs["DOYOUWANTTO_LOAD"] = {
				text = "[Save "..nn.."] will be overwritten. \nContinue?",
				button1 = "Yes",
				button2 = "No",
				OnAccept = function()
					DEFAULT_CHAT_FRAME.editBox:SetText("/saveset" .. nn) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}

			StaticPopup_Show ("DOYOUWANTTO_LOAD")
			
		end
	end
	CloseDropDownMenus()
end