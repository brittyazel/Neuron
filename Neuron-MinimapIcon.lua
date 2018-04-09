--Neuron , a World of Warcraft® user interface addon.

local NEURON = Neuron
local GDB

NEURON.NeuronMinimapIcon = NEURON:NewModule("NeuronMinimapIcon")
local NeuronMinimapIcon = NEURON.NeuronMinimapIcon

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local neuronIconLDB

local icon


-------------------------------------------------------------------------
--------------------Start of Functions-----------------------------------
-------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronMinimapIcon:OnInitialize()

    GDB = NeuronGDB

    neuronIconLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Neuron", {
        type = "launcher",
        text = "Neuron",
        icon = "Interface\\AddOns\\Neuron\\Images\\static_icon",
        OnClick = function(frame, button) self:OnClickHandler(frame, button) end,
        OnTooltipShow = function(tooltip) self:TooltipHandler(tooltip) end,
    })

    icon = LibStub("LibDBIcon-1.0")
    icon:Register("Neuron", neuronIconLDB, GDB.NeuronOrb)

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronMinimapIcon:OnEnable()
end

--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronMinimapIcon:OnDisable()

end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function NeuronMinimapIcon:OnClickHandler(frame, button)

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

function NeuronMinimapIcon:TooltipHandler(tooltip)

    tooltip:SetText("Neuron", 1, 1, 1)
    tooltip:AddLine(L["Left-Click to Configure Bars"])
    tooltip:AddLine(L["Right-Click to Configure Buttons"])
    tooltip:AddLine(L["Shift + Left-Click to Toggle Keybind Mode"])
    tooltip:AddLine(L["Shift + Right-Click to Toggle the Interface Menu"])

    tooltip:Show()

end

function NeuronMinimapIcon:ToggleIcon()

    if GDB.NeuronIcon.hide == false then
        icon:Hide("Neuron")
        GDB.NeuronIcon.hide = true
    elseif GDB.NeuronIcon.hide == true then
        icon:Show("Neuron")
        GDB.NeuronIcon.hide = false
    end

end