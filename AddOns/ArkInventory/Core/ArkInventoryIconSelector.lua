
ArkInventoryIconSelectorPopupFrameMixin = { }

local IconPopupFrameName = "ARKINV_IconSelectorPopupFrame"

local function nameCheck( name )
	
	name = string.gsub( name or "", "\"", "" )
	name = string.trim( name )
	if ( not name or name == "" ) then
		name = string.format( GUILDBANK_TAB_NUMBER, self.selectedTabData.ID )
	end
	
	return name
	
end

function ArkInventory.Icon_Selector_Show( loc_id_window, bag_id_window )
	
	local map = ArkInventory.Util.MapGetWindow( loc_id_window, bag_id_window )
	
	local self = _G[IconPopupFrameName]
	
	self:Hide( )
	
	self.ARK_Data = {
		blizzard_id = map.blizzard_id,
		loc_id_window = map.loc_id_window,
		bag_id_window = map.bag_id_window,
		loc_id_storage = map.loc_id_storage,
		bag_id_storage = map.bag_id_storage,
	}
	
	if map.loc_id_storage == ArkInventory.Const.Location.AccountBank then
		
		local tabData = C_Bank.FetchPurchasedBankTabData( Enum.BankType.Account )
		self.selectedTabData = tabData[map.tab_id]
		
	elseif map.loc_id_storage == ArkInventory.Const.Location.Vault then
		
		local name, icon = GetGuildBankTabInfo( map.tab_id )
		
		self.selectedTabData = {
			ID = map.tab_id,
			name = name,
			icon = icon,
		}
		
	end
	
	local name = nameCheck( self.selectedTabData.name )
	self.selectedTabData.name = name
	
	self.mode = IconSelectorPopupFrameModes.Edit
	
	self:Show( )
	
end


function ArkInventoryIconSelectorPopupFrameMixin:OnLoad( )
	
	CallbackRegistryMixin.OnLoad( self )
	
	IconSelectorPopupFrameTemplateMixin.OnLoad( self )
	
	local function OnIconSelected( selectionIndex, icon )
		
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture( icon )
		
		-- Index is not yet set, but we know if an icon in IconSelector was selected it was in the list, so set directly.
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText( ICON_SELECTION_CLICK )
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetFontObject( GameFontHighlightSmall )
		
	end
	
	self.IconSelector:SetSelectedCallback( OnIconSelected )
	
end

function ArkInventoryIconSelectorPopupFrameMixin:OnShow( )
	
	local loc_id_window = self.ARK_Data.loc_id_window
	local bag_id_window = self.ARK_Data.bag_id_window
	
	parentframename = string.format( "ARKINV_Frame%dTitle", loc_id_window )
	local parentframe = _G[parentframename]
	
	self:ClearAllPoints( )
	self:SetScale( 0.75 )
	self:SetPoint( "TOPLEFT", parentframe, "TOPRIGHT", 10, 0 )
	
	--ArkInventory.Output( loc_id_window, " / ", bag_id_window, " / ", parentframename )
	
	
	
	
	
	
	local editBoxHeaderText = "not set"
	
	local loc_id_storage = self.ARK_Data.loc_id_storage
	if loc_id_storage == ArkInventory.Const.Location.AccountBank then
		editBoxHeaderText = ACCOUNT_BANK_TAB_NAME_PROMPT
	elseif loc_id_storage == ArkInventory.Const.Location.Vault then
		editBoxHeaderText = GUILDBANK_POPUP_TEXT
	else
		return
	end
	
	self.BorderBox.EditBoxHeaderText:SetText( editBoxHeaderText )
	
	
	
	
	IconSelectorPopupFrameTemplateMixin.OnShow( self )
	
	self.iconDataProvider = self:RefreshIconDataProvider( )
	
	self:Update( )
	
	self:SetIconFilter( IconSelectorPopupFrameIconFilterTypes.All )
	
	self.BorderBox.IconSelectorEditBox:SetFocus( )
	self.BorderBox.IconSelectorEditBox:OnTextChanged( )
	
	PlaySound( SOUNDKIT.IG_CHARACTER_INFO_OPEN )
	
