--Neuron Menu Bar, a World of Warcraft® user interface addon.

--Most of this code is based off of the 7.0 version of Blizzard's
--MainMenuBarMicroButtons.lua & MainMenuBarMicroButtons.xml files

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------
local NEURON = Neuron
local DB

NEURON.NeuronMenuBar = NEURON:NewModule("MenuBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronMenuBar = NEURON.NeuronMenuBar

local menubarsDB, menubtnsDB

local MENUBTN = setmetatable({}, { __index = CreateFrame("Frame") })

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local gDef = {
    snapTo = false,
    snapToFrame = false,
    snapToPoint = false,
    point = "BOTTOMRIGHT",
    x = -335,
    y = 23,
}

local menuElements = {}
local addonData, sortData = {}, {}

local configData = {
    stored = false,
}

-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronMenuBar:OnInitialize()

    local object
    local bar

    DB = NeuronCDB


    menubarsDB = DB.menubars
    menubtnsDB = DB.menubtns


    if (not DB.scriptProfile) then
        DB.scriptProfile = false
    end

    ----------------------------------------------------------------
    MENUBTN.SetData = NeuronMenuBar.SetData
    MENUBTN.LoadData = NeuronMenuBar.LoadData
    MENUBTN.SaveData = NeuronMenuBar.SaveData
    MENUBTN.SetAux = NeuronMenuBar.SetAux
    MENUBTN.LoadAux = NeuronMenuBar.LoadAux
    MENUBTN.SetGrid = NeuronMenuBar.SetGrid
    MENUBTN.SetDefaults = NeuronMenuBar.SetDefaults
    MENUBTN.GetDefaults = NeuronMenuBar.GetDefaults
    MENUBTN.SetType = NeuronMenuBar.SetType
    MENUBTN.GetSkinned = NeuronMenuBar.GetSkinned
    MENUBTN.SetSkinned = NeuronMenuBar.SetSkinned
    ----------------------------------------------------------------

    NEURON:RegisterBarClass("menu", "MenuBar", L["Menu Bar"], "Menu Button", menubarsDB, menubarsDB, NeuronMenuBar, menubtnsDB, "CheckButton", "NeuronAnchorButtonTemplate", { __index = MENUBTN }, #menuElements, gDef, nil, false)
    NEURON:RegisterGUIOptions("menu", { AUTOHIDE = true, SHOWGRID = false, SPELLGLOW = false, SNAPTO = true, MULTISPEC = false, HIDDEN = true, LOCKBAR = false, TOOLTIPS = true }, false, false)

    if (DB.menubarFirstRun) then
        bar, object = NEURON.NeuronBar:CreateNewBar("menu", 1, true)

        for i=1,#menuElements do
            object = NEURON.NeuronButton:CreateNewObject("menu", i)
            NEURON.NeuronBar:AddObjectToList(bar, object)
        end

        DB.menubarFirstRun = false

    else
        local count = 0

        for id,data in pairs(menubarsDB) do
            if (data ~= nil) then
                NEURON.NeuronBar:CreateNewBar("menu", id)
            end
        end

        for id,data in pairs(menubtnsDB) do
            if (data ~= nil) then
                NEURON.NeuronButton:CreateNewObject("menu", id)
            end

            count = count + 1
        end

        if (count < #menuElements) then
            for i=count+1, #menuElements do
                object = NEURON.NeuronButton:CreateNewObject("menu", i)
            end
        end
    end

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronMenuBar:OnEnable()

    NeuronMenuBar:SecureHook("UpdateMicroButtons", NeuronMenuBar.updateMicroButtons)

    -- Hooks the Microbutton alerts that don't trigger of events  ie closing the talent frame
    NeuronMenuBar:SecureHook("MainMenuMicroButton_ShowAlert", NeuronMenuBar.MainMenuMicroButton_ShowAlert)

    -- Forces the default alert frames to auto hide if something tries to show them
    TalentMicroButtonAlert:SetScript("OnShow", function() end)
    CollectionsMicroButtonAlert:SetScript("OnShow", function()  end)
    EJMicroButtonAlert:SetScript("OnShow", function() end)

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronMenuBar:OnDisable()

end


------------------------------------------------------------------------------


-------------------------------------------------------------------------------



---  This replaces the Blizzard Flash function that causes massive taint when used.
-- pram: self  - the frame to create animation layer.  This layer should have a "$parentFlash" texture layer to it
function NeuronMenuBar.CreateAnimationLayer(self)
    local frame = _G[self:GetName().."Flash"]
    frame:SetAlpha(0)
    frame:Show()

    local flasher = frame:CreateAnimationGroup()
    flasher:SetLooping("REPEAT")

    -- Flashing in
    local fade1 = flasher:CreateAnimation("Alpha")
    fade1:SetDuration(1)
    fade1:SetSmoothing("IN")
    --fade1:SetChange(1)
    fade1:SetFromAlpha(0)
    fade1:SetToAlpha(1)
    fade1:SetOrder(1)

    -- Holding it visible for 1 second
    --fade1:SetEndDelay(.5)

    -- Flashing out
    local fade2 = flasher:CreateAnimation("Alpha")
    fade2:SetDuration(1)
    fade2:SetSmoothing("OUT")
    --fade2:SetChange(-1)
    fade2:SetFromAlpha(1)
    fade2:SetToAlpha(0)
    fade2:SetOrder(3)

    -- Holding it for 1 second before calling OnFinished
    --fade2:SetEndDelay(.5)

    flasher:SetScript("OnFinished", function() f:SetAlpha(0) end)

    self.Animate = flasher
end


--- Updates the microbuttons and sets the textures or if it is currently unavailable.
--   The :Enable() & :Disable() blocks have CombatLockdown tests to prevent taint.
function NeuronMenuBar.updateMicroButtons()
    local playerLevel = UnitLevel("player")
    local factionGroup = UnitFactionGroup("player")

    if ( factionGroup == "Neutral" ) then
        NeuronGuildButton.factionGroup = factionGroup
        NeuronLFDButton.factionGroup = factionGroup
    else
        NeuronGuildButton.factionGroup = nil
        NeuronLFDButton.factionGroup = nil
    end

    if (NeuronCharacterButton and CharacterFrame:IsShown()) then
        NeuronCharacterButton:SetButtonState("PUSHED", true)
        NeuronMenuBar.CharacterButton_SetPushed(NeuronCharacterButton)
    else
        NeuronCharacterButton:SetButtonState("NORMAL")
        NeuronMenuBar.CharacterButton_SetNormal(NeuronCharacterButton)
    end

    if (SpellBookFrame and SpellBookFrame:IsShown()) then
        NeuronSpellbookButton:SetButtonState("PUSHED", true)
    else
        NeuronSpellbookButton:SetButtonState("NORMAL")
    end

    if (PlayerTalentFrame and PlayerTalentFrame:IsShown()) then
        NeuronTalentButton:SetButtonState("PUSHED", true)
        NeuronMenuBar.IMicroButtonPulse(NeuronTalentButton, "Stop")
        NeuronTalentMicroButtonAlert:Hide()
    else
        if ( playerLevel < SHOW_SPEC_LEVEL or (IsKioskModeEnabled() and NEURON.class ~= "DEMONHUNTER") ) then

            if not InCombatLockdown() then
                NeuronTalentButton:Disable()
                if (IsKioskModeEnabled()) then
                    SetKioskTooltip(TalentMicroButton);
                end
            end
        else
            if not InCombatLockdown() then NeuronTalentButton:Enable() end
            NeuronTalentButton:SetButtonState("NORMAL")
        end
    end

    if (  WorldMapFrame and WorldMapFrame:IsShown() ) then
        NeuronQuestLogButton:SetButtonState("PUSHED", true)
    else
        NeuronQuestLogButton:SetButtonState("NORMAL")
    end

    if ( ( GameMenuFrame and GameMenuFrame:IsShown() )
            or ( InterfaceOptionsFrame:IsShown())
            or ( KeyBindingFrame and KeyBindingFrame:IsShown())
            or ( MacroFrame and MacroFrame:IsShown()) ) then
        NeuronLatencyButton:SetButtonState("PUSHED", true)
        NeuronMenuBar.LatencyButton_SetPushed(NeuronLatencyButton)
    else
        NeuronLatencyButton:SetButtonState("NORMAL")
        NeuronMenuBar.LatencyButton_SetNormal(NeuronLatencyButton)
    end

    NeuronMenuBar.updateTabard()
    if ( IsTrialAccount() or (IsVeteranTrialAccount() and not IsInGuild()) or factionGroup == "Neutral" or IsKioskModeEnabled() ) then
        NeuronGuildButton:Disable()
        if (IsKioskModeEnabled()) then
            SetKioskTooltip(GuildMicroButton);--Check
        end
    elseif ( ( GuildFrame and GuildFrame:IsShown() ) or ( LookingForGuildFrame and LookingForGuildFrame:IsShown() ) ) then
        if not InCombatLockdown() then
            NeuronGuildButton:Enable()
        end
        NeuronGuildButton:SetButtonState("PUSHED", true)
        NeuronGuildButtonTabard:SetPoint("TOPLEFT", -1, -1)
        NeuronGuildButtonTabard:SetAlpha(0.70)
    else
        if not InCombatLockdown() then
            NeuronGuildButton:Enable()
        end
        NeuronGuildButton:SetButtonState("NORMAL")
        NeuronGuildButtonTabard:SetPoint("TOPLEFT", 0, 0)
        NeuronGuildButtonTabard:SetAlpha(1)
        if ( IsInGuild() ) then
            NeuronGuildButton.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
            NeuronGuildButton.newbieText = NEWBIE_TOOLTIP_GUILDTAB
        else
            NeuronGuildButton.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB")
            NeuronGuildButton.newbieText = NEWBIE_TOOLTIP_LOOKINGFORGUILDTAB
        end
    end

    if ( PVEFrame and PVEFrame:IsShown() ) then
        NeuronLFDButton:SetButtonState("PUSHED", true)
    else
        --if ( playerLevel < NeuronLFDButton.minLevel or factionGroup == "Neutral" ) then
        if (IsKioskModeEnabled() or playerLevel < LFDMicroButton.minLevel or factionGroup == "Neutral" ) then
            if (IsKioskModeEnabled()) then
                SetKioskTooltip(LFDMicroButton);
            end
            if not InCombatLockdown() then NeuronLFDButton:Disable() end
        else
            if not InCombatLockdown() then NeuronLFDButton:Enable() end
            NeuronLFDButton:SetButtonState("NORMAL")
        end
    end

    if ( AchievementFrame and AchievementFrame:IsShown() ) then
        NeuronAchievementButton:SetButtonState("PUSHED", true)
    else
        if ( ( HasCompletedAnyAchievement() or IsInGuild() ) and CanShowAchievementUI() ) then
            if not InCombatLockdown() then NeuronAchievementButton:Enable() end
            NeuronAchievementButton:SetButtonState("NORMAL")
        else
            if not InCombatLockdown() then NeuronAchievementButton:Disable() end
        end
    end

    if ( EncounterJournal and EncounterJournal:IsShown() ) then
        NeuronEJButton:SetButtonState("PUSHED", true)
        NeuronMenuBar.IMicroButtonPulse(NeuronEJButton, "Stop")
        NeuronLFDMicroButtonAlert:Hide()
    else
        if ( playerLevel < NeuronEJButton.minLevel or factionGroup == "Neutral" ) then
            if not InCombatLockdown() then NeuronEJButton:Disable() end
            EJMicroButton_ClearNewAdventureNotice()  --CHECK
        else
            if not InCombatLockdown() then NeuronEJButton:Enable() end
            NeuronEJButton:SetButtonState("NORMAL")
        end
    end

    if ( CollectionsJournal and CollectionsJournal:IsShown() ) then
        if not InCombatLockdown() then NeuronCollectionsButton:Enable() end
        NeuronCollectionsButton:SetButtonState("PUSHED", true)
        NeuronMenuBar.IMicroButtonPulse(NeuronCollectionsButton, "Stop")
        NeuronCollectionsMicroButtonAlert:Hide()
    else
        if not InCombatLockdown() then NeuronCollectionsButton:Enable() end
        NeuronCollectionsButton:SetButtonState("NORMAL")
    end

    if ( StoreFrame and StoreFrame_IsShown() ) then
        NeuronStoreButton:SetButtonState("PUSHED", true)
    else
        NeuronStoreButton:SetButtonState("NORMAL")
    end


    if (  GameLimitedMode_IsActive() ) then
        NeuronStoreButton.disabledTooltip = ERR_FEATURE_RESTRICTED_TRIAL
        if not InCombatLockdown() then NeuronStoreButton:Disable() end
    elseif (  C_StorePublic.IsDisabledByParentalControls() ) then
        NeuronStoreButton.disabledTooltip =  BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS
        if not InCombatLockdown() then NeuronStoreButton:Disable() end
    else
        NeuronStoreButton.disabledTooltip = nil
        if not InCombatLockdown() then NeuronStoreButton:Enable() end
    end
end


function NeuronMenuBar.AchievementButton_OnEvent(self, event, ...)
    if (IsKioskModeEnabled()) then
        return;
    end
    if ( event == "UPDATE_BINDINGS" ) then
        self.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
    else
        NeuronMenuBar.updateMicroButtons()
    end
end


function NeuronMenuBar.GuildButton_OnEvent(self, event, ...)
    if (IsKioskModeEnabled()) then
        return;
    end

    if ( event == "UPDATE_BINDINGS" ) then
        if ( IsInGuild() ) then
            NeuronGuildButton.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
        else
            NeuronGuildButton.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB")
        end
    elseif ( event == "PLAYER_GUILD_UPDATE" or event == "NEUTRAL_FACTION_SELECT_RESULT" ) then
        NeuronGuildButtonTabard.needsUpdate = true
        NeuronMenuBar.updateMicroButtons()
    end
end


--- Updates the guild tabard icon on the menu bar
-- params: forceUpdate - (boolean) True- forces an update reguardless if has been set to need updateing
function NeuronMenuBar.updateTabard(forceUpdate)
    local tabard = NeuronGuildButtonTabard
    if ( not tabard.needsUpdate and not forceUpdate ) then
        return
    end
    -- switch textures if the guild has a custom tabard
    local emblemFilename = select(10, GetGuildLogoInfo())
    if ( emblemFilename ) then
        if ( not tabard:IsShown() ) then
            local button = NeuronGuildButton
            button:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
            button:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")
            -- no need to change disabled texture, should always be available if you're in a guild
            tabard:Show()
        end
        SetSmallGuildTabardTextures("player", tabard.emblem, tabard.background)
    else
        if ( tabard:IsShown() ) then
            local button = NeuronGuildButton
            button:SetNormalTexture("Interface\\Buttons\\UI-MicroButton-Socials-Up")
            button:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Socials-Down")
            button:SetDisabledTexture("Interface\\Buttons\\UI-MicroButton-Socials-Disabled")
            tabard:Hide()
        end
    end
    tabard.needsUpdate = nil
end


function NeuronMenuBar.CharacterButton_OnLoad(self)
    self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
    self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")
    self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
    self:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    self:RegisterEvent("UPDATE_BINDINGS")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
    self.newbieText = NEWBIE_TOOLTIP_CHARACTER

    menuElements[#menuElements+1] = self
end


function NeuronMenuBar.CharacterButton_OnEvent(self, event, ...)
    if ( event == "UNIT_PORTRAIT_UPDATE" ) then
        local unit = ...
        if ( not unit or unit == "player" ) then
            SetPortraitTexture(NeuronCharacterButtonPortrait, "player")
        end
        return
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        SetPortraitTexture(NeuronCharacterButtonPortrait, "player")
    elseif ( event == "UPDATE_BINDINGS" ) then
        self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
    end
end


function NeuronMenuBar.CharacterButton_SetPushed(self)
    NeuronCharacterButtonPortrait:SetTexCoord(0.2666, 0.8666, 0, 0.8333)
    NeuronCharacterButtonPortrait:SetAlpha(0.5)
end


function NeuronMenuBar.CharacterButton_SetNormal(self)
    NeuronCharacterButtonPortrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9)
    NeuronCharacterButtonPortrait:SetAlpha(1.0)
end


function NeuronMenuBar.TalentButton_OnEvent(self, event, ...)
    if (event == "PLAYER_LEVEL_UP") then
        local level = ...
        if (level == SHOW_SPEC_LEVEL) then
            NeuronMenuBar.IMicroButtonPulse(self)
            NeuronMenuBar.MainMenuMicroButton_ShowAlert(NeuronTalentMicroButtonAlert, TALENT_MICRO_BUTTON_SPEC_TUTORIAL)
        elseif (level == SHOW_TALENT_LEVEL) then
            NeuronMenuBar.IMicroButtonPulse(self)
            NeuronMenuBar.MainMenuMicroButton_ShowAlert(NeuronTalentMicroButtonAlert, TALENT_MICRO_BUTTON_TALENT_TUTORIAL)
        end
    elseif ( event == "PLAYER_SPECIALIZATION_CHANGED") then
        -- If we just unspecced, and we have unspent talent points, it's probably spec-specific talents that were just wiped.  Show the tutorial box.
        local unit = ...
        if(unit == "player" and GetSpecialization() == nil and GetNumUnspentTalents() > 0) then
           NeuronMenuBar.MainMenuMicroButton_ShowAlert(NeuronTalentMicroButtonAlert, TALENT_MICRO_BUTTON_UNSPENT_TALENTS)
        end
    elseif ( event == "PLAYER_TALENT_UPDATE" or event == "NEUTRAL_FACTION_SELECT_RESULT" ) then
        NeuronMenuBar.updateMicroButtons()

        -- On the first update from the server, flash the button if there are unspent points
        -- Small hack: GetNumSpecializations should return 0 if talents haven't been initialized yet
        if (not self.receivedUpdate and GetNumSpecializations(false) > 0) then
            self.receivedUpdate = true
            local shouldPulseForTalents = GetNumUnspentTalents() > 0 and not AreTalentsLocked()
            if (UnitLevel("player") >= SHOW_SPEC_LEVEL and (not GetSpecialization() or shouldPulseForTalents)) then
                NeuronMenuBar.IMicroButtonPulse(self)
            end
        end
    elseif ( event == "UPDATE_BINDINGS" ) then
        self.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
    elseif ( event == "PLAYER_CHARACTER_UPGRADE_TALENT_COUNT_CHANGED" ) then
        local prev, current = ...
        if ( prev == 0 and current > 0 ) then
            NeuronMenuBar.IMicroButtonPulse(self)
            NeuronMenuBar.MainMenuMicroButton_ShowAlert(NeuronTalentMicroButtonAlert, TALENT_MICRO_BUTTON_TALENT_TUTORIAL)
        elseif ( prev ~= current ) then
            NeuronMenuBar.IMicroButtonPulse(self)
            NeuronMenuBar.MainMenuMicroButton_ShowAlert	(NeuronTalentMicroButtonAlert, TALENT_MICRO_BUTTON_UNSPENT_TALENTS)
        end
    elseif (event == "PLAYER_ENTERING_WORLD") then
        NeuronMenuBar.updateMicroButtons()
    end
end

function NeuronMenuBar.SafeSetCollectionJournalTab(tab)
    if  InCombatLockdown() then return end
    if CollectionsJournal_SetTab then
        CollectionsJournal_SetTab(CollectionsJournal, tab)
    else
        SetCVar("petJournalTab", tab)
    end
end



function NeuronMenuBar.CollectionsButton_OnEvent(self, event, ...)
    if ( event == "HEIRLOOMS_UPDATED" ) then
        local itemID, updateReason = ...
        if itemID and updateReason == "NEW" then
            if MainMenuMicroButton_ShowAlert(NeuronCollectionsMicroButtonAlert, HEIRLOOMS_MICRO_BUTTON_SPEC_TUTORIAL, LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL) then
                NeuronMenuBar.IMicroButtonPulse(self)
                NeuronMenuBar.SafeSetCollectionJournalTab(4)
            end
        end
    elseif ( event == "PET_JOURNAL_NEW_BATTLE_SLOT" ) then
        NeuronMenuBar.IMicroButtonPulse(self)
        MainMenuMicroButton_ShowAlert(NeuronCollectionsMicroButtonAlert, COMPANIONS_MICRO_BUTTON_NEW_BATTLE_SLOT)
        NeuronMenuBar.SafeSetCollectionJournalTab(2)
    elseif ( event == "TOYS_UPDATED" ) then
        local itemID, new = ...
        if itemID and new then
            if MainMenuMicroButton_ShowAlert(NeuronCollectionsMicroButtonAlert, TOYBOX_MICRO_BUTTON_SPEC_TUTORIAL, LE_FRAME_TUTORIAL_TOYBOX) then
                NeuronMenuBar.IMicroButtonPulse(self)
                NeuronMenuBar.SafeSetCollectionJournalTab(3)
            end
        end
    else
        self.tooltipText = MicroButtonTooltipText(COLLECTIONS, "TOGGLECOLLECTIONS")
        self.newbieText = NEWBIE_TOOLTIP_MOUNTS_AND_PETS
        NeuronMenuBar.updateMicroButtons()
    end
end




-- Encounter Journal
function NeuronMenuBar.EJButton_OnLoad(self)
    LoadMicroButtonTextures(self, "EJ")
    SetDesaturation(self:GetDisabledTexture(), true)
    self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
    self.newbieText = NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL
    if (IsKioskModeEnabled()) then
        self:Disable();
    end

    self.minLevel = math.min(SHOW_LFD_LEVEL, SHOW_PVP_LEVEL);

    --events that can trigger a refresh of the adventure journal
    self:RegisterEvent("VARIABLES_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    NeuronMenuBar.CreateAnimationLayer(self)
    menuElements[#menuElements+1] = self
end


function NeuronMenuBar.EJButton_OnEvent(self, event, ...)
    if (IsKioskModeEnabled()) then
        return;
    end

    local arg1 = ...
    if( event == "UPDATE_BINDINGS" ) then
        self.tooltipText = MicroButtonTooltipText(ADVENTURE_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
        self.newbieText = NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL
        NeuronMenuBar.updateMicroButtons()
    elseif( event == "VARIABLES_LOADED" ) then
        self:UnregisterEvent("VARIABLES_LOADED");
        self.varsLoaded = true;

        local showAlert = GetCVarBool("showAdventureJournalAlerts")
        if( showAlert ) then
            local lastTimeOpened = tonumber(GetCVar("advJournalLastOpened"))
            if ( UnitLevel("player") >= NeuronEJButton.minLevel and UnitFactionGroup("player") ~= "Neutral" ) then
                if ( GetServerTime() - lastTimeOpened > EJ_ALERT_TIME_DIFF ) then
                    NeuronEJMicroButtonAlert:Show()
                    NeuronMenuBar.IMicroButtonPulse(NeuronEJButton)
                end

                if ( lastTimeOpened ~= 0 ) then
                    SetCVar("advJournalLastOpened", GetServerTime() )
                end
            end

            NeuronMenuBar.EJMicroButton_UpdateAlerts(true)
        end

    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        self.playerEntered = true;
    elseif ( event == "UNIT_LEVEL" and arg1 == "player" ) then
        EJMicroButton_UpdateNewAdventureNotice(true)  --Check
    elseif event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" then
        local playerLevel = UnitLevel("player")
        if ( playerLevel == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) then
            EJMicroButton_UpdateNewAdventureNotice(false)--Check
        end
    elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
        self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
        self.zoneEntered = true;
    end

    if( event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" or event == "ZONE_CHANGED_NEW_AREA" ) then
        if( self.playerEntered and self.varsLoaded and self.zoneEntered) then
            NeuronMenuBar.EJMicroButton_UpdateDisplay();
            if( self:IsEnabled() ) then
                C_AdventureJournal.UpdateSuggestions();

                local showAlert = not GetCVarBool("hideAdventureJournalAlerts");
                if( showAlert ) then
                    -- display alert if the player hasn't opened the journal for a long time
                    local lastTimeOpened = tonumber(GetCVar("advJournalLastOpened"));
                    if ( GetServerTime() - lastTimeOpened > EJ_ALERT_TIME_DIFF ) then
                        NeuronEJMicroButtonAlert:Show();
                        NeuronMenuBar.IMicroButtonPulse(NeuronEJButton);
                    end

                    if ( lastTimeOpened ~= 0 ) then
                        SetCVar("advJournalLastOpened", GetServerTime() );
                    end

                    NeuronMenuBar.EJMicroButton_UpdateAlerts(true);
                end
            end
        end
    end
end


function NeuronMenuBar.EJMicroButton_UpdateNewAdventureNotice(levelUp)
    if ( NeuronEJButton:IsEnabled() and C_AdventureJournal.UpdateSuggestions(levelUp) ) then
        if( not EncounterJournal or not EncounterJournal:IsShown() ) then
            NeuronEJButton.Flash:Show()
            NeuronEJButton.NewAdventureNotice:Show()
        end
    end
end


function NeuronMenuBar.EJMicroButton_ClearNewAdventureNotice()
    NeuronEJButton.Flash:Hide()
    NeuronEJButton.NewAdventureNotice:Hide()
end

function NeuronMenuBar.EJMicroButton_UpdateDisplay()
    local frame = EJMicroButton;
    if ( EncounterJournal and EncounterJournal:IsShown() ) then
        frame:SetButtonState("PUSHED", true);
    else
        local disabled = not C_AdventureJournal.CanBeShown();
        if ( IsKioskModeEnabled() or disabled ) then
            frame:Disable();
            if (IsKioskModeEnabled()) then
                SetKioskTooltip(frame);
            elseif ( disabled ) then
                frame.disabledTooltip = FEATURE_NOT_YET_AVAILABLE;
            end
            NeuronMenuBar.EJMicroButton_ClearNewAdventureNotice();
        else
            frame:Enable();
            frame:SetButtonState("NORMAL");
        end
    end
end

function NeuronMenuBar.EJMicroButton_UpdateAlerts( flag )
    if ( flag ) then
        NeuronEJButton:RegisterEvent("UNIT_LEVEL")
        NeuronEJButton:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
        NeuronMenuBar.EJMicroButton_UpdateNewAdventureNotice(false)
    else
        NeuronEJButton:UnregisterEvent("UNIT_LEVEL")
        NeuronEJButton:UnregisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
        NeuronMenuBar.EJMicroButton_ClearNewAdventureNotice()
    end
end


--- This adds a frame element to the table.
function NeuronMenuBar.AddMenuElement(self)
    menuElements[#menuElements+1] = self
end


function NeuronMenuBar.MainMenuMicroButton_ShowAlert(alert, text, tutorialIndex)
    if alert == TalentMicroButtonAlert then alert = NeuronTalentMicroButtonAlert end

    alert.Text:SetText(text)
    alert:SetHeight(alert.Text:GetHeight()+42)
    alert.tutorialIndex = tutorialIndex
    --LDB alert:Show()
    return alert:IsShown()
end


function NeuronMenuBar.LatencyButton_OnLoad(self)
    self.overlay = _G[self:GetName().."Overlay"]
    self.overlay:SetWidth(self:GetWidth()+1)
    self.overlay:SetHeight(self:GetHeight())

    self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
    self.newbieText = NEWBIE_TOOLTIP_MAINMENU

    self.hover = nil
    self.updateInterval = 0
    --self.elapsed = 0

    self:RegisterForClicks("LeftButtonDown", "RightButtonDown", "LeftButtonUp", "RightButtonUp")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("UPDATE_BINDINGS")

    menuElements[#menuElements+1] = self

end


function NeuronMenuBar.LatencyButton_OnEvent(self, event, ...)
    if (event == "ADDON_LOADED" and ...=="Neuron") then
        self.lastStart = 0
        if (DB) then
            self.enabled = DB.scriptProfile
        end
        GameMenuFrame:HookScript("OnShow", NeuronMenuBar.LatencyButton_SetPushed)
        GameMenuFrame:HookScript("OnHide", NeuronMenuBar.LatencyButton_SetNormal)
    end

    self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
end


function NeuronMenuBar.LatencyButton_OnClick(self, button, down)
    if (button == "RightButton") then
        if (IsShiftKeyDown()) then
            if (DB.scriptProfile) then
                SetCVar("scriptProfile", "0")
                DB.scriptProfile = false
            else
                SetCVar("scriptProfile", "1")
                DB.scriptProfile = true

            end

            ReloadUI()
        end

        if (not down) then
            if (self.alt_tooltip) then
                self.alt_tooltip = false
            else
                self.alt_tooltip = true
            end

            NeuronMenuBar.LatencyButton_SetNormal()
        else
            NeuronMenuBar.LatencyButton_SetPushed()
        end

        NeuronMenuBar.LatencyButton_OnEnter(self)

    elseif (IsShiftKeyDown()) then
        ReloadUI()

    else
        if (self.down) then
            self.down = nil
            if (not GameMenuFrame:IsShown()) then
                CloseMenus()
                CloseAllWindows()
                PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
                ShowUIPanel(GameMenuFrame)
            else
                PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
                HideUIPanel(GameMenuFrame)
                NeuronMenuBar.LatencyButton_SetNormal()
            end

            if (InterfaceOptionsFrame:IsShown()) then
                InterfaceOptionsFrameCancel:Click()
            end

            return
        end

        if (self:GetButtonState() == "NORMAL") then
            NeuronMenuBar.LatencyButton_SetPushed()
            self.down = 1
        else
            self.down = 1
        end
    end
end


function NeuronMenuBar.LatencyButton_OnEnter(self)
    self.hover = 1
    self.updateInterval = 0

    if (self.alt_tooltip and not NeuronMenuBarTooltip.wasShown) then
        NeuronMenuBar.LatencyButton_AltOnEnter(self)
        GameTooltip:Hide()
        NeuronMenuBarTooltip:Show()

    elseif (self:IsMouseOver()) then
        MainMenuBarPerformanceBarFrame_OnEnter(self)

        local objects = NEURON:GetParentKeys(GameTooltip)
        local foundion, text

        for k,v in pairs(objects) do
            if (_G[v]:IsObjectType("FontString")) then
                text = _G[v]:GetText()
                if (text) then
                    foundion = text:match("%s+Neuron$")
                end
            end
        end

        if (not foundion) then
            for i=1, GetNumAddOns() do
                if (select(1,GetAddOnInfo(i)) == "Neuron") then
                    local mem = GetAddOnMemoryUsage(i)
                    if (mem > 1000) then
                        mem = mem / 1000
                    end
                    GameTooltip:AddLine(string.format(ADDON_MEM_MB_ABBR, mem, select(1,GetAddOnInfo(i))), 1.0, 1.0, 1.0)
                end
            end
        end

        NeuronMenuBarTooltip:Hide()
        GameTooltip:Show()
    end
end


function NeuronMenuBar.LatencyButton_AltOnEnter(self)
    if (not NeuronMenuBarTooltip:IsVisible()) then
        NeuronMenuBarTooltip:SetOwner(UIParent, "MENUBTN_PRESERVE")
    end

    if (self.enabled) then
        NeuronMenuBarTooltip:SetText("Script Profiling is |cff00ff00Enabled|r", 1, 1, 1)
        NeuronMenuBarTooltip:AddLine("(Shift-RightClick to Disable)", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
        NeuronMenuBarTooltip:AddLine("\n|cfff00000Warning:|r Script Profiling Affects Game Performance\n", 1, 1, 1, 1)

        for i=1, GetNumAddOns() do
            local name,_,_,enabled = GetAddOnInfo(i)

            if (not addonData[i]) then
                addonData[i] = { name = name, enabled = enabled	}
            end

            local addon = addonData[i]

            addon.currMem = GetAddOnMemoryUsage(i)

            if (not addon.maxMem or addon.maxMem < addon.currMem) then
                addon.maxMem = addon.currMem
            end

            local currCPU = GetAddOnCPUUsage(i)

            if (addon.lastUsage) then
                addon.currCPU = (currCPU - addon.lastUsage)/2.5

                if (not addon.maxCPU or addon.maxCPU < addon.currCPU) then
                    addon.maxCPU = addon.currCPU
                end
            else
                addon.currCPU = currCPU
            end

            if (self.usage > 0) then
                addon.percentCPU = addon.currCPU/self.usage * 100
            else
                addon.percentCPU = 0
            end

            addon.lastUsage = currCPU

            if (self.lastStart > 0) then
                addon.avgCPU = currCPU / self.lastStart
            end
        end

        if (self.usage) then
            NeuronMenuBarTooltip:AddLine("|cffffffff("..string.format("%.2f",(self.usage) / 2.5).."ms)|r Total Script CPU Time\n", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
        end

        wipe(sortData)

        for i,v in ipairs(addonData) do
            if (addonData[i].enabled) then
                local addLine = ""

                if (addonData[i].currCPU and addonData[i].currCPU > 0) then
                    addLine = addLine..string.format("%.2f", addonData[i].currCPU).."ms/"..string.format("%.1f", addonData[i].percentCPU).."%)|r "

                    local num = tonumber(addLine:match("^%d+"))

                    if (num and num < 10) then
                        addLine = "0"..addLine
                    end

                    if (addonData[i].name) then
                        addLine = "|cffffffff("..addLine..addonData[i].name.." "
                    end

                    tinsert(sortData, addLine)
                end
            end
        end

        table.sort(sortData, function(a,b) return a>b end)

        for i,v in ipairs(sortData) do
            NeuronMenuBarTooltip:AddLine(v, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
        end
    else
        NeuronMenuBarTooltip:SetText("Script Profiling is |cfff00000Disabled|r", 1, 1, 1)
        NeuronMenuBarTooltip:AddLine("(Shift-RightClick to Enable)", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
        NeuronMenuBarTooltip:AddLine("\n|cfff00000Warning:|r Script Profiling Affects Game Performance\n", 1, 1, 1, 1)
    end
end


function NeuronMenuBar.LatencyButton_OnLeave(self)
    self.hover = nil
    GameTooltip:Hide()
end


function NeuronMenuBar.LatencyButton_SetPushed()
    NeuronLatencyButtonOverlay:SetPoint("CENTER", NeuronLatencyButton, "CENTER", -1, -2)
end


function NeuronMenuBar.LatencyButton_SetNormal()
    NeuronLatencyButtonOverlay:SetPoint("CENTER", NeuronLatencyButton, "CENTER", 0, -0.5)
end


function NeuronMenuBar:SetData(button, bar)
    if (bar) then
        button.bar = bar

        button:SetFrameStrata(bar.gdata.objectStrata)
        button:SetScale(bar.gdata.scale)
    end

    button:SetFrameLevel(4)
end


function NeuronMenuBar:SaveData(button)
    -- empty
end


function NeuronMenuBar:LoadData(button, spec, state)
    local id = button.id

    button.DB = menubtnsDB

    if (button.DB) then
        if (not button.DB[id]) then
            button.DB[id] = {}
        end

        if (not button.DB[id].config) then
            button.DB[id].config = CopyTable(configData)
        end

        if (not button.DB[id]) then
            button.DB[id] = {}
        end

        if (not button.DB[id].data) then
            button.DB[id].data = {}
        end

        button.config = button.DB [id].config
        button.data = button.DB[id].data
    end
end


function NeuronMenuBar:SetGrid(button, show, hide)
    --empty
end

function NeuronMenuBar:SetAux(button)
    -- empty
end

function NeuronMenuBar:LoadAux(button)
    -- empty
end

function NeuronMenuBar:SetDefaults(button)
    -- empty
end

function NeuronMenuBar:GetDefaults(button)
    --empty
end

function NeuronMenuBar:SetSkinned(button)
    -- empty
end

function NeuronMenuBar:GetSkinned(button)
    --empty
end


function NeuronMenuBar:SetType(button, save)
    if (menuElements[button.id]) then
        button:SetWidth(menuElements[button.id]:GetWidth()*0.90)
        button:SetHeight(menuElements[button.id]:GetHeight()/1.60)
        button:SetHitRectInsets(button:GetWidth()/2, button:GetWidth()/2, self:GetHeight()/2, button:GetHeight()/2)

        button.element = menuElements[button.id]

        local objects = NEURON:GetParentKeys(button.element)

        for k,v in pairs(objects) do
            local name = v:gsub(button.element:GetName(), "")
            button[name:lower()] = _G[v]
        end

        button.element.normaltexture = button.element:CreateTexture("$parentNormalTexture", "OVERLAY", "NeuronCheckButtonTextureTemplate")
        button.element.normaltexture:ClearAllPoints()
        button.element.normaltexture:SetPoint("CENTER", 0, 0)
        button.element.icontexture = button.element:GetNormalTexture()
        button.element:ClearAllPoints()
        button.element:SetParent(button)
        button.element:Show()
        button.element:SetPoint("BOTTOM", self, "BOTTOM", 0, -1)
        button.element:SetHitRectInsets(3, 3, 23, 3)
    end
end




--- This will check the position of the menu bar and move the alert below bar if
-- to close to the top of the screen
-- Prams: self  - alert frame to be repositioned
-- Prams: parent - frame to be moved in relation to
function NeuronMenuBar.CheckAlertPosition(self, parent)
    if not parent:GetTop() then return end

    if ( self:GetHeight() > UIParent:GetTop() - parent:GetTop() ) then
        self:ClearAllPoints()
        self:SetPoint("TOP", parent, "BOTTOM", 0, -16)
        self.Arrow:ClearAllPoints()
        self.Arrow:SetPoint("BOTTOM", self, "TOP", 0, -4)
        self.Arrow.Arrow:SetTexture("Interface\\AddOns\\Neuron\\Images\\UpIndicator")
        self.Arrow.Arrow:SetTexCoord(0, 1, 0, 1)
        self.Arrow.Glow:Hide()
    end
end

--- Toggle for the flash animation layer
-- pram: self - Layer contining the animation layer
-- pram: control - Stop- stops the animation, any other command start it
function NeuronMenuBar.IMicroButtonPulse(self, control)
    if control == "Stop" then
        self.Animate:Stop()
    else
        self.Animate:Play()
    end
end