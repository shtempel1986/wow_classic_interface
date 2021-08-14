
local objectCorrections = {
	["item"] = {
		[86592] = {
			[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.EXPANSION] = ArkInventory.Const.BLIZZARD.GLOBAL.EXPANSION.PANDARIA,
		},
		[108257] = {
			[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.EXPANSION] = ArkInventory.Const.BLIZZARD.GLOBAL.EXPANSION.DRAENOR,
		},
		[120945] = {
			[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.EXPANSION] = ArkInventory.Const.BLIZZARD.GLOBAL.EXPANSION.DRAENOR,
		},
		[124461] = {
			[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.EXPANSION] = ArkInventory.Const.BLIZZARD.GLOBAL.EXPANSION.LEGION,
		},
		[186727] = {
			[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.EXPANSION] = ArkInventory.Const.BLIZZARD.GLOBAL.EXPANSION.SHADOWLANDS,
		},
	},
}


local cacheObjectStringStandard = { }

local cacheObjectStringDecode = { }

function ArkInventory.ObjectStringDecode( h, i )
	
	local chs = h and cacheObjectStringStandard[h]
	if chs and cacheObjectStringDecode[chs] then
		return cacheObjectStringDecode[chs]
	end
	
	local h1 = string.trim( h or "" )
	local bt
	if h1 == "" and i then
		if i.h then
			h1 = i.h
		else
			local blizzard_id = ArkInventory.InternalIdToBlizzardBagId( i.loc_id, i.bag_id )
			bt = ArkInventory.BagType( blizzard_id )
			h1 = string.format( "empty:0:%s", bt )
		end
	end
	
	chs = cacheObjectStringStandard[h1]
	if chs and cacheObjectStringDecode[chs] then
		return cacheObjectStringDecode[chs]
	end
	
	
	local h2
	if type( h ) == "number" then
		-- convert a number into an item link
		h2 = string.format( "item:%s", h )
	else
		-- pull out the item string
		h2 = string.match( h1, "|H(.-)|h" ) or string.match( h1, "^([a-z]-:.+)" ) or "empty:0:0"
	end
	
	chs = cacheObjectStringStandard[h2]
	if chs and cacheObjectStringDecode[chs] then
		return cacheObjectStringDecode[chs]
	end
	
	
	-- data is not cached
	-- build it and cache it
	
	local osd = { strsplit( ":", h2 ) }
	
	local c = #osd
	
	local cmin = 20 + ( ArkInventory.ToNumber( osd[14] ) or 0 )
	if c < cmin then
		c = cmin
	end
	
	for x = 2, c do
		if not osd[x] or osd[x] == "" then
			osd[x] = 0
		else
			osd[x] = ArkInventory.ToNumber( osd[x] ) or osd[x]
		end
	end
	
	osd.class = osd[1]
	osd.id = osd[2]
	osd.h = h2
	osd.h_base = string.format( "%s:%s", osd.class, osd.id )
	--osd.name = string.match( h1, "|h%[(.-)]|h" )
	osd.slottype = bt
	
	if osd.class == "item" then
		
		--[[
			[01]class
			[02]itemid
			[03]enchantid
			[04]gem1
			[05]gem2
			[06]gem3
			[07]gem4
			[08]suffixid
			[09]uniqueid
			[10]linklevel
				reset to 0 for consistency
			[11]specid
				reset to 0 for consistency
				for values see https://wowpedia.fandom.com/wiki/SpecializationID
			[12]upgradetypeid
				4 = pandaria x/4
				512 = timewarped
			[13]souce / instance difficulty id
				reset to 0 for consistency
				for values see https://wowpedia.fandom.com/wiki/DifficultyID
			[14]numbonusids
			[..]bonusids
			[15]upgradevalue
			[16]??
			[17]??
			[18]??
			[19]??
			[20]??
			++++
			[21]numrelics1
			[..]ids
			[22]numrelics2
			[..]ids
			[23]numrelics3
			[..]ids
			++++
			[21]player guid
			[22]??
			
			
			
			
		]]--
		
		osd.enchantid = osd[3]
		
		osd.gemid = { osd[4], osd[5], osd[6], osd[7] }
		
		osd.suffixid = osd[8] -- only applies to old items, new items use a bonusid for the suffix
		osd.uniqueid = osd[9]
		
		osd.suffixfactor = 0
		if osd.suffixid < 0 then
			osd.suffixfactor = bit.band( osd.uniqueid, 65535 )
		end
		
		--osd.linklevel = osd[10]
		osd[10] = 0 -- zero out for a more consistent exrid (its the characters current level)
		
		--osd.specid = osd[11]
		osd[11] = 0 -- zero out for a more consistent exrid (its the characters current spec)
		
		osd.upgradeid = osd[12]
		
		osd.sourceid = osd[13]
		osd[13] = 0 -- zero out for a more consistent exrid (its the same item so it doesnt matter where it came from)
		
		local pos = 14
		
		-- [14] bonus ids
		if osd[pos] and osd[pos] > 0 then
			osd.bonusids = { }
			for x = pos + 1, pos + osd[pos] do
				osd.bonusids[osd[x]] = true
			end
			pos = pos + osd[pos]
		end
		pos = pos + 1
		
		-- [15] upgrade level
		osd.upgradelevel = osd[pos]
		pos = pos + 1
		
		-- [16] unknown
		osd.unknown1 = osd[pos]
		pos = pos + 1
		
		-- [17] unknown
		osd.unknown2 = osd[pos]
		pos = pos + 1
		
		-- [18] unknown
		osd.unknown3 = osd[pos]
		pos = pos + 1
		
		-- [19] unknown
		osd.unknown4 = osd[pos]
		pos = pos + 1
		
		-- [20] unknown
		osd.unknown5 = osd[pos]
		pos = pos + 1
		
		-- everything up to here should exist in the itemstring
		-- after this, seems to be specific to the item type
		
		if pos <= c then
			-- record start position of custom values
			osd.custom = pos
		end
		
		-- build an extended rule id for equipable items (it gets added onto the basic id)
		osd.exrid = osd[3]
		for k = 4, pos - 1 do
			osd.exrid = string.format( "%s:%s", osd.exrid, osd[k] or 0 )
		end
		
		-- build a sanitised itemstring (no character level or spec)
		osd.h_rule = string.format( "%s:%s", osd.h_base, osd.exrid )
		
	elseif osd.class == "keystone" then
		
		-- keystone:138019:239:2:0:0:0:0
		--[[
			[01]class
			[02]itemid
			[03]instance
			[04]level
			[05]status (2=active, ?=depleted)
			[06]affix1
			[07]affix2
			[08]affix3
			[09]affix4
		]]--
		
		osd.instance = osd[3]
		osd.level = osd[4]
		osd.status = osd[5]
		
		-- affix ids
		for x = 6, 9 do
			if osd[x] ~= 0 then
				if not osd.bonusids then
					osd.bonusids = { }
				end
				osd.bonusids[osd[x]] = true
			end
		end
		
	elseif osd.class == "reputation" then
		
		-- custom reputation hyperlink
		
		--[[
			[01]class
			[02]factionId
			[03]standingText
			[04]barValue
			[05]barMax
			[06]isCapped
			[07]paragonLevel
			[08]paragonReward
		]]--
		
		osd.st = osd[3]
		osd.bv = osd[4]
		osd.bm = osd[5]
		osd.ic = osd[6]
		osd.pv = osd[7]
		osd.pr = osd[8]
		
	elseif osd.class == "spell" then
		
		--[[
			[01]class
			[02]spellId
			[03]glyphId
			[04]???
		]]--
		
		osd.glyphid = osd[3]
		
	elseif osd.class == "battlepet" then
		
		--[[
			[01]class
			[02]species
			[03]level
			[04]quality
			[05]maxhealth
			[06]power
			[07]speed
			[08]name (can also be guid, api is inconsistent)
			[09]guid (BattlePet-[unknowndata]-[creatureID])
		]]--
		
		osd.level = osd[3]
		osd.q = osd[4]
		osd.health = osd[5] 
		osd.power = osd[6]
		osd.speed = osd[7]
		
		if type( osd[8] ) == "string" then
			if string.match( osd[8], "BattlePet(.+)" ) then
				--ArkInventory.Output( "moving ", osd[8], " guid is in name slot" )
				osd[9] = osd[8]
				osd[8] = ""
			end
		else
			osd[8] = ""
		end
		
		if type( osd[9] ) == "string" then
			if not string.match( osd[9], "BattlePet(.+)" ) then
				--ArkInventory.Output( "fail ", osd[9], " is not the correct format" )
				--ArkInventory.Output( s )
				osd[9] = ""
			end
		else
			osd[9] = ""
		end
		
		osd.cn = osd[8]
		osd.guid = osd[9]
		
	elseif osd.class == "copper" then
		
		--[[
			[01]class
			[02]not used (always 0)
			[03]amount
		--]]
		
		osd.amount = osd[3]
		
	elseif osd.class == "empty" then
		
		--[[
			[01]class
			[02]not used (always 0)
			[03]bag type
		--]]
		
		osd.bagtype = osd[3]
		
	end
	
	osd.h1 = h1
	osd.h2 = h2
	
	local hs = table.concat( osd, ":" )
	osd.hs = hs
	cacheObjectStringDecode[hs] = osd
	
	if h and h ~= "" then
		cacheObjectStringStandard[h] = hs
	end
	cacheObjectStringStandard[h1] = hs
	cacheObjectStringStandard[h2] = hs
	cacheObjectStringStandard[hs] = hs
	
	return cacheObjectStringDecode[hs]
	
