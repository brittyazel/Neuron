--Neuron Status Bars, a World of Warcraft® user interface addon.

local DB

Neuron.NeuronStatusBar = Neuron:NewModule("StatusBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronStatusBar = Neuron.NeuronStatusBar

local EDITIndex = Neuron.EDITIndex

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")


local BarTextures = {
    [1] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Default_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Default_2", L["Default"] },
    [2] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Contrast_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Contrast_2", L["Contrast"] },
    [3] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Carpaint_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Carpaint_2", L["Carpaint"] },
    [4] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Gel_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Gel_2", L["Gel"] },
    [5] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Glassed_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Glassed_2", L["Glassed"] },
    [6] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Soft_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Soft_2", L["Soft"] },
    [7] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Velvet_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Velvet_3", L["Velvet"] },
}
Neuron.BarTextures = BarTextures


local BarBorders = {
    [1] = { L["Tooltip"], "Interface\\Tooltips\\UI-Tooltip-Border", 2, 2, 3, 3, 12, 12, -2, 3, 2, -3 },
    [2] = { L["Slider"], "Interface\\Buttons\\UI-SliderBar-Border", 3, 3, 6, 6, 8, 8 , -1, 5, 1, -5 },
    [3] = { L["Dialog"], "Interface\\AddOns\\Neuron\\Images\\Border_Dialog", 11, 12, 12, 11, 26, 26, -7, 7, 7, -7 },
    [4] = { L["None"], "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}
Neuron.BarBorders = BarBorders

local BarOrientations = {
    [1] = L["Horizontal"],
    [2] = L["Vertical"],
}
Neuron.BarOrientations = BarOrientations


local BarUnits = {
    [1] = "-none-",
    [2] = "player",
    [3] = "pet",
    [4] = "target",
    [5] = "targettarget",
    [6] = "focus",
    [7] = "mouseover",
    [8] = "party1",
    [9] = "party2",
    [10] = "party3",
    [11] = "party4",
}
Neuron.BarUnits = BarUnits

local BarRepColors = {
    [0] = { l="a_Unknown", r=0.5, g=0.5, b=0.5, a=1.0 },
    [1] = { l="b_Hated", r=0.6, g=0.1, b=0.1, a=1.0 },
    [2] = { l="c_Hostile", r=0.7, g=0.2, b=0.2, a=1.0 },
    [3] = { l="d_Unfriendly", r=0.75, g=0.27, b=0, a=1.0 },
    [4] = { l="e_Neutral", r=0.9, g=0.7, b=0, a=1.0 },
    [5] = { l="f_Friendly", r=0.5, g=0.6, b=0.1, a=1.0 },
    [6] = { l="g_Honored", r=0.1, g=0.5, b=0.20, a=1.0 },
    [7] = { l="h_Revered", r=0.0, g=0.39, b=0.88, a=1.0 },
    [8] = { l="i_Exalted", r=0.58, g=0.0, b=0.55, a=1.0 },
    [9] = { l="i_Exalted2", r=0.58, g=0.0, b=0.55, a=1.0 },
    [10] = { l="i_Exalted3", r=0.58, g=0.0, b=0.55, a=1.0 },
    [11] = { l="p_Paragon", r=1, g=0.5, b=0, a=1.0 },
}

--FACTION_BAR_COLORS = BarRepColors

local CastWatch, RepWatch, MirrorWatch, MirrorBars, Session = {}, {}, {}, {}, {}


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


local configDefaults = {
    [1] = { sbType = "cast", cIndex = 1, lIndex = 2, rIndex = 3, showIcon = true},
    [2] = { sbType = "xp", cIndex = 2, lIndex = 6, rIndex = 4, mIndex = 3, width = 450},
    [3] = { sbType = "rep", cIndex = 3, lIndex = 2, rIndex = 4, mIndex = 6, width = 450},
    [4] = { sbType = "mirror", cIndex = 1, lIndex = 2, rIndex = 3},
}


local sbStrings = {
    cast = {
        [1] = { L["None"], function(sb) return "" end },
        [2] = { L["Spell"], function(sb) if (CastWatch[sb.unit]) then return CastWatch[sb.unit].spell end end },
        [3] = { L["Timer"], function(sb) if (CastWatch[sb.unit]) then return CastWatch[sb.unit].timer end end },
    },
    xp = {
        [1] = { L["None"], function(sb) return "" end },
        [2] = { L["Current/Next"], function(sb) if (sb.XPWatch) then return sb.XPWatch.current end end },
        [3] = { L["Rested Levels"], function(sb) if (sb.XPWatch) then return sb.XPWatch.rested end end },
        [4] = { L["Percent"], function(sb) if (sb.XPWatch) then return sb.XPWatch.percent end end },
        [5] = { L["Bubbles"], function(sb) if (sb.XPWatch) then return sb.XPWatch.bubbles end end },
        [6] = { L["Current Level/Rank"], function(sb) if (sb.XPWatch) then return sb.XPWatch.rank end end },
    },
    rep = {
        [1] = { L["None"], function(sb) return "" end },
        [2] = { L["Faction"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].rep end end }, ---TODO:should probably do the same as above here, just in case people have more than 1 rep bar
        [3] = { L["Current/Next"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].current end end },
        [4] = { L["Percent"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].percent end end },
        [5] = { L["Bubbles"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].bubbles end end },
        [6] = { L["Current Level/Rank"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].rank end end },
    },
    mirror = {
        [1] = { L["None"], function(sb) return "" end },
        [2] = { L["Type"], function(sb) if (MirrorWatch[sb.mirror]) then return MirrorWatch[sb.mirror].label end end },
        [3] = { L["Timer"], function(sb) if (MirrorWatch[sb.mirror]) then return MirrorWatch[sb.mirror].timer end end },
    },
}
Neuron.sbStrings = sbStrings



--These factions return fID but have 8 levels instead of 6
local BrawlerGuildFactions = {
    [1419] = true, --Aliance
    [1374] = true, --Horde
}




---@class STATUS : BUTTON
local STATUS = setmetatable({}, { __index = Neuron.BUTTON })


-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronStatusBar:OnInitialize()

    DB = Neuron.db.profile


    Neuron:RegisterBarClass("status", "StatusBarGroup", L["Status Bar"], "Status Bar", DB.statusbar, NeuronStatusBar, DB.statusbtn, "Button", "NeuronStatusBarTemplate", { __index = STATUS }, 1000)

    Neuron:RegisterGUIOptions("status", { AUTOHIDE = true,
                                          SNAPTO = true,
                                          HIDDEN = true,
                                          TOOLTIPS = true }, false, false)

    NeuronStatusBar:CreateBarsAndButtons()

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronStatusBar:OnEnable()

    NeuronStatusBar:DisableDefault()

    NeuronStatusBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    NeuronStatusBar:RegisterEvent("UPDATE_FACTION")
    NeuronStatusBar:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    NeuronStatusBar:RegisterEvent("MIRROR_TIMER_START")
    NeuronStatusBar:RegisterEvent("MIRROR_TIMER_STOP")

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronStatusBar:OnDisable()

end


------------------------------------------------------------------------------

function NeuronStatusBar:PLAYER_ENTERING_WORLD()

    local timer, value, maxvalue, scale, paused, label

    for i=1,MIRRORTIMER_NUMTIMERS do

        timer, value, maxvalue, scale, paused, label = GetMirrorTimerInfo(i)

        if (timer ~= "UNKNOWN") then
            mbStart(timer, value, maxvalue, scale, paused, label)
        end
    end

end

function NeuronStatusBar:UPDATE_FACTION(eventName, ...)

    NeuronStatusBar:repstrings_Update(...)

end

function NeuronStatusBar:CHAT_MSG_COMBAT_FACTION_CHANGE(eventName, ...)

    NeuronStatusBar:repstrings_Update(...)

end

function NeuronStatusBar:MIRROR_TIMER_START(eventName, ...)

    NeuronStatusBar:mirrorbar_Start(...)

end

function NeuronStatusBar:MIRROR_TIMER_STOP(eventName, ...)

    NeuronStatusBar:mirrorbar_Stop(select(1,...))

end

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



function NeuronStatusBar:controlOnUpdate(frame, elapsed)

end

----------------------------------
--------XP Bar--------------------
----------------------------------

---TODO: right now we are using DB.statusbtn to assign settins ot the status buttons, but I think our indexes are bar specific
function NeuronStatusBar:xpstrings_Update(button) --handles updating all the strings for the play XP watch bar

    local parent = button.parent
    local id = parent.id --this is a really hacked together way of storing this info. We need the ID to identify this specific bar instance

    local thisBar = DB.statusbtn[id] --we are refrencing a specific bar instance out of a list. I'm not entirely sure why the points are the way they are but it works so whatever


    local currXP, nextXP, restedXP, percentXP, bubbles, rank

    --player xp option
    if (thisBar.curXPType == "player_xp") then

        currXP, nextXP, restedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()

        local playerLevel = UnitLevel("player")

        if (playerLevel == MAX_PLAYER_LEVEL) then
            currXP = nextXP
        end

        percentXP = (currXP/nextXP)*100;

        bubbles = tostring(math.floor(currXP/(nextXP/20))).." / 20 "..L["Bubbles"]
        percentXP = string.format("%.2f", (percentXP)).."%"


        if (restedXP) then
            restedXP = string.format("%.2f", (tostring(restedXP/nextXP))).." "..L["Levels"]
        else
            restedXP = "0".." "..L["Levels"]
        end

        rank = L["Level"].." "..tostring(playerLevel)

        --heart of azeroth option
    elseif(thisBar.curXPType == "azerite_xp") then

        local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()

        if(azeriteItemLocation) then

            currXP, nextXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)

            restedXP = "0".." "..L["Levels"]

            percentXP = (currXP/nextXP)*100
            bubbles = tostring(math.floor(percentXP/5)).." / 20 "..L["Bubbles"]
            rank = L["Level"] .. " " .. tostring(C_AzeriteItem.GetPowerLevel(azeriteItemLocation))
        else
            currXP = 0;
            nextXP = 0;
            percentXP = 0;
            restedXP = "0".." "..L["Levels"]
            bubbles = tostring(0).." / 20 "..L["Bubbles"]
            rank = tostring(0).." "..L["Points"]
        end

        percentXP = string.format("%.2f", percentXP).."%"; --format


        --honor points option
    elseif(thisBar.curXPType == "honor_points") then
        currXP = UnitHonor("player"); -- current value for level
        nextXP = UnitHonorMax("player"); -- max value for level
        restedXP = tostring(0).." "..L["Levels"]

        local level = UnitHonorLevel("player");

        percentXP = (currXP/nextXP)*100


        bubbles = tostring(math.floor(percentXP/5)).." / 20 "..L["Bubbles"];
        percentXP = string.format("%.2f", percentXP).."%"; --format


        rank = L["Level"] .. " " .. tostring(UnitHonorLevel("player"))

    end

    if (not button.XPWatch) then --make sure we make the table for us to store our data so we aren't trying to index a non existant table
        button.XPWatch = {}
    end

    button.XPWatch.current = BreakUpLargeNumbers(currXP).." / "..BreakUpLargeNumbers(nextXP)
    button.XPWatch.rested = restedXP
    button.XPWatch.percent = percentXP
    button.XPWatch.bubbles = bubbles
    button.XPWatch.rank = rank


    local isRested
    if(restedXP ~= "0") then
        isRested = true
    else
        isRested = false
    end

    return currXP, nextXP, isRested
end



function NeuronStatusBar:XPBar_OnEvent(button, event, ...)

    local parent = button.parent

    local id = parent.id --this is a really hacked together way of storing this info. We need the ID to identify this specific bar instance

    local thisBar = DB.statusbtn[id] --we are refrencing a specific button instance out of a list. I'm not entirely sure why the points are the way they are but it works so whatever

    if (not thisBar.curXPType) then
        thisBar.curXPType = "player_xp" --sets the default state of the XP bar to be player_xp
    end

    local currXP, nextXP, isRested
    local hasChanged = false;


    if(thisBar.curXPType == "player_xp" and (event=="PLAYER_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event=="UPDATE_EXHAUSTION" or event =="changed_curXPType")) then

        currXP, nextXP, isRested = NeuronStatusBar:xpstrings_Update(button)

        if (isRested) then
            button:SetStatusBarColor(button.restColor[1], button.restColor[2], button.restColor[3], button.restColor[4])
        else
            button:SetStatusBarColor(button.norestColor[1], button.norestColor[2], button.norestColor[3], button.norestColor[4])
        end

        hasChanged = true;
    end


    if(thisBar.curXPType == "azerite_xp" and (event =="AZERITE_ITEM_EXPERIENCE_CHANGED" or event =="PLAYER_ENTERING_WORLD" or event =="PLAYER_EQUIPMENT_CHANGED" or event =="changed_curXPType"))then

        currXP, nextXP = NeuronStatusBar:xpstrings_Update(button)

        button:SetStatusBarColor(1, 1, 0); --set to yellow?

        hasChanged = true;

    end

    if(thisBar.curXPType == "honor_points" and (event=="HONOR_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event =="changed_curXPType")) then

        currXP, nextXP = NeuronStatusBar:xpstrings_Update(button)

        button:SetStatusBarColor(1, .4, .4);

        hasChanged = true;
    end

    if (hasChanged == true) then
        button:SetMinMaxValues(0, 100) --these are for the bar itself, the progress it has from left to right
        button:SetValue((currXP/nextXP)*100)

        button.cText:SetText(button.cFunc(button))
        button.lText:SetText(button.lFunc(button))
        button.rText:SetText(button.rFunc(button))
        button.mText:SetText(button.mFunc(button))
    end

end



function NeuronStatusBar:switchCurXPType(parent, newXPType)
    local id = parent.id
    DB.statusbtn[id].curXPType = newXPType
    NeuronStatusBar:XPBar_OnEvent(parent.sb, "changed_curXPType")
end


function NeuronStatusBar:xpDropDown_Initialize(dropdown) -- initialize the dropdown menu for chosing to watch either XP, azerite XP, or Honor Points

    local parent = dropdown:GetParent()
    local id = parent.id

    if (parent) then

        local info = UIDropDownMenu_CreateInfo()

        info.arg1 = parent
        info.arg2 = "player_xp"
        info.text = L["Track Character XP"]
        info.func = NeuronStatusBar.switchCurXPType

        if (DB.statusbtn[id].curXPType == "player_xp") then
            info.checked = 1
        else
            info.checked = nil
        end

        UIDropDownMenu_AddButton(info)
        wipe(info)

        if(C_AzeriteItem.FindActiveAzeriteItem()) then --only show this button if they player has the Heart of Azeroth
            info.arg1 = parent
            info.arg2 = "azerite_xp"
            info.text = L["Track Azerite Power"]
            info.func = NeuronStatusBar.switchCurXPType

            if (DB.statusbtn[id].curXPType == "azerite_xp") then
                info.checked = 1
            else
                info.checked = nil
            end

            UIDropDownMenu_AddButton(info)
            wipe(info)
        end


        info.arg1 = parent
        info.arg2 = "honor_points"
        info.text = L["Track Honor Points"]
        info.func = NeuronStatusBar.switchCurXPType

        info.arg1 = parent
        info.arg2 = "honor_points"
        info.text = L["Track Honor Points"]
        info.func = NeuronStatusBar.switchCurXPType

        if (DB.statusbtn[id].curXPType == "honor_points") then
            info.checked = 1
        else
            info.checked = nil
        end

        UIDropDownMenu_AddButton(info)
        wipe(info)


    end
end


function NeuronStatusBar:XPBar_DropDown_OnLoad(button)
    UIDropDownMenu_Initialize(button.dropdown, function() NeuronStatusBar:xpDropDown_Initialize(button.dropdown) end, "MENU")
    button.dropdown_init = true
end





----------------------------------------------
----------------Rep Bar-----------------------
----------------------------------------------


--- Creates a table containing provided data
-- @param name, hasFriendStatus, standing, minrep, maxrep, value, colors
-- @return reptable:  Table containing provided data
function NeuronStatusBar:SetRepWatch(name, hasFriendStatus, standing, minrep, maxrep, value, colors)
    local reptable = {}
    reptable.rep = name
    reptable.rank = standing
    reptable.current = (value-minrep).." / "..(maxrep-minrep)
    reptable.percent = floor(((value-minrep)/(maxrep-minrep))*100).."%"
    reptable.bubbles = tostring(math.floor(((((value-minrep)/(maxrep-minrep))*100)/5))).." / 20 "..L["Bubbles"]
    reptable.rephour = "---"
    reptable.min = minrep
    reptable.max = maxrep
    reptable.value = value
    reptable.hex = string.format("%02x%02x%02x", colors.r*255, colors.g*255, colors.b*255)
    reptable.r = colors.r
    reptable.g = colors.g
    reptable.b = colors.b

    if hasFriendStatus then
        reptable.l = "z"..colors.l
    else
        reptable.l = colors.l
    end
    return reptable
end


function NeuronStatusBar:repstrings_Update(line)


    if (GetNumFactions() > 0) then
        wipe(RepWatch)

        for i=1, GetNumFactions() do
            local name, _, ID, min, max, value, _, _, isHeader, _, hasRep, _, _, factionID = GetFactionInfo(i)
            local fID, fRep, fMaxRep, fName, fText, fTexture, fTextLevel, fThreshold, nextFThreshold = GetFriendshipReputation(factionID)
            local colors, standing
            local hasFriendStatus = false

            if ID == 8 then
                min = 0
            end

            if ((not isHeader or hasRep) and not IsFactionInactive(i)) then
                if (fID and not BrawlerGuildFactions[fID]) then
                    colors = BarRepColors[ID+2]; standing = fTextLevel
                    hasFriendStatus = true
                elseif (fID and BrawlerGuildFactions[fID]) then
                    colors = BarRepColors[ID]; standing = fTextLevel
                    hasFriendStatus = true
                else
                    colors = BarRepColors[ID]; standing = (colors.l):gsub("^%a%p", "")
                end

                if (factionID and C_Reputation.IsFactionParagon(factionID)) then
                    local para_value, para_max, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID);
                    value = para_value % para_max;
                    max = para_max
                    if hasRewardPending then
                        name = name.." ("..L["Reward"]:upper()..")"
                    end
                    min = 0
                    colors = BarRepColors[11]
                end

                local repData = NeuronStatusBar:SetRepWatch(name, hasFriendStatus, standing, min, max, value, colors)
                RepWatch[i] = repData --set current reptable into growing RepWatch table

                if (((line and type(line)~= "boolean") and line:find(name)) or DB.AutoWatch == i) then --this line automatically assings the most recently updated repData to RepWatch[0], and the "auto" option assigns RepWatch[0] to be shown
                    RepWatch[0] = repData
                    DB.AutoWatch = i
                end
            end
        end
    end
end





function NeuronStatusBar:repbar_OnEvent(button, event,...)

    NeuronStatusBar:repstrings_Update(...)

    if (RepWatch[button.repID]) then
        button:SetStatusBarColor(RepWatch[button.repID].r,  RepWatch[button.repID].g, RepWatch[button.repID].b)
        button:SetMinMaxValues(RepWatch[button.repID].min, RepWatch[button.repID].max)
        button:SetValue(RepWatch[button.repID].value)
    else
        button:SetStatusBarColor(0.5,  0.5, 0.5)
        button:SetMinMaxValues(0, 1)
        button:SetValue(1)
    end

    button.cText:SetText(button.cFunc(button))
    button.lText:SetText(button.lFunc(button))
    button.rText:SetText(button.rFunc(button))
    button.mText:SetText(button.mFunc(button))
end


function NeuronStatusBar:repDropDown_Initialize(dropdown) --Initialize the dropdown menu for choosing a rep

    local parent = dropdown:GetParent()

    if (parent) then

        local info = UIDropDownMenu_CreateInfo()
        local checked, repLine, repIndex

        info.arg1 = parent
        info.arg2 = NeuronStatusBar.repbar_OnEvent
        info.text = L["Auto Select"]
        info.func = function(self, statusbar, func, checked) --statusbar is arg1, func is arg2
            local faction = sbStrings.rep[2][2](statusbar.sb)
            statusbar.data.repID = self.value
            statusbar.sb.repID = self.value
            func(self, statusbar.sb, nil, faction)
        end

        if (parent.data.repID == 0) then
            checked = 1
        else
            checked = nil
        end

        info.value = 0
        info.checked = checked

        UIDropDownMenu_AddButton(info)

        wipe(info)

        info.arg1 = nil
        info.arg2 = nil
        info.text = " "
        info.func = function() end
        info.value = nil
        info.checked = nil
        info.notClickable = true
        info.notCheckable = 1

        UIDropDownMenu_AddButton(info)

        wipe(info)

        local data = {}
        local order, ID, text, friends

        for k,v in pairs(RepWatch) do

            if (k > 0) then

                local percent = tonumber(v.percent:match("%d+"))

                if (percent < 10) then
                    percent = "0"..percent
                end

                tinsert(data, v.l..percent..";"..k..";".."|cff"..v.hex..v.rep.." - "..v.percent.."|r")
            end
        end

        table.sort(data)

        for k,v in ipairs(data) do

            order, ID, text = (";"):split(v)

            if (order:find("^z") and not friends) then

                info.arg1 = nil
                info.arg2 = nil
                info.text = " "
                info.func = function() end
                info.value = nil
                info.checked = nil
                info.notClickable = true
                info.notCheckable = 1

                UIDropDownMenu_AddButton(info)

                info.arg1 = nil
                info.arg2 = nil
                info.text = "Friends"
                info.func = function() end
                info.value = nil
                info.checked = nil
                info.notClickable = true
                info.notCheckable = 1
                info.leftPadding = 17

                UIDropDownMenu_AddButton(info)

                wipe(info)

                friends = true
            end

            ID = tonumber(ID)

            info.arg1 = parent
            info.arg2 = NeuronStatusBar.repbar_OnEvent
            info.text = text
            info.func = function(self, statusbar, func, checked)
                statusbar.data.repID = self.value
                statusbar.sb.repID = self.value
                func(self, statusbar.sb)
            end

            if (parent.data.repID == ID) then
                checked = 1
            else
                checked = nil
            end

            info.value = ID
            info.checked = checked
            info.notClickable = nil
            info.notCheckable = nil

            UIDropDownMenu_AddButton(info)

            wipe(info)
        end
    end
end


function NeuronStatusBar:RepBar_DropDown_OnLoad(button)
    UIDropDownMenu_Initialize(button.dropdown, function() NeuronStatusBar:repDropDown_Initialize(button.dropdown) end, "MENU")
    button.dropdown_init = true
end



----------------------------------------------------
-------------------Mirror Bar-----------------------
----------------------------------------------------


function NeuronStatusBar:mirrorbar_Start(button, value, maxvalue, scale, paused, label)


    if (not MirrorWatch[button]) then
        MirrorWatch[button] = { active = false, mbar = nil, label = "", timer = "" }
    end

    if (not MirrorWatch[button].active) then

        local mbar = tremove(MirrorBars, 1)

        if (mbar) then

            MirrorWatch[button].active = true
            MirrorWatch[button].mbar = mbar
            MirrorWatch[button].label = label

            mbar.sb.mirror = button
            mbar.sb.value = (value / 1000)
            mbar.sb.maxvalue = (maxvalue / 1000)
            mbar.sb.scale = scale

            if ( paused > 0 ) then
                mbar.sb.paused = 1
            else
                mbar.sb.paused = nil
            end

            local color = MirrorTimerColors[button]

            mbar.sb:SetMinMaxValues(0, (maxvalue / 1000))
            mbar.sb:SetValue(mbar.sb.value)
            mbar.sb:SetStatusBarColor(color.r, color.g, color.b)

            mbar.sb:SetAlpha(1)
            mbar.sb:Show()
        end
    end
end





function NeuronStatusBar:mirrorbar_Stop(button)


    if (MirrorWatch[button] and MirrorWatch[button].active) then

        local mbar = MirrorWatch[button].mbar

        if (mbar) then

            tinsert(MirrorBars, 1, mbar)

            MirrorWatch[button].active = false
            MirrorWatch[button].mbar = nil
            MirrorWatch[button].label = ""
            MirrorWatch[button].timer = ""

            mbar.sb.mirror = nil
        end
    end
end





function NeuronStatusBar:CastBar_FinishSpell(button)

    button.spark:Hide()
    button.barflash:SetAlpha(0.0)
    button.barflash:Show()
    button.flash = 1
    button.fadeOut = 1
    button.casting = nil
    button.channeling = nil
end





function NeuronStatusBar:CastBar_Reset(button)

    button.fadeOut = 1
    button.casting = nil
    button.channeling = nil
    button:SetStatusBarColor(button.castColor[1], button.castColor[2], button.castColor[3], button.castColor[4])

    if (not button.editmode) then
        button:Hide()
    end
end





function NeuronStatusBar:CastBar_OnEvent(button, event, ...)

    local parent, unit = button.parent, ...

    if (unit ~= button.unit) then
        return
    end

    if (not CastWatch[button.unit] ) then
        CastWatch[button.unit] = {}
    end

    if (event == "UNIT_SPELLCAST_START") then

        local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)

        if (not name or (not button.showTradeSkills and isTradeSkill)) then
            NeuronStatusBar:CastBar_Reset(button)
            return
        end

        button:SetStatusBarColor(button.castColor[1], button.castColor[2], button.castColor[3], button.castColor[4])

        if (button.spark) then
            button.spark:SetTexture("Interface\\AddOns\\Neuron\\Images\\CastingBar_Spark_"..button.orientation)
            button.spark:Show()
        end

        button.value = (GetTime()-(startTime/1000))
        button.maxValue = (endTime-startTime)/1000
        button:SetMinMaxValues(0, button.maxValue)
        button:SetValue(button.value)

        button.totalTime = button.maxValue - button:GetValue()

        CastWatch[button.unit].spell = text

        if (button.showIcon) then

            button.icon:SetTexture(texture)
            button.icon:Show()

            if (notInterruptible) then
                button.shield:Show()
            else
                button.shield:Hide()
            end

        else
            button.icon:Hide()
            button.shield:Hide()
        end

        button:SetAlpha(1.0)
        button.holdTime = 0
        button.casting = 1
        button.castID = castID
        button.channeling = nil
        button.fadeOut = nil

        button:Show()

    elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then

        button:SetStatusBarColor(button.successColor[1], button.successColor[2], button.successColor[3], button.successColor[4])

    elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then

        if ((button.casting and event == "UNIT_SPELLCAST_STOP") or
                (button.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP")) then

            button.spark:Hide()
            button.barflash:SetAlpha(0.0)
            button.barflash:Show()

            button:SetValue(button.maxValue)

            if (event == "UNIT_SPELLCAST_STOP") then
                button.casting = nil
            else
                button.channeling = nil
            end

            button.flash = 1
            button.fadeOut = 1
            button.holdTime = 0
        end

    elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") then

        if (button:IsShown() and (button.casting) and not button.fadeOut) then

            button:SetValue(button.maxValue)

            button:SetStatusBarColor(button.failColor[1], button.failColor[2], button.failColor[3], button.failColor[4])

            if (button.spark) then
                button.spark:Hide()
            end

            if (event == "UNIT_SPELLCAST_FAILED") then
                CastWatch[button.unit].spell = FAILED
            else
                CastWatch[button.unit].spell = INTERRUPTED
            end

            button.casting = nil
            button.channeling = nil
            button.fadeOut = 1
            button.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
        end

    elseif (event == "UNIT_SPELLCAST_DELAYED") then

        if (button:IsShown()) then

            local name, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)

            if (not name or (not button.showTradeSkills and isTradeSkill)) then
                NeuronStatusBar:CastBar_Reset(button)
                return
            end

            button.value = (GetTime()-(startTime/1000))
            button.maxValue = (endTime-startTime)/1000
            button:SetMinMaxValues(0, button.maxValue)

            if (not button.casting) then

                button:SetStatusBarColor(button.castColor[1], button.castColor[2], button.castColor[3], button.castColor[4])

                button.spark:Show()
                button.barflash:SetAlpha(0.0)
                button.barflash:Hide()

                button.casting = 1
                button.channeling = nil
                button.flash = 0
                button.fadeOut = 0
            end
        end

    elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then

        local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)

        if (not name or (not button.showTradeSkills and isTradeSkill)) then
            NeuronStatusBar:CastBar_Reset(button)
            return
        end

        button:SetStatusBarColor(button.channelColor[1], button.channelColor[2], button.channelColor[3], button.channelColor[4])

        button.value = ((endTime/1000)-GetTime())
        button.maxValue = (endTime - startTime) / 1000;
        button:SetMinMaxValues(0, button.maxValue);
        button:SetValue(button.value)

        CastWatch[button.unit].spell = text

        if (button.showIcon) then

            button.icon:SetTexture(texture)
            button.icon:Show()

            if (notInterruptible) then
                button.shield:Show()
            else
                button.shield:Hide()
            end

        else
            button.icon:Hide()
            button.shield:Hide()
        end

        if (button.spark) then
            button.spark:Hide()
        end

        button:SetAlpha(1.0)
        button.holdTime = 0
        button.casting = nil
        button.channeling = 1
        button.fadeOut = nil

        button:Show()

    elseif (event == "UNIT_SPELLCAST_CHANNEL_UPDATE") then

        if (button:IsShown()) then

            local name, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit)

            if (not name or (not button.showTradeSkills and isTradeSkill)) then
                NeuronStatusBar:CastBar_Reset(button)
                return
            end

            button.value = ((endTime/1000)-GetTime())
            button.maxValue = (endTime-startTime)/1000
            button:SetMinMaxValues(0, button.maxValue)
            button:SetValue(button.value)
        end

    elseif ( button.showShield and event == "UNIT_SPELLCAST_INTERRUPTIBLE" ) then

        button.shield:Hide()

    elseif ( button.showShield and event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" ) then

        button.shield:Show()

    else
        NeuronStatusBar:CastBar_Reset(button)
    end

    button.cText:SetText(button.cFunc(button))
    button.lText:SetText(button.lFunc(button))
    button.rText:SetText(button.rFunc(button))
    button.mText:SetText(button.mFunc(button))
end





function NeuronStatusBar:CastBar_OnUpdate(button, elapsed)

    local unit = button.unit
    local sparkPosition, alpha

    if (unit) then

        if (button.cbtimer.castInfo[unit]) then

            local displayName, numFormat = button.cbtimer.castInfo[unit][1], button.cbtimer.castInfo[unit][2]

            if (button.maxValue) then
                CastWatch[button.unit].timer = string.format(numFormat, button.value).."/"..format(numFormat, button.maxValue)
            else
                CastWatch[button.unit].timer = string.format(numFormat, button.value)
            end
        end

        if (button.casting) then

            button.value = button.value + elapsed

            if (button.value >= button.maxValue) then
                button:SetValue(button.maxValue)
                NeuronStatusBar:CastBar_FinishSpell(button); return
            end

            button:SetValue(button.value)

            button.barflash:Hide()

            if (button.orientation == 1) then

                sparkPosition = (button.value/button.maxValue)*button:GetWidth()

                if (sparkPosition < 0) then
                    sparkPosition = 0
                end

                button.spark:SetPoint("CENTER", button, "LEFT", sparkPosition, 0)

            else
                sparkPosition = (button.value / button.maxValue) * button:GetHeight()

                if ( sparkPosition < 0 ) then
                    sparkPosition = 0
                end

                button.spark:SetPoint("CENTER", button, "BOTTOM", 0, sparkPosition)
            end

        elseif (button.channeling) then

            button.value = button.value - elapsed

            if (button.value <= 0) then
                NeuronStatusBar:CastBar_FinishSpell(button)
                return
            end

            button:SetValue(button.value)

            button.barflash:Hide()

        elseif (GetTime() < button.holdTime) then

            return

        elseif (button.flash) then

            alpha = button.barflash:GetAlpha() + CASTING_BAR_FLASH_STEP or 0

            if (alpha < 1) then
                button.barflash:SetAlpha(alpha)
            else
                button.barflash:SetAlpha(1.0)
                button.flash = nil
            end

        elseif (button.fadeOut and not button.editmode) then

            alpha = button:GetAlpha() - CASTING_BAR_ALPHA_STEP

            if (alpha > 0) then
                button:SetAlpha(alpha)
            else
                NeuronStatusBar:CastBar_Reset(button)
            end
        end
    end

    button.cText:SetText(button.cFunc(button))
    button.lText:SetText(button.lFunc(button))
    button.rText:SetText(button.rFunc(button))
    button.mText:SetText(button.mFunc(button))
end





function NeuronStatusBar:CastBarTimer_OnEvent(button, event, ...)

    local unit = select(1, ...)

    if (unit) then

        if (event == "UNIT_SPELLCAST_START") then

            local _, text = UnitCastingInfo(unit)

            if (not button.castInfo[unit]) then button.castInfo[unit] = {} end
            button.castInfo[unit][1] = text
            button.castInfo[unit][2] = "%0.1f"

        elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then

            local _, text = UnitChannelInfo(unit)

            if (not button.castInfo[unit]) then button.castInfo[unit] = {} end
            button.castInfo[unit][1] = text
            button.castInfo[unit][2] = "%0.1f"
        end
    end
end




function NeuronStatusBar:MirrorBar_OnUpdate(button, elapsed)

    if (button.mirror) then

        button.value = GetMirrorTimerProgress(button.mirror)/1000


        if (button.value > button.maxvalue) then

            button.alpha = button:GetAlpha() - CASTING_BAR_ALPHA_STEP

            if (button.alpha > 0) then
                button:SetAlpha(button.alpha)
            else
                button:Hide()
            end

        else

            button:SetValue(button.value)

            if (button.value >= 60) then
                button.value = string.format("%0.1f", button.value/60)
                button.value = button.value.."m"
            else
                button.value = string.format("%0.0f", button.value)
                button.value = button.value.."s"
            end

            MirrorWatch[button.mirror].timer = button.value

        end

    elseif (not button.editmode) then

        button.alpha = button:GetAlpha() - CASTING_BAR_ALPHA_STEP

        if (button.alpha > 0) then
            button:SetAlpha(button.alpha)
        else
            button:Hide()
        end
    end

    button.cText:SetText(button.cFunc(button))
    button.lText:SetText(button.lFunc(button))
    button.rText:SetText(button.rFunc(button))
    button.mText:SetText(button.mFunc(button))
end




function NeuronStatusBar:SetBorder(button, config, bordercolor)

    button.border:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                                edgeFile = BarBorders[config.border][2],
                                tile = true,
                                tileSize = BarBorders[config.border][7],
                                edgeSize = BarBorders[config.border][8],
                                insets = { left = BarBorders[config.border][3],
                                           right = BarBorders[config.border][4],
                                           top = BarBorders[config.border][5],
                                           bottom = BarBorders[config.border][6]
                                }
    })

    button.border:SetPoint("TOPLEFT", BarBorders[config.border][9], BarBorders[config.border][10])
    button.border:SetPoint("BOTTOMRIGHT", BarBorders[config.border][11], BarBorders[config.border][12])

    button.border:SetBackdropColor(0, 0, 0, 0)
    button.border:SetBackdropBorderColor(bordercolor[1], bordercolor[2], bordercolor[3], 1)
    button.border:SetFrameLevel(button:GetFrameLevel()+1)

    button.bg:SetBackdropColor(0, 0, 0, 1)
    button.bg:SetBackdropBorderColor(0, 0, 0, 0)
    button.bg:SetFrameLevel(0)

    if (button.barflash) then
        button.barflash:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                                      edgeFile = BarBorders[config.border][2],
                                      tile = true,
                                      tileSize = BarBorders[config.border][7],
                                      edgeSize = BarBorders[config.border][8],
                                      insets = { left = BarBorders[config.border][3],
                                                 right = BarBorders[config.border][4],
                                                 top = BarBorders[config.border][5],
                                                 bottom = BarBorders[config.border][6]
                                      }
        })
    end
