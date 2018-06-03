--Neuron Menu Bar, a World of Warcraft® user interface addon.

--Most of this code is based off of the 7.0 version of Blizzard's
--MainMenuBarMicroButtons.lua & MainMenuBarMicroButtons.xml files

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------
local NEURON = Neuron
local DB

NEURON.NeuronMenuBar = NEURON:NewModule("MenuBar")
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

    DB = NeuronCDB


    menubarsDB = DB.menubars
    menubtnsDB = DB.menubtns



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


    NeuronMenuBar:CreateBarsAndButtons()

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronMenuBar:OnEnable()


end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronMenuBar:OnDisable()

end


------------------------------------------------------------------------------


-------------------------------------------------------------------------------


function NeuronMenuBar:CreateBarsAndButtons()


    if (DB.menubarFirstRun) then
        local bar = NEURON.NeuronBar:CreateNewBar("menu", 1, true)
        local object

        for i=1,#menuElements do
            object = NEURON.NeuronButton:CreateNewObject("menu", i)
            NEURON.NeuronBar:AddObjectToList(bar, object)
        end

        DB.menubarFirstRun = false

    else

        for id,data in pairs(menubarsDB) do
            if (data ~= nil) then
                NEURON.NeuronBar:CreateNewBar("menu", id)
            end
        end

        for id,data in pairs(menubtnsDB) do
            if (data ~= nil) then
                NEURON.NeuronButton:CreateNewObject("menu", id)
            end
        end
    end
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

end

function NeuronMenuBar:GetSkinned(button)
    --empty
end

function NeuronMenuBar:SetType(button, save)
    if (menuElements[button.id]) then

        button:SetWidth(menuElements[button.id]:GetWidth()-2)
        --button:SetHeight(menuElements[button.id]:GetHeight()-2) --this is fixed in BfA and should be reenabled
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