end


local function helper_CorrectData( info, tmp )
	-- correct any data
	if type( info ) == "table" and type( tmp ) == "table" then
		if info.class and objectCorrections[info.class] then
			if info.id and objectCorrections[info.class][info.id] then
				for k, v in pairs( objectCorrections[info.class][info.id] ) do
					tmp[k] = v
				end
			end
		end
	end
end

local cacheGetObjectInfo = { }

function ArkInventory.GetObjectInfo( h, i )
	
	local chs = h and cacheObjectStringStandard[h]
	local info = chs and cacheGetObjectInfo[chs]
	if info and info.ready then
		return info
	end
	
	if not info then
		
		local osd = ArkInventory.ObjectStringDecode( h, i )
		
		if not osd.class or not osd.id then
			ArkInventory.OutputError( "code failure: invalid class [", osd.class, ":", osd.id, "]" )
			error( "code failure" )
		end
		
		chs = osd.hs and cacheObjectStringStandard[osd.hs]
		info = chs and cacheGetObjectInfo[chs]
		if info and info.ready then
			return info
		end
		
	end
	
	
	info = info or { }
	info.osd = info.osd or ArkInventory.ObjectStringDecode( h, i )
	
	info.class = info.osd.class
	info.id = info.osd.id
	info.hs = info.osd.hs
	info.h = info.osd.h
	
	info.name = ArkInventory.Localise["DATA_NOT_READY"]
	info.q = ArkInventory.Const.BLIZZARD.GLOBAL.ITEMQUALITY.UNKNOWN
	info.ilvl_base = -2
	info.ilvl = -2
	info.uselevel = -2
	info.itemtype = ArkInventory.Localise["UNKNOWN"]
	info.itemsubtype = ArkInventory.Localise["UNKNOWN"]
	info.stacksize = 1
	info.equiploc = ""
	info.texture = ArkInventory.Const.Texture.Missing
	info.vendorprice = -1
	info.itemtypeid = -2
	info.itemsubtypeid = -2
	info.binding = 0
	info.expansion = ArkInventory.Const.BLIZZARD.GLOBAL.EXPANSION.CLASSIC
	
	
	local tmp
	
	if info.class == "item" or info.class == "keystone" then
		
		
