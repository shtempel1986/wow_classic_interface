local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:SkinWorldStateScore()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bgscore) then return end

	local WorldStateScoreFrame = _G.WorldStateScoreFrame
	S:HandleFrame(WorldStateScoreFrame, true, nil, 0, -5, -107, 25)

	_G.WorldStateScoreScrollFrame:StripTextures()
	S:HandleScrollBar(_G.WorldStateScoreScrollFrameScrollBar)

	for i = 1, 3 do
		S:HandleTab(_G['WorldStateScoreFrameTab'..i])
		_G['WorldStateScoreFrameTab'..i..'Text']:SetPoint('CENTER', 0, 2)
	end

	-- Reposition Tabs
	_G.WorldStateScoreFrameTab1:ClearAllPoints()
	_G.WorldStateScoreFrameTab1:Point('TOPLEFT', _G.WorldStateScoreFrame, 'BOTTOMLEFT', -10, 25)
	_G.WorldStateScoreFrameTab2:Point('TOPLEFT', _G.WorldStateScoreFrameTab1, 'TOPRIGHT', -19, 0)
	_G.WorldStateScoreFrameTab3:Point('TOPLEFT', _G.WorldStateScoreFrameTab2, 'TOPRIGHT', -19, 0)

	S:HandleButton(_G.WorldStateScoreFrameLeaveButton)
	S:HandleCloseButton(_G.WorldStateScoreFrameCloseButton)

	_G.WorldStateScoreFrameKB:StyleButton()
	_G.WorldStateScoreFrameDeaths:StyleButton()
	_G.WorldStateScoreFrameHK:StyleButton()
	_G.WorldStateScoreFrameHonorGained:StyleButton()
	_G.WorldStateScoreFrameName:StyleButton()

	for i = 1, 7 do
		_G['WorldStateScoreColumn'..i]:StyleButton()
	end
end

S:AddCallback('SkinWorldStateScore')
