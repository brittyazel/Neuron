--Neuron Menu Bar, a World of Warcraft® user interface addon.

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------

local DB

Neuron.NeuronMenuBar = Neuron:NewModule("MenuBar", "AceHook-3.0")
local NeuronMenuBar = Neuron.NeuronMenuBar

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


-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronMenuBar:OnInitialize()

    DB = Neuron.db.profile

    Neuron:RegisterBarClass("menu", "MenuBar", L["Menu Bar"], "Menu Button", DB.menubar, Neuron.NeuronMenuBar, Neuron.MENUBTN, 11)

    Neuron:RegisterGUIOptions("menu", {
        AUTOHIDE = true,
        SHOWGRID = false,
        SPELLGLOW = false,
        SNAPTO = true,
        MULTISPEC = false,
        HIDDEN = true,
        LOCKBAR = false,
        TOOLTIPS = true },
            false, false)

    if DB.blizzbar == false then
        NeuronMenuBar:CreateBarsAndButtons()
    end
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


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


function NeuronMenuBar:CreateBarsAndButtons()


    if (DB.menubarFirstRun) then

        for id, defaults in ipairs(defaultBarOptions) do

            local bar = Neuron.NeuronBar:CreateNewBar("menu", id, true) --this calls the bar constructor

            for	k,v in pairs(defaults) do
                bar.data[k] = v
            end

            local object

            for i=1,11 do
                object = Neuron:CreateNewObject("menu", i, true)
                bar:AddObjectToList(object)
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
                Neuron:CreateNewObject("menu", id)
            end
        end
    end
end