--[[
		[01] = name
		[02] = h
		[03] = q
		[04] = ilvl_base
		[05] = uselevel
		[06] = type
		[07] = subtype
		[08] = stacksize
		[09] = equip
		[10] = texture
		[11] = vendor
		[12] = typeid
		[13] = subtypeid
		[14] = binding
			[00] = none
			[01] = on pickup
			[02] = on equip
			[03] = on use
			[04] = quest
		[15] = expansion
		[16] = setid
		[17] = craft
]]--
		
		info.ready = true
		
		tmp = { GetItemInfo( info.hs ) }
		
		if not tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.NAME] then
			-- name will be null if the item data isnt availabvle from the server yet
			-- so temporarily fill it with data that is available from the client
			info.ready = false
			local instant = { GetItemInfoInstant( info.hs ) }
			tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.NAME] = instant[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFOINSTANT.NAME]
			tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.TYPE] = instant[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFOINSTANT.TYPE]
			tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.SUBTYPE] = instant[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFOINSTANT.SUBTYPE]
			tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.EQUIP] = instant[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFOINSTANT.EQUIP]
			tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.TEXTURE] = instant[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFOINSTANT.TEXTURE]
			tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.TYPEID] = instant[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFOINSTANT.TYPEID]
			tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.SUBTYPEID] = instant[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFOINSTANT.SUBTYPEID]
		end
		
		helper_CorrectData( info, tmp )
		
		info.h = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.LINK] or info.h
		info.q = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.QUALITY] or info.q
		info.ilvl_base = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.ILVL_BASE] or info.ilvl_base
		info.uselevel = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.USELEVEL] or info.uselevel
		info.itemtype = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.TYPE] or info.itemtype
		info.itemsubtype = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.SUBTYPE] or info.itemsubtype
		info.stacksize = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.STACKSIZE] or info.stacksize
		info.equiploc = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.EQUIP] or info.equiploc
		info.texture = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.TEXTURE] or GetItemIcon( info.hs ) or info.texture
		info.vendorprice = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.VENDORPRICE] or info.vendorprice
		info.itemtypeid = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.TYPEID] or info.itemtypeid
		info.itemsubtypeid = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.SUBTYPEID] or info.itemsubtypeid
		info.binding = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.BINDING] or info.binding
		info.expansion = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.EXPANSION] or info.expansion
		
		info.setid = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.SETID]
		info.craft = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.CRAFT]
		
		info.name = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.NAME] or info.name
		if info.name == ArkInventory.Localise["DATA_NOT_READY"] then
			info.ready = false
		end
		
		
		if info.ready then
			
			info.ilvl = GetDetailedItemLevelInfo( info.hs ) or info.ilvl_base
			info.spell_name, info.spell_id = GetItemSpell( info.id )
			
			ArkInventory.TooltipSetHyperlink( ArkInventory.Global.Tooltip.Scan, info.hs )
			if not ArkInventory.TooltipIsReady( ArkInventory.Global.Tooltip.Scan ) then
				
				info.ready = false
				--ArkInventory.Output( "tooltip not ready: ", info.h )
				
			else
				
				local _, txt, ilvl, stock
				
				if info.equiploc == "INVTYPE_BAG" then
					_, _, stock = ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, "(%d+)", false, true, true, 0, true )
					if not stock then
						info.ready = false
					end
				elseif info.itemsubtypeid == ArkInventory.Const.ItemClass.GEM_ARTIFACTRELIC then
					_, _, ilvl = ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_RELIC_LEVEL"], false, true, true, 0, true )
				elseif ArkInventory.PT_ItemInSets( info.id, "ArkInventory.Internal.ItemsWithStockValues" ) then
					_, _, stock = ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ".- ([%d.,]+) .+", false, true, true, 0, true )
					if not stock then
						info.ready = false
					end
				else
					_, _, ilvl = ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_ITEM_LEVEL"], false, true, true, 4, true )
				end
				
				info.ilvl = ArkInventory.ToNumber( ilvl or stock ) or info.ilvl
				info.stock = ArkInventory.ToNumber( stock )
				
			end
			
		end
		
		
		if not info.ready then
			--ArkInventory.Output( "not ready: ", info.h )
		end
		
	elseif info.class == "spell" then
		
		
