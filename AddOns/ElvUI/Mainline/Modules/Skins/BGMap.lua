local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function GetOpacity()
	return 1 - (_G.BattlefieldMapOptions and _G.BattlefieldMapOptions.opacity or 1)
end

local function setBackdropAlpha()
	if _G.BattlefieldMapFrame.backdrop then
		_G.BattlefieldMapFrame.backdrop:SetBackdropColor(0, 0, 0, GetOpacity())
	end
end

-- alpha stuff
local oldAlpha = 0
local function setOldAlpha()
	_G.BattlefieldMapFrame.BorderFrame.CloseButton:SetAlpha(0.1)

	if oldAlpha then
		_G.BattlefieldMapFrame:SetGlobalAlpha(oldAlpha)
		oldAlpha = nil
	end
end

local function setRealAlpha()
	_G.BattlefieldMapFrame.BorderFrame.CloseButton:SetAlpha(1)

	oldAlpha = GetOpacity()
	_G.BattlefieldMapFrame:SetGlobalAlpha(1)
end

local function refreshAlpha()
	oldAlpha = GetOpacity()
end

function S:Blizzard_BattlefieldMap()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bgmap) then return end

	refreshAlpha() -- will need this soon

	local frame = _G.BattlefieldMapFrame
	frame:StripTextures()
	frame:CreateBackdrop()
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:SetFrameStrata('LOW')
	frame:SetScript('OnUpdate', _G.MapCanvasMixin.OnUpdate) -- shut off the tab fading in, but keep the canvas updater

	local border = frame.BorderFrame
	border:StripTextures()

	local close = border.CloseButton
	close:SetAlpha(0.1)
	close:SetIgnoreParentAlpha(1)
	close:SetFrameLevel(close:GetFrameLevel()+1)
	close:ClearAllPoints()
	close:Point('TOPRIGHT', 3, 8)
	S:HandleCloseButton(close)

	local tab = _G.BattlefieldMapTab
	local scroll = frame.ScrollContainer
	frame.backdrop:SetOutside(scroll)
	frame.backdrop:SetBackdropColor(0, 0, 0, oldAlpha)

	scroll:HookScript('OnMouseUp', function(_, btn)
		if btn == 'LeftButton' then
			tab:StopMovingOrSizing()
		elseif btn == 'RightButton' then
			tab:Click('RightButton')
		end

		local slider = _G.OpacityFrame
		if slider and slider:IsShown() then
			slider:Hide()
		end
	end)

	scroll:HookScript('OnMouseDown', function(_, btn)
		if btn == 'LeftButton' and (_G.BattlefieldMapOptions and not _G.BattlefieldMapOptions.locked) then
			tab:StartMoving()
		end
	end)

	hooksecurefunc(frame, 'SetGlobalAlpha', setBackdropAlpha)
	hooksecurefunc(frame, 'RefreshAlpha', refreshAlpha)

	scroll:HookScript('OnLeave', setOldAlpha)
	scroll:HookScript('OnEnter', setRealAlpha)
	frame:HookScript('OnShow', setBackdropAlpha)
	close:HookScript('OnLeave', setOldAlpha)
	close:HookScript('OnEnter', setRealAlpha)
end

S:AddCallbackForAddon('Blizzard_BattlefieldMap')
