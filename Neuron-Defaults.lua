
---**NOTE** values assigned with empty quotes, i.e. name = "", basically don't exist. Lua treats them as nil


local genericBarData = {
    name = ":",

    objectList = {},

    hidestates = ":",

    point = "BOTTOM",
    x = 0,
    y = 190,

    scale = 1,
    shape = 1,
    columns = false,

    alpha = 1,
    alphaUp = 1,
    alphaMax = 1,
    fadeSpeed = 0.5,

    barStrata = "MEDIUM",
    objectStrata = "LOW",

    padH = 0,
    padV = 0,
    arcStart = 0,
    arcLength = 359,

    snapTo = false,
    snapToPad = 0,
    snapToPoint = false,
    snapToFrame = false,

    autoHide = false,
    showGrid = true,

    bindColor = "1;1;1;1",
    macroColor = "1;1;1;1",
    countColor = "1;1;1;1",
    cdcolor1 = "1;0.82;0;1",
    cdcolor2 = "1;0.1;0.1;1",
    auracolor1 = "0;0.82;0;1",
    auracolor2 = "1;0.1;0.1;1",
    buffcolor = "0;0.8;0;1",
    debuffcolor = "0.8;0;0;1",
    rangecolor = "0.7;0.15;0.15;1",
    border = true,

    upClicks = true,
    downClicks = false,

    conceal = false,

    multiSpec = false,

    spellGlow = true,
    spellGlowDef = true,
    spellGlowAlt = false,

    barLock = false,
    barLockAlt = false,
    barLockCtrl = false,
    barLockShift = false,

    tooltips = true,
    tooltipsEnhanced = true,
    tooltipsCombat = false,

    bindText = true,
    macroText = true,
    countText = true,
    rangeInd = true,

    cdText = false,
    cdAlpha = false,
    auraText = false,
    auraInd = false,

    homestate = true,
    paged = false,
    stance = false,
    stealth = false,
    reaction = false,
    combat = false,
    group = false,
    pet = false,
    fishing = false,
    vehicle = false,
    possess = false,
    override = false,
    extrabar = false,
    alt = false,
    ctrl = false,
    shift = false,
    target = false,

    selfCast = false,
    focusCast = false,
    rightClickTarget = false,
    mouseOverCast = false,

    custom = false,
    customRange = false,
    customNames = false,

    remap = false,
}

local genericButtonData = {
    btnType = "macro",

    mouseAnchor = false,
    clickAnchor = false,
    anchorDelay = false,
    anchoredBar = false,

    upClicks = true,
    downClicks = false,
    copyDrag = false,
    muteSFX = false,
    clearerrors= false,
    cooldownAlpha = 1,

    bindText = true,
    bindColor = "1;1;1;1",

    countText = true,
    spellCounts = false,
    comboCounts = false,
    countColor = "1;1;1;1",

    macroText = false,
    macroColor = "1;1;1;1",

    cdText = false,
    cdcolor1 = "1;0.82;0;1",
    cdcolor2 = "1;0.1;0.1;1",

    auraText = false,
    auracolor1 = "0;0.82;0;1",
    auracolor2 = "1;0.1;0.1;1",

    auraInd = false,
    buffcolor = "0;0.8;0;1",
    debuffcolor = "0.8;0;0;1",

    rangeInd = true,
    rangecolor = "0.7;0.15;0.15;1",

    skincolor = "1;1;1;1",
    hovercolor = "0.1;0.1;1;1",
    equipcolor = "0.1;1;0.1;1",

    scale = 1,
    alpha = 1,
    XOffset = 0,
    YOffset = 0,
    HHitBox = 0,
    VHitBox = 0,
}


local genericSpecData = {
    actionID = false,

    macro_Text = "",
    macro_Icon = false,
    macro_Name = "",
    macro_Auto = false,
    macro_Watch = false,
    macro_Equip = false,
    macro_Note = "",
    macro_UseNote = false,
}