--[[
		[01] = name
		[02] = rank
		[03] = texture
]]--
		
		info.ready = true
		
		tmp = { GetSpellInfo( info.id ) }
		
		helper_CorrectData( info, tmp )
		
		info.h = GetSpellLink( info.id ) or info.hs
		info.name = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETITEMINFO.NAME] or info.name
		if info.name == ArkInventory.Localise["DATA_NOT_READY"] then
			info.ready = false
		end
		info.texture = tmp[ArkInventory.Const.BLIZZARD.FUNCTION.GETSPELLINFO.TEXTURE] or ArkInventory.Const.Texture.Missing
		info.q = ArkInventory.Const.BLIZZARD.GLOBAL.ITEMQUALITY.COMMON
		
		
	elseif info.class == "battlepet" then
		
		info.ready = true
		
		info.sd = ArkInventory.Collection.Pet.GetSpeciesInfo( info.id )
		if info.sd then
			info.name = info.sd.name or info.name
			if info.name == ArkInventory.Localise["DATA_NOT_READY"] then
				info.ready = false
			end
			info.texture = info.sd.icon or info.texture
			info.itemsubtypeid = info.sd.petType or info.itemsubtypeid
		else
			info.ready = false
		end
		
		info.ilvl = info.osd.level or 1
		info.itemtypeid = ArkInventory.Const.ItemClass.BATTLEPET
		
	elseif info.class == "currency" then
		
		info.ready = true
		
		tmp = ArkInventory.Collection.Currency.GetByID( info.id )
		
		if tmp then
			info.h = tmp.link or info.h
			info.name = tmp.name or info.name
			info.amount = tmp.quantity
			info.q = tmp.quality or info.q
			info.texture = tmp.iconFileID
			info.h = tmp.link
			info.ready = ArkInventory.Collection.Currency.IsReady( )
		end
		
		if info.name == ArkInventory.Localise["DATA_NOT_READY"] then
			info.ready = false
		end
		
	elseif info.class == "reputation" then
		
		info.ready = true
		
		tmp = ArkInventory.Collection.Reputation.GetByID( info.id )
		if tmp then
			info.h = tmp.link or info.h
			info.name = tmp.name or info.name
			info.texture = tmp.icon or info.texture
			info.ready = ArkInventory.Collection.Reputation.IsReady( )
		end
		
		if info.name == ArkInventory.Localise["DATA_NOT_READY"] then
			info.ready = false
		end
		
	elseif info.class == "empty" then
		
		info.ready = true
		
		info.texture = ""
		info.itemtypeid = ArkInventory.Const.ItemClass.EMPTY
		info.itemsubtypeid = info.osd.slottype
		
	end
	
	