end




function NeuronStatusBar:OnClick(button, mousebutton, down)

    if (mousebutton == "RightButton") then
        if (button.config.sbType == "xp" and not button.dropdown_init) then
            NeuronStatusBar:XPBar_DropDown_OnLoad(button)
        elseif(button.config.sbType == "rep" and not button.dropdown_init) then
            NeuronStatusBar:RepBar_DropDown_OnLoad(button)
        end


        if (DropDownList1:IsVisible()) then
            DropDownList1:Hide()
        else
            NeuronStatusBar:repstrings_Update()

            ToggleDropDownMenu(1, nil, button.dropdown, button, 0, 0)

            DropDownList1:ClearAllPoints()
            DropDownList1:SetPoint("LEFT", button, "RIGHT", 3, 0)
            DropDownList1:SetClampedToScreen(true)

            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end
    end
end




function NeuronStatusBar:OnEnter(button)

    if (button.config.mIndex > 1) then
        button.sb.cText:Hide()
        button.sb.lText:Hide()
        button.sb.rText:Hide()
        button.sb.mText:Show()
        button.sb.mText:SetText(button.sb.mFunc(button.sb))
    end

    if (button.config.tIndex > 1) then

        if (button.bar) then

            if (button.bar.data.tooltipsCombat and InCombatLockdown()) then
                return
            end

            if (button.bar.data.tooltips) then

                if (button.bar.data.tooltipsEnhanced) then
                    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                else
                    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                end

                GameTooltip:SetText(button.sb.tFunc(button.sb) or "", button.tColor[1] or 1, button.tColor[2] or 1, button.tColor[3] or 1, button.tColor[4] or 1)
                GameTooltip:Show()
            end
        end
    end
