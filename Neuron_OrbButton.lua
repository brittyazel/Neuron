--Neuron , a World of Warcraft® user interface addon.

local NEURON = Neuron
local GDB

NEURON.NeuronMinimapOrb = NEURON:NewModule("NeuronMinimapOrb")
local NeuronMinimapOrb = NEURON.NeuronMinimapOrb

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local neuronOrbLDB

local orb


-------------------------------------------------------------------------
--------------------Start of Functions-----------------------------------
-------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronMinimapOrb:OnInitialize()

    GDB = NeuronGDB

    neuronOrbLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Neuron", {
        type = "launcher",
        text = "Neuron",
        icon = "Interface\\AddOns\\Neuron\\Images\\static_icon",
        OnClick = function(frame, button) self:OnClickHandler(frame, button) end,
        OnTooltipShow = function(tooltip) self:TooltipHandler(tooltip) end,
    })

    orb = LibStub("LibDBIcon-1.0")
    orb:Register("Neuron", neuronOrbLDB, GDB.NeuronOrb)

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronMinimapOrb:OnEnable()
end

--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronMinimapOrb:OnDisable()

end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function NeuronMinimapOrb:OnClickHandler(frame, button)

    if (InCombatLockdown()) then
        return
    end

    PlaySound(SOUNDKIT.IG_CHAT_SCROLL_DOWN)

    if (button == "LeftButton" and not IsShiftKeyDown()) then
        NEURON:ToggleBars()
    elseif (button == "RightButton" and not IsShiftKeyDown()) then
        NEURON:ToggleEditFrames()
    elseif (button == "LeftButton" and IsShiftKeyDown()) then
        NEURON:ToggleBindings()
    elseif (button == "RightButton" and IsShiftKeyDown()) then
        NEURON:ToggleMainMenu()
    end

end

function NeuronMinimapOrb:TooltipHandler(tooltip)

    tooltip:SetText("Neuron", 1, 1, 1)
    tooltip:AddLine(L["Left-Click to Configure Bars"])
    tooltip:AddLine(L["Right-Click to Configure Buttons"])
    tooltip:AddLine(L["Shift + Left-Click to Toggle Keybind Mode"])
    tooltip:AddLine(L["Shift + Right-Click to Toggle the Interface Menu"])

    tooltip:Show()

end

function NeuronMinimapOrb:ToggleIcon()

    if GDB.NeuronOrb.hide == false then
        orb:Hide("Neuron")
        GDB.NeuronOrb.hide = true
    elseif GDB.NeuronOrb.hide == true then
        orb:Show("Neuron")
        GDB.NeuronOrb.hide = false
    end

end