--	if info.id == 178926 then
--		bonusids turn this into a legendary, but for searching its still on the base item which has a totally different name
--		need to find a way to add all bonus ids into the search as an option
--		ArkInventory.Output( h, " = ", info.name, " / ", info.ready )
--		ArkInventory.Output( info )
--	end
	
	
	if h and h ~= "" then
		cacheObjectStringStandard[h] = info.osd.hs
	end
	cacheGetObjectInfo[info.osd.hs] = info
	cacheGetObjectInfo[info.osd.h1] = info
	cacheGetObjectInfo[info.osd.h2] = info
	
	return info
	
end

function ArkInventory.ObjectInfoItemString( h )
	local osd = ArkInventory.ObjectStringDecode( h )
	return osd.h
end

function ArkInventory.ObjectInfoName( h )
	local info = ArkInventory.GetObjectInfo( h )
	return info.name or "!"
end

function ArkInventory.ObjectInfoTexture( h )
	local info = ArkInventory.GetObjectInfo( h )
	return info.texture
end

function ArkInventory.ObjectInfoQuality( h )
	local info = ArkInventory.GetObjectInfo( h )
	return info.q or ArkInventory.Const.BLIZZARD.GLOBAL.ITEMQUALITY.UNKNOWN
end

function ArkInventory.ObjectInfoVendorPrice( h )
	local info = ArkInventory.GetObjectInfo( h )
	return info.vendorprice or -1
