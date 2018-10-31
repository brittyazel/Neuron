--Neuron Menu Bar, a World of Warcraft® user interface addon.

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------
local NEURON = Neuron
local DB

NEURON.NeuronMenuBar = NEURON:NewModule("MenuBar", "AceHook-3.0")
local NeuronMenuBar = NEURON.NeuronMenuBar

local MENUBTN = setmetatable({}, {__index = CreateFrame("CheckButton")})

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

    DB = NEURON.db.profile


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


    ----------------------------------------------------------------
    MENUBTN.SetData = NeuronMenuBar.SetData
    MENUBTN.LoadData = NeuronMenuBar.LoadData
    MENUBTN.SetAux = NeuronMenuBar.SetAux
    MENUBTN.LoadAux = NeuronMenuBar.LoadAux
    MENUBTN.SetObjectVisibility = NeuronMenuBar.SetObjectVisibility
    MENUBTN.SetDefaults = NeuronMenuBar.SetDefaults
    MENUBTN.GetDefaults = NeuronMenuBar.GetDefaults
    MENUBTN.SetType = NeuronMenuBar.SetType
    MENUBTN.GetSkinned = NeuronMenuBar.GetSkinned
    MENUBTN.SetSkinned = NeuronMenuBar.SetSkinned
    ----------------------------------------------------------------

    NEURON:RegisterBarClass("menu", "MenuBar", L["Menu Bar"], "Menu Button", DB.menubar, NeuronMenuBar, DB.menubtn, "CheckButton", "NeuronAnchorButtonTemplate", { __index = MENUBTN }, #menuElements, false)
    NEURON:RegisterGUIOptions("menu", { AUTOHIDE = true, SHOWGRID = false, SPELLGLOW = false, SNAPTO = true, MULTISPEC = false, HIDDEN = true, LOCKBAR = false, TOOLTIPS = true }, false, false)

    if DB.blizzbar == false then
        NeuronMenuBar:CreateBarsAndButtons()
    end
end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronMenuBar:OnEnable()

    NEURON:RegisterEvent("PET_BATTLE_OPENING_START")
    NEURON:RegisterEvent("PET_BATTLE_CLOSE")

    NeuronMenuBar:DisableDefault()

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronMenuBar:OnDisable()

end


------------------------------------------------------------------------------


function NEURON:PET_BATTLE_OPENING_START()
end

function NEURON:PET_BATTLE_CLOSE()
end

-------------------------------------------------------------------------------


function NeuronMenuBar:CreateBarsAndButtons()


    if (DB.menubarFirstRun) then

        for id, defaults in ipairs(defaultBarOptions) do

            local bar = NEURON.NeuronBar:CreateNewBar("menu", id, true) --this calls the bar constructor

            for	k,v in pairs(defaults) do
                bar.data[k] = v
            end

            local object

            for i=1,#menuElements do
                object = NEURON.NeuronButton:CreateNewObject("menu", i, true)
                NEURON.NeuronBar:AddObjectToList(bar, object)
            end
        end

        DB.menubarFirstRun = false

    else

        for id,data in pairs(DB.menubar) do
            if (data ~= nil) then
                NEURON.NeuronBar:CreateNewBar("menu", id)
            end
        end

        for id,data in pairs(DB.menubtn) do
            if (data ~= nil) then
                NEURON.NeuronButton:CreateNewObject("menu", id)
            end
        end
    end
end

function NeuronMenuBar:DisableDefault()

    local disableMenuBarFunctions = false

    for i,v in ipairs(NEURON.NeuronMenuBar) do
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


function NeuronMenuBar:SetData(button, bar)
    if (bar) then

        button.bar = bar

        button:SetFrameStrata(bar.data.objectStrata)
        button:SetScale(bar.data.scale)

    end

    button:SetFrameLevel(4)
end


function NeuronMenuBar:LoadData(button, spec, state)

    local id = button.id

    if not DB.menubtn[id] then
        DB.menubtn[id] = {}
    end

    button.DB = DB.menubtn[id]

    button.config = button.DB.config
    button.keys = button.DB.keys
    button.data = button.DB.data

end


function NeuronMenuBar:SetObjectVisibility(button, show, hide)
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
    --empty
end

function NeuronMenuBar:GetSkinned(button)
    --empty
end

function NeuronMenuBar:SetType(button, save)
    if (menuElements[button.id]) then

        button:SetWidth(menuElements[button.id]:GetWidth()-2)
        button:SetHeight(menuElements[button.id]:GetHeight()-2)

        button:SetHitRectInsets(button:GetWidth()/2, button:GetWidth()/2, button:GetHeight()/2, button:GetHeight()/2)

        button.element = menuElements[button.id]

        local objects = NEURON:GetParentKeys(button.element)

        for k,v in pairs(objects) do
            local name = v:gsub(button.element:GetName(), "")
            button[name:lower()] = _G[v]
        end

        button.element:ClearAllPoints()
        button.element:SetParent(button)
        button.element:Show()
        button.element:SetPoint("CENTER", button, "CENTER")
        button.element:SetScale(1)
    end

end