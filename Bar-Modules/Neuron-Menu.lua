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

    --[[if (DB.menubarFirstRun) then
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
    end]]

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



function NeuronMenuBar:SetData(button, bar)
    --empty
end

function NeuronMenuBar:SaveData(button)
    -- empty
end

function NeuronMenuBar:LoadData(button, spec, state)
    --empty
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
    --empty
end