end




function NeuronStatusBar:OnLeave(button)

    if (button.config.mIndex > 1) then
        button.sb.cText:Show()
        button.sb.lText:Show()
        button.sb.rText:Show()
        button.sb.mText:Hide()
        button.sb.cText:SetText(button.sb.cFunc(button.sb))
        button.sb.lText:SetText(button.sb.lFunc(button.sb))
        button.sb.rText:SetText(button.sb.rFunc(button.sb))
    end

    if (button.config.tIndex > 1) then
        GameTooltip:Hide()
    end
end




function NeuronStatusBar:UpdateWidth(button, command, gui, query, skipupdate)

    if (query) then
        return button.config.width
    end

    local width = tonumber(command)

    if (width and width >= 10) then

        button.config.width = width

        button:SetWidth(button.config.width)

        Neuron.NeuronBar:SetObjectLoc(button.bar)

        Neuron.NeuronBar:SetPerimeter(button.bar)

        Neuron.NeuronBar:SetSize(button.bar)

        if (not skipupdate) then
            Neuron.NeuronGUI:Status_UpdateEditor()
            Neuron.NeuronBar:Update(button.bar)
        end
    end
end




function NeuronStatusBar:UpdateHeight(button, command, gui, query, skipupdate)

    if (query) then
        return button.config.height
    end

    local height = tonumber(command)

    if (height and height >= 4) then

        button.config.height = height

        button:SetHeight(button.config.height)

        Neuron.NeuronBar:SetObjectLoc(button.bar)

        Neuron.NeuronBar:SetPerimeter(button.bar)

        Neuron.NeuronBar:SetSize(button.bar)

        if (not skipupdate) then
            Neuron.NeuronGUI:Status_UpdateEditor()
            Neuron.NeuronBar:Update(button.bar)
        end
    end
