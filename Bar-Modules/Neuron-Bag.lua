--Neuron Bag Bar, a World of Warcraft® user interface addon.

local  DB

Neuron.NeuronBagBar = Neuron:NewModule("BagBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronBagBar = Neuron.NeuronBagBar

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")


local defaultBarOptions = {
    [1] = {
        padH = 0,
        scale = 1.1,
        snapTo = false,
        snapToFrame = false,
        snapToPoint = false,
        point = "BOTTOMRIGHT",
        x = -102,
        y = 24,
    }
}


-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronBagBar:OnInitialize()

    DB = Neuron.db.profile

    Neuron:RegisterBarClass("bag", "BagBar", L["Bag Bar"], "Bag Button", DB.bagbar, Neuron.NeuronBagBar, Neuron.BAGBTN,5)

    Neuron:RegisterGUIOptions("bag", {
        AUTOHIDE = true,
        SHOWGRID = false,
        SPELLGLOW = false,
        SNAPTO = true,
        MULTISPEC = false,
        HIDDEN = true,
        LOCKBAR = false,
        TOOLTIPS = true, },
            false, false)

    if DB.blizzbar == false then
        NeuronBagBar:CreateBarsAndButtons()

        ---hide the weird color border around bag bars
        CharacterBag0Slot.IconBorder:Hide()
        CharacterBag1Slot.IconBorder:Hide()
        CharacterBag2Slot.IconBorder:Hide()
        CharacterBag3Slot.IconBorder:Hide()

        ---overwrite the Show function with a null function because it keeps coming back and won't stay hidden
        NeuronBagBar:RawHook(CharacterBag0Slot.IconBorder, "Show", function() end, true)
        NeuronBagBar:RawHook(CharacterBag1Slot.IconBorder, "Show", function() end, true)
        NeuronBagBar:RawHook(CharacterBag2Slot.IconBorder, "Show", function() end, true)
        NeuronBagBar:RawHook(CharacterBag3Slot.IconBorder, "Show", function() end, true)
    end

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronBagBar:OnEnable()


end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronBagBar:OnDisable()

end


------------------------------------------------------------------------------


-------------------------------------------------------------------------------

function NeuronBagBar:CreateBarsAndButtons()

    if (DB.bagbarFirstRun) then

        for id, defaults in ipairs(defaultBarOptions) do

            local bar = Neuron.NeuronBar:CreateNewBar("bag", id, true) --this calls the bar constructor

            for	k,v in pairs(defaults) do
                bar.data[k] = v
            end

            local object

            for i=1,5 do
                object = Neuron:CreateNewObject("bag", i, true)
                Neuron.NeuronBar:AddObjectToList(bar, object)
            end

        end

        DB.bagbarFirstRun = false

    else

        for id,data in pairs(DB.bagbar) do
            if (data ~= nil) then
                Neuron.NeuronBar:CreateNewBar("bag", id)
            end
        end

        for id,data in pairs(DB.bagbtn) do
            if (data ~= nil) then
                Neuron:CreateNewObject("bag", id)
            end
        end
    end
end