end

function ArkInventory.ObjectIDClean( h )
	local h = h
	h = string.gsub( h, ":0", ":" )
	h = string.match( h, "(.-):*$" )
	return h
end


local cacheObjectIDBonus = { }

function ArkInventory.ObjectIDBonusClear( t )
	ArkInventory.PT_BonusIDIsWantedClear( t )
	ArkInventory.Table.Wipe( cacheObjectIDBonus[t] )
end

function ArkInventory.ObjectIDBonus( t, h, i )
	
	local hr = string.trim( h or "" )
	
	if not cacheObjectIDBonus[t] then
		cacheObjectIDBonus[t] = { }
	end
	
	if cacheObjectIDBonus[t][hr] then
		return cacheObjectIDBonus[t][hr]
	end
	
	local osd = ArkInventory.ObjectStringDecode( hr, i )
	
	local v = osd.h_base
	
	if osd.class == "item" then
		
		v = string.format( "%s:0:0:0:0:0", v )
		
		if ( t == ArkInventory.Const.IDType.Count and ArkInventory.db.option.bonusid.count.suffix ) or ( t == ArkInventory.Const.IDType.Search and ArkInventory.db.option.bonusid.search.suffix ) then
			if osd.suffixid == 0 then
				v = string.format( "%s:0:0", v )
			else
				v = string.format( "%s:%s:%s", v, osd.suffixid, osd.uniqueid )
			end
		else
			v = string.format( "%s:0:0", v )
		end
		
		v = string.format( "%s:0:0:0:0", v )
		
		if osd.bonusids then
			
			local c = 0
			local r = ""
			local id
			
			for bid in pairs( osd.bonusids ) do
				id = ArkInventory.PT_BonusIDIsWanted( t, bid )
				if id then
					c = c + 1
					r = string.format( "%s:%s", r, id )
				end
			end
			
			v = string.format( "%s:%s%s", v, c, r )
			
		else
			v = string.format( "%s:0", v )
		end
		
		v = string.format( "%s:0", v )
		
		v = ArkInventory.ObjectIDClean( v )
		
	end
	
	if hr ~= "" then
		cacheObjectIDBonus[t][hr] = v
	end
	
	return v
	
end


local cacheObjectIDCount = { }

function ArkInventory.ObjectIDCountClear( )
	ArkInventory.ObjectIDBonusClear( ArkInventory.Const.IDType.Count )
	ArkInventory.Table.Wipe( cacheObjectIDCount )
end

function ArkInventory.ObjectIDCount( h, i )
	
	local hr = string.trim( h or "" )
	
	if cacheObjectIDCount[hr] then
		return cacheObjectIDCount[hr]
	end
	
	local v = ArkInventory.ObjectIDBonus( ArkInventory.Const.IDType.Count, h, i )
	
	if hr ~= "" then
		cacheObjectIDCount[hr] = v
	end
	
	return v
	
end


local cacheObjectIDSearch = { }

function ArkInventory.ObjectIDSearchClear( )
	ArkInventory.ObjectIDBonusClear( ArkInventory.Const.IDType.Search )
	ArkInventory.Table.Wipe( cacheObjectIDSearch )
end

function ArkInventory.ObjectIDSearch( h, i )
	
	local hr = string.trim( h or "" )
	
	if cacheObjectIDSearch[hr] then
		return cacheObjectIDSearch[hr]
	end
	
	local v = ArkInventory.ObjectIDBonus( ArkInventory.Const.IDType.Search, h, i )
	
	if hr ~= "" then
		cacheObjectIDSearch[hr] = v
	end
	
	return v
	
end