end




function NeuronStatusBar:UpdateTexture(button, command, gui, query)

    if (query) then
        return BarTextures[button.config.texture][3]
    end

    local index = tonumber(command)

    if (index and BarTextures[index]) then

        button.config.texture = index

        button.sb:SetStatusBarTexture(BarTextures[button.config.texture][button.config.orientation])
        button.fbframe.feedback:SetStatusBarTexture(BarTextures[button.config.texture][button.config.orientation])

        if (not skipupdate) then
            Neuron.NeuronGUI:Status_UpdateEditor()
        end

    end

end




function NeuronStatusBar:UpdateBorder(button, command, gui, query)

    if (query) then
        return BarBorders[button.config.border][1]
    end

    local index = tonumber(command)

    if (index and BarBorders[index]) then

        button.config.border = index

        NeuronStatusBar:SetBorder(button.sb, button.config, button.bordercolor)
        NeuronStatusBar:SetBorder(button.fbframe.feedback, button.config, button.bordercolor)

        if (not skipupdate) then
            Neuron.NeuronGUI:Status_UpdateEditor()
        end
    end
end




function NeuronStatusBar:UpdateOrientation(button, command, gui, query)

    if (query) then
        return BarOrientations[button.config.orientation]
    end

    local index = tonumber(command)

    if (index) then

        button.config.orientation = index
        button.sb.orientation = button.config.orientation

        button.sb:SetOrientation(BarOrientations[button.config.orientation]:upper())
        button.fbframe.feedback:SetOrientation(BarOrientations[button.config.orientation]:upper())

        if (button.config.orientation == 2) then
            button.sb.cText:SetAlpha(0)
            button.sb.lText:SetAlpha(0)
            button.sb.rText:SetAlpha(0)
            button.sb.mText:SetAlpha(0)
        else
            button.sb.cText:SetAlpha(1)
            button.sb.lText:SetAlpha(1)
            button.sb.rText:SetAlpha(1)
            button.sb.mText:SetAlpha(1)
        end

        local width, height = button.config.width,  button.config.height

        button.config.width = height
        button.config.height = width

        button:SetWidth(button.config.width)

        button:SetHeight(button.config.height)

        Neuron.NeuronBar:SetObjectLoc(button.bar)

        Neuron.NeuronBar:SetPerimeter(button.bar)

        Neuron.NeuronBar:SetSize(button.bar)

        if (not skipupdate) then
            Neuron.NeuronGUI:Status_UpdateEditor()
            Neuron.NeuronBar:Update(button.bar)
        end
    end
