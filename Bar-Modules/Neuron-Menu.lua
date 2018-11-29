--Neuron Menu Bar, a World of Warcraft® user interface addon.

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------

local DB

Neuron.NeuronMenuBar = Neuron:NewModule("MenuBar", "AceHook-3.0")
local NeuronMenuBar = Neuron.NeuronMenuBar

local MENUBTN = setmetatable({}, {__index = Neuron.BUTTON})

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local defaultBarOptions = {
    [1] = {
        snapTo = false,
        snapToFrame = false,
        snapToPoint = false,
        point = "BOTTOMRIGHT",
        x = -348,
        y = 24,
    }
}

local menuElements = {}

-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronMenuBar:OnInitialize()

    DB = Neuron.db.profile


    menuElements[1] = CharacterMicroButton
    menuElements[2] = SpellbookMicroButton
    menuElements[3] = TalentMicroButton
    menuElements[4] = AchievementMicroButton
    menuElements[5] = QuestLogMicroButton
    menuElements[6] = GuildMicroButton
    menuElements[7] = LFDMicroButton
    menuElements[8] = CollectionsMicroButton
    menuElements[9] = EJMicroButton
    menuElements[10] = StoreMicroButton
    menuElements[11] = MainMenuMicroButton


    Neuron:RegisterBarClass("menu", "MenuBar", L["Menu Bar"], "Menu Button", DB.menubar, NeuronMenuBar, DB.menubtn, "CheckButton", "NeuronAnchorButtonTemplate", { __index = MENUBTN }, #menuElements)
    Neuron:RegisterGUIOptions("menu", { AUTOHIDE = true, SHOWGRID = false, SPELLGLOW = false, SNAPTO = true, MULTISPEC = false, HIDDEN = true, LOCKBAR = false, TOOLTIPS = true }, false, false)

    if DB.blizzbar == false then
        NeuronMenuBar:CreateBarsAndButtons()
    end
end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronMenuBar:OnEnable()

    Neuron:RegisterEvent("PET_BATTLE_OPENING_START")
    Neuron:RegisterEvent("PET_BATTLE_CLOSE")

    NeuronMenuBar:DisableDefault()

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronMenuBar:OnDisable()

end


------------------------------------------------------------------------------


function Neuron:PET_BATTLE_OPENING_START()
end

function Neuron:PET_BATTLE_CLOSE()
end

-------------------------------------------------------------------------------


function NeuronMenuBar:CreateBarsAndButtons()


    if (DB.menubarFirstRun) then

        for id, defaults in ipairs(defaultBarOptions) do

            local bar = Neuron.NeuronBar:CreateNewBar("menu", id, true) --this calls the bar constructor

            for	k,v in pairs(defaults) do
                bar.data[k] = v
            end

            local object

            for i=1,#menuElements do
                object = Neuron.NeuronButton:CreateNewObject("menu", i, true)
                Neuron.NeuronBar:AddObjectToList(bar, object)
            end
        end

        DB.menubarFirstRun = false

    else

        for id,data in pairs(DB.menubar) do
            if (data ~= nil) then
                Neuron.NeuronBar:CreateNewBar("menu", id)
            end
        end

        for id,data in pairs(DB.menubtn) do
            if (data ~= nil) then
                Neuron.NeuronButton:CreateNewObject("menu", id)
            end
        end
    end
end

function NeuronMenuBar:DisableDefault()

    local disableMenuBarFunctions = false

    for i,v in ipairs(Neuron.NeuronMenuBar) do
        if (v["bar"]) then --only disable if a specific button has an associated bar
            disableMenuBarFunctions = true
        end
    end

    if disableMenuBarFunctions then
        ---This stops PetBattles from taking over the Micro Buttons
        NeuronMenuBar:RawHook("MoveMicroButtons", function() end, true)
        NeuronMenuBar:RawHook("UpdateMicroButtonsParent", function() end, true)
    end

end


function MENUBTN:SetData( bar)
    if (bar) then

        self.bar = bar

        self:SetFrameStrata(bar.data.objectStrata)
        self:SetScale(bar.data.scale)

    end

    self:SetFrameLevel(4)
end


function MENUBTN:LoadData(spec, state)

    local id = self.id

    if not DB.menubtn[id] then
        DB.menubtn[id] = {}
    end

    self.DB = DB.menubtn[id]

    self.config = self.DB.config
    self.keys = self.DB.keys
    self.data = self.DB.data

end

function MENUBTN:SetType(save)
    if (menuElements[self.id]) then

        self:SetWidth(menuElements[self.id]:GetWidth()-2)
        self:SetHeight(menuElements[self.id]:GetHeight()-2)

        self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

        self.element = menuElements[self.id]

        local objects = Neuron:GetParentKeys(self.element)

        for k,v in pairs(objects) do
            local name = v:gsub(self.element:GetName(), "")
            self[name:lower()] = _G[v]
        end

        self.element:ClearAllPoints()
        self.element:SetParent(self)
        self.element:Show()
        self.element:SetPoint("CENTER", self, "CENTER")
        self.element:SetScale(1)
    end

end