local genericStatusBtnData= {
    sbType = "statusbar",

    width = 250,
    height = 18,
    scale = 1,
    XOffset = 0,
    YOffset = 0,
    texture = 7,
    border = 1,

    orientation = 1,

    cIndex = 1,
    cColor = "1;1;1;1",

    lIndex = 1,
    lColor = "1;1;1;1",

    rIndex = 1,
    rColor = "1;1;1;1",

    mIndex = 1,
    mColor = "1;1;1;1",

    tIndex = 1,
    tColor = "1;1;1;1",

    bordercolor = "1;1;1;1",

    norestColor = "1;0;1;1",
    restColor = "0;0;1;1",

    castColor = "1;0.7;0;1",
    channelColor = "0;1;0;1",
    successColor = "0;1;0;1",
    failColor = "1;0;0;1",

    showIcon = false,

}

local genericKeyData = {
    hotKeyLock = false,
    hotKeyPri = false,
    hotKeyText = ":",
    hotKeys = ":"
}


------------------------------------------------------------------------
----------------------MAIN TABLE----------------------------------------
------------------------------------------------------------------------

NeuronDefaults = {
    profile = {
        throttle = 0.2,
        timerLimit = 4,
        snapToTol = 28,

        blizzbar = false,


        mouseOverMod= "NONE",

        perCharBinds = false,
        firstRun = true,

        AutoWatch = 1,

        extrabarFirstRun = true,
        exitbarFirstRun = true,
        zoneabilitybarFirstRun = true,
        bagbarFirstRun = true,
        menubarFirstRun = true,
        petbarFirstRun = true,
        statusbarFirstRun = true,

        NeuronItemCache = {},

        NeuronIcon = {hide = false,},

        bars = {
            ['*'] = CopyTable(genericBarData)
        },
        buttons = {
            ['*'] = {
                ['config'] = CopyTable(genericButtonData),
                ['keys'] = CopyTable(genericKeyData),
                [1] = {['**'] = CopyTable(genericSpecData), ['homestate'] = {}},
                [2] = {['**'] = CopyTable(genericSpecData), ['homestate'] = {}},
                [3] = {['**'] = CopyTable(genericSpecData), ['homestate'] = {}},
                [4] = {['**'] = CopyTable(genericSpecData), ['homestate'] = {}},
            }
        },

        extrabar = {
            ['*'] = CopyTable(genericBarData)
        },
        extrabtn = {
            ['*'] = {
                ['config'] = CopyTable(genericButtonData),
                ['keys'] = CopyTable(genericKeyData),
                ['data'] = {},
            }
        },

        exitbar ={
            ['*'] = CopyTable(genericBarData)
        },
        exitbtn = {
            ['*'] = {
                ['config'] = CopyTable(genericButtonData),
                ['keys'] = CopyTable(genericKeyData),
                ['data'] = {},
            }
        },

        bagbar = {
            ['*'] = CopyTable(genericBarData)
        },
        bagbtn = {
            ['*'] = {
                ['config'] = CopyTable(genericButtonData),
                ['keys'] = CopyTable(genericKeyData),
                ['data'] = {},
            }
        },

        zoneabilitybar = {
            ['*'] = CopyTable(genericBarData)
        },
        zoneabilitybtn = {
            ['*'] = {
                ['config'] = CopyTable(genericButtonData),
                ['keys'] = CopyTable(genericKeyData),
                ['data'] = {},
            }
        },

        menubar = {
            ['*'] = CopyTable(genericBarData)
        },
        menubtn = {
            ['*'] = {
                ['config'] = CopyTable(genericButtonData),
                ['keys'] = CopyTable(genericKeyData),
                ['data'] = {},
            }
        },

        petbar = {
            ['*'] = CopyTable(genericBarData)
        },
        petbtn = {
            ['*'] = {
                ['config'] = CopyTable(genericButtonData),
                ['keys'] = CopyTable(genericKeyData),
                ['data'] = {},
            }
        },

        statusbar = {
            ['*'] = CopyTable(genericBarData)
        },
        statusbtn = {
            ['*'] = {
                ['config'] = CopyTable(genericStatusBtnData),
                ['keys'] = CopyTable(genericKeyData),
                ['data'] = {unit = 2, repID = 0, repAuto = 0,},
            }
        },

    }
}

------------------------------------------------------------------------------