end




function NeuronStatusBar:UpdateCenterText(button, command, gui, query)

    if (not sbStrings[button.config.sbType]) then
        return "---"
    end

    if (query) then
        return sbStrings[button.config.sbType][button.config.cIndex][1]
    end

    local index = tonumber(command)

    if (index) then

        button.config.cIndex = index

        if (sbStrings[button.config.sbType]) then
            button.sb.cFunc = sbStrings[button.config.sbType][button.config.cIndex][2]
        else
            buttonsb.cFunc = function() return "" end
        end

        button.sb.cText:SetText(button.sb.cFunc(button.sb))
    end
end




function NeuronStatusBar:UpdateLeftText(button, command, gui, query)

    if (not sbStrings[button.config.sbType]) then
        return "---"
    end

    if (query) then
        return sbStrings[button.config.sbType][button.config.lIndex][1]
    end

    local index = tonumber(command)

    if (index) then

        button.config.lIndex = index

        if (sbStrings[button.config.sbType]) then
            button.sb.lFunc = sbStrings[button.config.sbType][button.config.lIndex][2]
        else
            button.sb.lFunc = function() return "" end
        end

        button.sb.lText:SetText(button.sb.lFunc(button.sb))

    end
end




function NeuronStatusBar:UpdateRightText(button, command, gui, query)

    if (not sbStrings[button.config.sbType]) then
        return "---"
    end

    if (query) then
        return sbStrings[button.config.sbType][button.config.rIndex][1]
    end

    local index = tonumber(command)

    if (index) then

        button.config.rIndex = index

        if (sbStrings[button.config.sbType] and button.config.rIndex) then
            button.sb.rFunc = sbStrings[button.config.sbType][button.config.rIndex][2]
        else
            button.sb.rFunc = function() return "" end
        end

        button.sb.rText:SetText(button.sb.rFunc(button.sb))

    end