end

function ArkInventoryIconSelectorPopupFrameMixin:RefreshIconDataProvider( )
	
	if self.iconDataProvider == nil then
		self.iconDataProvider = CreateAndInitFromMixin( IconDataProviderMixin, IconDataProviderExtraType.None )
	end
	
	return self.iconDataProvider
	
end

function ArkInventoryIconSelectorPopupFrameMixin:OnHide( )
	
	IconSelectorPopupFrameTemplateMixin.OnHide( self )
	
	PlaySound( SOUNDKIT.IG_CHARACTER_INFO_TAB )
	
	if iconDataProvider ~= nil then
		iconDataProvider:Release( )
		iconDataProvider = nil
	end
	
end

function ArkInventoryIconSelectorPopupFrameMixin:Update( )
	
	local name = self.selectedTabData.name
	local icon = self.selectedTabData.icon
	
	--ArkInventory.Output( "name [", name, "], icon [", icon, "]" )
	
	self.BorderBox.IconSelectorEditBox:SetText( name )
	self.BorderBox.IconSelectorEditBox:HighlightText( )
	
	local defaultIconSelected = string.lower( icon ) == string.lower( QUESTION_MARK_ICON )
	if defaultIconSelected then
		local initialIndex = 1
		self.IconSelector:SetSelectedIndex( initialIndex )
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture( self:GetIconByIndex( initialIndex ) )
	else
		self.IconSelector:SetSelectedIndex( self:GetIndexOfIcon( icon ) )
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture( icon )
	end
	
	local getSelection = GenerateClosure( self.iconDataProvider.GetIconByIndex, self.iconDataProvider )
	local getNumSelections = GenerateClosure( self.iconDataProvider.GetNumIcons, self.iconDataProvider )
	
	self.IconSelector:SetSelectionsDataProvider( getSelection, getNumSelections )
	self.IconSelector:ScrollToSelectedIndex( )
	
	self:SetSelectedIconText( )
	
end

function ArkInventoryIconSelectorPopupFrameMixin:CancelButton_OnClick( )
	
	IconSelectorPopupFrameTemplateMixin.CancelButton_OnClick( self )
	
	PlaySound( SOUNDKIT.GS_TITLE_OPTION_OK )
	
end

function ArkInventoryIconSelectorPopupFrameMixin:OkayButton_OnClick( )
	
	IconSelectorPopupFrameTemplateMixin.OkayButton_OnClick( self )
	
	PlaySound( SOUNDKIT.GS_TITLE_OPTION_OK )
	
	
	
	local icon = self.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture( )
	local name = nameCheck( self.BorderBox.IconSelectorEditBox:GetText( ) )
	
	
	local loc_id_storage = self.ARK_Data.loc_id_storage
	if loc_id_storage == ArkInventory.Const.Location.AccountBank then
		
		local depositFlags = self.selectedTabData.depositFlags
		
		C_Bank.UpdateBankTabSettings( self.selectedTabData.bankType, self.selectedTabData.ID, name, icon, depositFlags )
		
	elseif loc_id_storage == ArkInventory.Const.Location.Vault then
		
		--ArkInventory.Output( "[", self.selectedTabData.ID, "] [", name, "] [", icon, "]" )
		SetGuildBankTabInfo( self.selectedTabData.ID, name, icon )
		
	end
	
	
	
	local bag_id_storage = self.ARK_Data.bag_id_storage
	
	local storage = ArkInventory.Codex.GetStorage( nil, loc_id_storage )
	local bag = storage.data.location[loc_id_storage].bag[bag_id_storage]
	
	bag.name = name
	bag.texture = icon
	
	ArkInventory:SendMessage( "EVENT_ARKINV_CHANGER_UPDATE_BUCKET", self.ARK_Data.loc_id_window )
	
end
