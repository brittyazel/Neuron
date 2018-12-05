--Neuron Status Bars, a World of Warcraft® user interface addon.

local DB

Neuron.NeuronStatusBar = Neuron:NewModule("StatusBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronStatusBar = Neuron.NeuronStatusBar

local EDITIndex = Neuron.EDITIndex

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")



local defaultBarOptions = {

    [1] = {
        showGrid = true,
        snapTo = false,
        snapToFrame = false,
        snapToPoint = false,
        point = "BOTTOM",
        x = 0,
        y = 385,
    },

    [2] = {
        showGrid = true,
        snapTo = false,
        snapToFrame = false,
        snapToPoint = false,
        point = "BOTTOM",
        x = 0,
        y = 24,
    },

    [3] = {
        showGrid = true,
        snapTo = false,
        snapToFrame = false,
        snapToPoint = false,
        point = "BOTTOM",
        x = 0,
        y = 7,
    },

    [4] = {
        showGrid = true,
        columns = 1,
        snapTo = false,
        snapToFrame = false,
        snapToPoint = false,
        point = "TOP",
        x = 0,
        y = -123,
    },
}





-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronStatusBar:OnInitialize()

    DB = Neuron.db.profile

    Neuron:RegisterBarClass("status", "StatusBarGroup", L["Status Bar"], "Status Bar", DB.statusbar, Neuron.NeuronStatusBar, Neuron.STATUSBTN, 20)

    Neuron:RegisterGUIOptions("status", {
        AUTOHIDE = true,
        SNAPTO = true,
        HIDDEN = true,
        TOOLTIPS = true },
            false, false)

    NeuronStatusBar:CreateBarsAndButtons()

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronStatusBar:OnEnable()

    NeuronStatusBar:DisableDefault()

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronStatusBar:OnDisable()

end


------------------------------------------------------------------------------

-------------------------------------------------------------------------------

function NeuronStatusBar:CreateBarsAndButtons()


    if (DB.statusbarFirstRun) then

        for id, defaults in ipairs(defaultBarOptions) do

            local bar = Neuron.NeuronBar:CreateNewBar("status", id, true) --this calls the bar constructor

            for	k,v in pairs(defaults) do
                bar.data[k] = v
            end

            local object

            object = Neuron:CreateNewObject("status", id, true)
            Neuron.NeuronBar:AddObjectToList(bar, object)
        end

        DB.statusbarFirstRun = false

    else

        for id,data in pairs(DB.statusbar) do
            if (data ~= nil) then
                Neuron.NeuronBar:CreateNewBar("status", id)
            end
        end

        for id,data in pairs(DB.statusbtn) do
            if (data ~= nil) then
                Neuron:CreateNewObject("status", id)
            end
        end
    end

end


function NeuronStatusBar:DisableDefault()

    local disableDefaultCast = false
    local disableDefaultMirror = false

    for i,v in ipairs(Neuron.NeuronStatusBar) do

        if (v["bar"]) then --only disable if a specific button has an associated bar
            if v.config.sbType == "cast" then
                disableDefaultCast = true
            elseif v.config.sbType == "mirror" then
                disableDefaultMirror = true
            end
        end
    end


    if disableDefaultCast then
        CastingBarFrame:UnregisterAllEvents()
        CastingBarFrame:Hide()
    end

    if disableDefaultMirror then
        UIParent:UnregisterEvent("MIRROR_TIMER_START")
        MirrorTimer1:UnregisterAllEvents()
        MirrorTimer2:UnregisterAllEvents()
        MirrorTimer3:UnregisterAllEvents()
    end

end