end




function NeuronStatusBar:UpdateMouseover(button, command, gui, query)

    if (not sbStrings[button.config.sbType]) then
        return "---"
    end

    if (query) then
        return sbStrings[button.config.sbType][button.config.mIndex][1]
    end

    local index = tonumber(command)

    if (index) then

        button.config.mIndex = index

        if (sbStrings[button.config.sbType]) then
            button.sb.mFunc = sbStrings[button.config.sbType][button.config.mIndex][2]
        else
            button.sb.mFunc = function() return "" end
        end

        button.sb.mText:SetText(button.sb.mFunc(button.sb))
    end
end




function NeuronStatusBar:UpdateTooltip(button, command, gui, query)

    if (not sbStrings[button.config.sbType]) then
        return "---"
    end

    if (query) then
        return sbStrings[button.config.sbType][button.config.tIndex][1]
    end

    local index = tonumber(command)

    if (index) then

        button.config.tIndex = index

        if (sbStrings[button.config.sbType]) then
            button.sb.tFunc = sbStrings[button.config.sbType][button.config.tIndex][2]
        else
            button.sb.tFunc = function() return "" end
        end
    end
end




function NeuronStatusBar:UpdateUnit(button, command, gui, query)

    if (query) then
        return BarUnits[button.data.unit]
    end

    local index = tonumber(command)

    if (index) then

        button.data.unit = index

        button.sb.unit = BarUnits[button.data.unit]

    end
