--Neuron Bag Bar, a World of Warcraft® user interface addon.
local NEURON = Neuron
local  DB

NEURON.NeuronBagBar = NEURON:NewModule("BagBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronBagBar = NEURON.NeuronBagBar

local BAGBTN = setmetatable({}, {__index = CreateFrame("CheckButton")})

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local SKIN = LibStub("Masque", true)


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

local bagElements = {}

local configData = {
    stored = false,
}

-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronBagBar:OnInitialize()

    DB = NEURON.db.profile

    bagElements[5] = MainMenuBarBackpackButton
    bagElements[4] = CharacterBag0Slot
    bagElements[3] = CharacterBag1Slot
    bagElements[2] = CharacterBag2Slot
    bagElements[1] = CharacterBag3Slot


    ----------------------------------------------------------------
    BAGBTN.SetData = NeuronBagBar.SetData
    BAGBTN.LoadData = NeuronBagBar.LoadData
    BAGBTN.SaveData = NeuronBagBar.SaveData
    BAGBTN.SetAux = NeuronBagBar.SetAux
    BAGBTN.LoadAux = NeuronBagBar.LoadAux
    BAGBTN.SetObjectVisibility = NeuronBagBar.SetObjectVisibility
    BAGBTN.SetDefaults = NeuronBagBar.SetDefaults
    BAGBTN.GetDefaults = NeuronBagBar.GetDefaults
    BAGBTN.SetType = NeuronBagBar.SetType
    BAGBTN.GetSkinned = NeuronBagBar.GetSkinned
    BAGBTN.SetSkinned = NeuronBagBar.SetSkinned
    ----------------------------------------------------------------


    NEURON:RegisterBarClass("bag", "BagBar", L["Bag Bar"], "Bag Button", DB.bagbar, NeuronBagBar, DB.bagbtn, "CheckButton", "NeuronAnchorButtonTemplate", { __index = BAGBTN }, #bagElements, true)


    NEURON:RegisterGUIOptions("bag", { AUTOHIDE = true, SHOWGRID = false, SPELLGLOW = false, SNAPTO = true, MULTISPEC = false, HIDDEN = true, LOCKBAR = false, TOOLTIPS = true, }, false, false)

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

            local bar = NEURON.NeuronBar:CreateNewBar("bag", id, true) --this calls the bar constructor

            for	k,v in pairs(defaults) do
                bar.data[k] = v
            end

            local object

            for i=1,#bagElements do
                object = NEURON.NeuronButton:CreateNewObject("bag", i, true)
                NEURON.NeuronBar:AddObjectToList(bar, object)
            end

        end

        DB.bagbarFirstRun = false

    else

        for id,data in pairs(DB.bagbar) do
            if (data ~= nil) then
                NEURON.NeuronBar:CreateNewBar("bag", id)
            end
        end

        for id,data in pairs(DB.bagbtn) do
            if (data ~= nil) then
                NEURON.NeuronButton:CreateNewObject("bag", id)
            end
        end
    end
end


function NeuronBagBar:SetSkinned(button)

    if (SKIN) then

        local bar = button.bar

        if (bar) then

            local btnData = {
                Icon = button.icontexture,
                Normal = button.normaltexture,
                Count = button.count,
            }

            SKIN:Group("Neuron", bar.data.name):AddButton(button, btnData)

        end
    end

end


function NeuronBagBar:GetSkinned(button)
    -- empty
end


function NeuronBagBar:SetData(button, bar)

    if (bar) then

        button.bar = bar

        button:SetFrameStrata(bar.data.objectStrata)
        button:SetScale(bar.data.scale)

    end

    button:SetFrameLevel(4)
end

function NeuronBagBar:SaveData(button)

    -- empty

end

function NeuronBagBar:LoadData(button, spec, state)

    local id = button.id

    button.DB = DB.bagbtn

    if (button.DB) then

        if (not button.DB[id]) then
            button.DB[id] = {}
        end

        if (not button.DB[id].config) then
            button.DB[id].config = CopyTable(configData)
        end

        if (not button.DB[id].data) then
            button.DB[id].data = {}
        end

        button.config = button.DB [id].config

        button.data = button.DB[id].data
    end
end

function NeuronBagBar:SetObjectVisibility(button, show, hide)

    --empty

end

function NeuronBagBar:SetAux(button)

    -- empty

end

function NeuronBagBar:LoadAux(button)

    ---hide the color border around these buttons
    --C_Timer.NewTimer(1, function() button.element.IconBorder:Hide() end)


end

function NeuronBagBar:SetDefaults(button)

    -- empty

end

function NeuronBagBar:GetDefaults(button)

    --empty

end

function NeuronBagBar:SetType(button, save)

    if (bagElements[button.id]) then

		if button.id == 5 then --this corrects for some large ass margins on the main backpack button
			button:SetWidth(bagElements[button.id]:GetWidth()-5)
			button:SetHeight(bagElements[button.id]:GetHeight()-5)
		else
			button:SetWidth(bagElements[button.id]:GetWidth()+3)
			button:SetHeight(bagElements[button.id]:GetHeight()+3)
		end

		button:SetHitRectInsets(button:GetWidth()/2, button:GetWidth()/2, button:GetHeight()/2, button:GetHeight()/2)

        button.element = bagElements[button.id]

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

		button:SetSkinned(button)
	end
end