end




function NeuronStatusBar:UpdateCastIcon(button, frame, checked)

    if (checked) then
        button.config.showIcon = true
    else
        button.config.showIcon = false
    end

    button.sb.showIcon = button.config.showIcon

end




function NeuronStatusBar:ChangeStatusBarType(button)

    if (button.config.sbType == "xp") then
        button.config.sbType = "rep"
        button.config.cIndex = 2
        button.config.lIndex = 1
        button.config.rIndex = 1
    elseif (button.config.sbType == "rep") then
        button.config.sbType = "cast"
        button.config.cIndex = 1
        button.config.lIndex = 2
        button.config.rIndex = 3
    elseif (button.config.sbType == "cast") then
        button.config.sbType = "mirror"
        button.config.cIndex = 1
        button.config.lIndex = 2
        button.config.rIndex = 3
    else
        button.config.sbType = "xp"
        button.config.cIndex = 2
        button.config.lIndex = 1
        button.config.rIndex = 1
    end

    button:SetType()
end



function STATUS:SetData(bar)

    if (bar) then

        self.bar = bar
        self.alpha = bar.data.alpha
        self.showGrid = bar.data.showGrid

        self:SetFrameStrata(bar.data.objectStrata)
        self:SetScale(bar.data.scale)

    end

    self:SetWidth(self.config.width)
    self:SetHeight(self.config.height)

    self.bordercolor = { (";"):split(self.config.bordercolor) }

    self.cColor = { (";"):split(self.config.cColor) }
    self.lColor = { (";"):split(self.config.lColor) }
    self.rColor = { (";"):split(self.config.rColor) }
    self.mColor = { (";"):split(self.config.mColor) }
    self.tColor = { (";"):split(self.config.tColor) }

    self.sb.parent = self

    self.sb.cText:SetTextColor(self.cColor[1], self.cColor[2], self.cColor[3], self.cColor[4])
    self.sb.lText:SetTextColor(self.lColor[1], self.lColor[2], self.lColor[3], self.lColor[4])
    self.sb.rText:SetTextColor(self.rColor[1], self.rColor[2], self.rColor[3], self.rColor[4])
    self.sb.mText:SetTextColor(self.mColor[1], self.mColor[2], self.mColor[3], self.mColor[4])

    if (sbStrings[self.config.sbType]) then

        if (not sbStrings[self.config.sbType][self.config.cIndex]) then
            self.config.cIndex = 1
        end
        self.sb.cFunc = sbStrings[self.config.sbType][self.config.cIndex][2]

        if (not sbStrings[self.config.sbType][self.config.lIndex]) then
            self.config.lIndex = 1
        end
        self.sb.lFunc = sbStrings[self.config.sbType][self.config.lIndex][2]

        if (not sbStrings[self.config.sbType][self.config.rIndex]) then
            self.config.rIndex = 1
        end
        self.sb.rFunc = sbStrings[self.config.sbType][self.config.rIndex][2]

        if (not sbStrings[self.config.sbType][self.config.mIndex]) then
            self.config.mIndex = 1
        end
        self.sb.mFunc = sbStrings[self.config.sbType][self.config.mIndex][2]

        if (not sbStrings[self.config.sbType][self.config.tIndex]) then
            self.config.tIndex = 1
        end
        self.sb.tFunc = sbStrings[self.config.sbType][self.config.tIndex][2]

    else
        self.sb.cFunc = function() return "" end
        self.sb.lFunc = function() return "" end
        self.sb.rFunc = function() return "" end
        self.sb.mFunc = function() return "" end
        self.sb.tFunc = function() return "" end
    end

    self.sb.cText:SetText(self.sb.cFunc(self.sb))
    self.sb.lText:SetText(self.sb.lFunc(self.sb))
    self.sb.rText:SetText(self.sb.rFunc(self.sb))
    self.sb.mText:SetText(self.sb.mFunc(self.sb))

    self.sb.norestColor = { (";"):split(self.config.norestColor) }
    self.sb.restColor = { (";"):split(self.config.restColor) }

    self.sb.castColor = { (";"):split(self.config.castColor) }
    self.sb.channelColor = { (";"):split(self.config.channelColor) }
    self.sb.successColor = { (";"):split(self.config.successColor) }
    self.sb.failColor = { (";"):split(self.config.failColor) }

    self.sb.orientation = self.config.orientation
    self.sb:SetOrientation(BarOrientations[self.config.orientation]:upper())
    self.fbframe.feedback:SetOrientation(BarOrientations[self.config.orientation]:upper())

    if (self.config.orientation == 2) then
        self.sb.cText:SetAlpha(0)
        self.sb.lText:SetAlpha(0)
        self.sb.rText:SetAlpha(0)
        self.sb.mText:SetAlpha(0)
    else
        self.sb.cText:SetAlpha(1)
        self.sb.lText:SetAlpha(1)
        self.sb.rText:SetAlpha(1)
        self.sb.mText:SetAlpha(1)
    end

    if (BarTextures[self.config.texture]) then
        self.sb:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
        self.fbframe.feedback:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
    else
        self.sb:SetStatusBarTexture(BarTextures[1][self.config.orientation])
        self.fbframe.feedback:SetStatusBarTexture(BarTextures[1][self.config.orientation])
    end

    NeuronStatusBar:SetBorder(self.sb, self.config, self.bordercolor)
    NeuronStatusBar:SetBorder(self.fbframe.feedback, self.config, self.bordercolor)

    self:SetFrameLevel(4)

    self.fbframe:SetFrameLevel(self:GetFrameLevel()+10)
    self.fbframe.feedback:SetFrameLevel(self.sb:GetFrameLevel()+10)
    self.fbframe.feedback.bg:SetFrameLevel(self.sb.bg:GetFrameLevel()+10)
    self.fbframe.feedback.border:SetFrameLevel(self.sb.border:GetFrameLevel()+10)

end



function STATUS:LoadData(spec, state)

    local id = self.id

    if not DB.statusbtn[id] then
        DB.statusbtn[id] = {}
    end

    self.DB = DB.statusbtn[id]

    self.config = self.DB.config
    self.keys = self.DB.keys
    self.data = self.DB.data
end




function STATUS:SetObjectVisibility(show, hide)

    if (show) then

        self.editmode = true

        self.fbframe:Show()

    else
        self.editmode = nil

        self.fbframe:Hide()
    end

end




function STATUS:LoadAux()

    Neuron.NeuronGUI:SB_CreateEditFrame(self, self.objTIndex)

end


function STATUS:SetDefaults(config)

    if (config) then
        for k,v in pairs(config) do
            self.config[k] = v
        end
    end

end




function STATUS:GetDefaults()

    return configDefaults[self.id]

end




function NeuronStatusBar:StatusBar_Reset(button)

    button:RegisterForClicks("")
    button:SetScript("OnClick", function() end)
    button:SetScript("OnEnter", function() end)
    button:SetScript("OnLeave", function() end)
    button:SetHitRectInsets(button:GetWidth()/2, button:GetWidth()/2, button:GetHeight()/2, button:GetHeight()/2)

    button.sb:UnregisterAllEvents()
    button.sb:SetScript("OnEvent", function() end)
    button.sb:SetScript("OnUpdate", function() end)
    button.sb:SetScript("OnShow", function() end)
    button.sb:SetScript("OnHide", function() end)

    button.sb.unit = nil
    button.sb.rep = nil
    button.sb.showIcon = nil

    button.sb.cbtimer:UnregisterAllEvents()
    button.sb.cbtimer:SetScript("OnEvent", nil)

    for index, sb in ipairs(MirrorBars) do
        if (sb == statusbar) then
            tremove(MirrorBars, index)
        end
    end
end




function STATUS:SetType(save)

    if (InCombatLockdown()) then
        return
    end

    NeuronStatusBar:StatusBar_Reset(self)

    if (kill) then

        self:SetScript("OnEvent", function() end)
        self:SetScript("OnUpdate", function() end)
    else

        if (self.config.sbType == "cast") then

            self.sb:RegisterEvent("UNIT_SPELLCAST_START")
            self.sb:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
            self.sb:RegisterEvent("UNIT_SPELLCAST_STOP")
            self.sb:RegisterEvent("UNIT_SPELLCAST_FAILED")
            self.sb:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
            self.sb:RegisterEvent("UNIT_SPELLCAST_DELAYED")
            self.sb:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
            self.sb:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
            self.sb:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
            self.sb:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
            self.sb:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

            self.sb.unit = BarUnits[self.data.unit]
            self.sb.showIcon = self.config.showIcon

            self.sb.showTradeSkills = true
            self.sb.casting = nil
            self.sb.channeling = nil
            self.sb.holdTime = 0

            self.sb:SetScript("OnEvent", function(self, event, ...) NeuronStatusBar:CastBar_OnEvent(self, event, ...) end)
            self.sb:SetScript("OnUpdate", function(self, elapsed) NeuronStatusBar:CastBar_OnUpdate(self, elapsed) end)

            if (not self.sb.cbtimer.castInfo) then
                self.sb.cbtimer.castInfo = {}
            else
                wipe(self.sb.cbtimer.castInfo)
            end

            self.sb.cbtimer:RegisterEvent("UNIT_SPELLCAST_START")
            self.sb.cbtimer:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
            self.sb.cbtimer:RegisterEvent("UNIT_SPELLCAST_STOP")
            self.sb.cbtimer:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
            self.sb.cbtimer:SetScript("OnEvent", function(self, event, ...) NeuronStatusBar:CastBarTimer_OnEvent(self, event, ...) end)

            self.sb:Hide()

        elseif (self.config.sbType == "xp") then

            self:SetAttribute("hasaction", true)

            self:RegisterForClicks("RightButtonUp")
            self:SetScript("OnClick", function(self, mousebutton, down) NeuronStatusBar:OnClick(self, mousebutton, down) end)
            self:SetScript("OnEnter", function(self) NeuronStatusBar:OnEnter(self) end)
            self:SetScript("OnLeave", function(self) NeuronStatusBar:OnLeave(self) end)
            self:SetHitRectInsets(0, 0, 0, 0)

            self.sb:RegisterEvent("PLAYER_XP_UPDATE")
            self.sb:RegisterEvent("HONOR_XP_UPDATE")
            self.sb:RegisterEvent("UPDATE_EXHAUSTION")
            self.sb:RegisterEvent("PLAYER_ENTERING_WORLD")
            self.sb:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
            self.sb:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

            self.sb:SetScript("OnEvent", function(self, event, ...) NeuronStatusBar:XPBar_OnEvent(self, event, ...) end)

            self.sb:Show()

        elseif (self.config.sbType == "rep") then

            self.sb.repID = self.data.repID

            self:SetAttribute("hasaction", true)

            self:RegisterForClicks("RightButtonUp")
            self:SetScript("OnClick", function(self, mousebutton, down) NeuronStatusBar:OnClick(self, mousebutton, down) end)
            self:SetScript("OnEnter", function(self) NeuronStatusBar:OnEnter(self) end)
            self:SetScript("OnLeave", function(self) NeuronStatusBar:OnLeave(self) end)
            self:SetHitRectInsets(0, 0, 0, 0)

            self.sb:RegisterEvent("UPDATE_FACTION")
            self.sb:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
            self.sb:RegisterEvent("PLAYER_ENTERING_WORLD")

            self.sb:SetScript("OnEvent", function(self, event, ...) NeuronStatusBar:repbar_OnEvent(self, event, ...) end)

            self.sb:Show()

        elseif (self.config.sbType == "mirror") then

            self.sb:SetScript("OnUpdate", function(self, elapsed) NeuronStatusBar:MirrorBar_OnUpdate(self, elapsed) end)

            tinsert(MirrorBars, self)

            self.sb:Hide()

        end


        local typeString

        if (self.config.sbType == "xp") then
            typeString = L["XP Bar"]
        elseif (self.config.sbType == "rep") then
            typeString = L["Rep Bar"]
        elseif (self.config.sbType == "cast") then
            typeString = L["Cast Bar"]
        elseif (self.config.sbType == "mirror") then
            typeString = L["Mirror Bar"]
        end

        self.fbframe.feedback.text:SetText(typeString)

    end

    self:SetData(self.bar)

end




function NeuronStatusBar:SetFauxState(button, state)

    -- empty

end