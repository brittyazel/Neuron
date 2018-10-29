

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
            ['*'] = {}
        },
        buttons = {
            ['*'] = {
                ['config'] = {},
                ['keys'] = {hotKeyLock = false, hotKeyPri = false, hotKeyText = "", hotKeys = ""},
                [1] = {['**'] = {}, ['homestate'] = {}},
                [2] = {['**'] = {}, ['homestate'] = {}},
                [3] = {['**'] = {}, ['homestate'] = {}},
                [4] = {['**'] = {}, ['homestate'] = {}},
            }
        },

        extrabar = {
            ['*'] = {}
        },
        extrabtn = {
            ['*'] = {
                ['config'] = {},
                ['keys'] = {hotKeyLock = false, hotKeyPri = false, hotKeyText = "", hotKeys = ""},
                [1] = {['**'] = {}, ['homestate'] = {}},
                [2] = {['**'] = {}, ['homestate'] = {}},
                [3] = {['**'] = {}, ['homestate'] = {}},
                [4] = {['**'] = {}, ['homestate'] = {}},
            }
        },

        exitbar ={
            ['*'] = {}
        },
        exitbtn = {
            ['*'] = {
                ['config'] = {},
                ['keys'] = {hotKeyLock = false, hotKeyPri = false, hotKeyText = "", hotKeys = ""},
                [1] = {['**'] = {}, ['homestate'] = {}},
                [2] = {['**'] = {}, ['homestate'] = {}},
                [3] = {['**'] = {}, ['homestate'] = {}},
                [4] = {['**'] = {}, ['homestate'] = {}},
            }
        },

        bagbar = {
            ['*'] = {}
        },
        bagbtn = {
            ['*'] = {
                ['config'] = {},
                ['keys'] = {hotKeyLock = false, hotKeyPri = false, hotKeyText = "", hotKeys = ""},
                [1] = {['**'] = {}, ['homestate'] = {}},
                [2] = {['**'] = {}, ['homestate'] = {}},
                [3] = {['**'] = {}, ['homestate'] = {}},
                [4] = {['**'] = {}, ['homestate'] = {}},
            }
        },

        zoneabilitybar = {
            ['*'] = {}
        },
        zoneabilitybtn = {
            ['*'] = {
                ['config'] = {},
                ['keys'] = {hotKeyLock = false, hotKeyPri = false, hotKeyText = "", hotKeys = ""},
                [1] = {['**'] = {}, ['homestate'] = {}},
                [2] = {['**'] = {}, ['homestate'] = {}},
                [3] = {['**'] = {}, ['homestate'] = {}},
                [4] = {['**'] = {}, ['homestate'] = {}},
            }
        },

        menubar = {
            ['*'] = {}
        },
        menubtn = {
            ['*'] = {
                ['config'] = {},
                ['keys'] = {hotKeyLock = false, hotKeyPri = false, hotKeyText = "", hotKeys = ""},
                [1] = {['**'] = {}, ['homestate'] = {}},
                [2] = {['**'] = {}, ['homestate'] = {}},
                [3] = {['**'] = {}, ['homestate'] = {}},
                [4] = {['**'] = {}, ['homestate'] = {}},
            }
        },

        petbar = {
            ['*'] = {}
        },
        petbtn = {
            ['*'] = {
                ['config'] = {},
                ['keys'] = {hotKeyLock = false, hotKeyPri = false, hotKeyText = "", hotKeys = ""},
                [1] = {['**'] = {}, ['homestate'] = {}},
                [2] = {['**'] = {}, ['homestate'] = {}},
                [3] = {['**'] = {}, ['homestate'] = {}},
                [4] = {['**'] = {}, ['homestate'] = {}},
            }
        },

        statusbar = {
            ['*'] = {}
        },
        statusbtn = {
            ['*'] = {
                ['config'] = {},
                ['keys'] = {hotKeyLock = false, hotKeyPri = false, hotKeyText = "", hotKeys = ""},
                ['data'] = {},
                [1] = {['**'] = {}, ['homestate'] = {}},
                [2] = {['**'] = {}, ['homestate'] = {}},
                [3] = {['**'] = {}, ['homestate'] = {}},
                [4] = {['**'] = {}, ['homestate'] = {}},
            }
        },

    }
}

local genericBarData = {
    name = "",

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


for k,v in pairs(genericBarData) do
    NeuronDefaults.profile.bars['*'][k] = v
    NeuronDefaults.profile.extrabar['*'][k] = v
    NeuronDefaults.profile.exitbar['*'][k] = v
    NeuronDefaults.profile.bagbar['*'][k] = v
    NeuronDefaults.profile.zoneabilitybar['*'][k] = v
    NeuronDefaults.profile.petbar['*'][k] = v
    NeuronDefaults.profile.statusbar['*'][k] = v
    NeuronDefaults.profile.menubar['*'][k] = v
end


local genericButtonData = {
    btnType = "macro",

    class = "",

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

local genericKeyData = {
    hotKeys = ":",
    hotKeyText = ":",
    hotKeyLock = false,
    hotKeyPri = false,
}

for k,v in pairs(genericButtonData) do
    NeuronDefaults.profile.buttons['*'].config[k] = v
    NeuronDefaults.profile.extrabtn['*'].config[k] = v
    NeuronDefaults.profile.exitbtn['*'].config[k] = v
    NeuronDefaults.profile.bagbtn['*'].config[k] = v
    NeuronDefaults.profile.zoneabilitybtn['*'].config[k] = v
    NeuronDefaults.profile.petbtn['*'].config[k] = v
    NeuronDefaults.profile.statusbtn['*'].config[k] = v
    NeuronDefaults.profile.menubtn['*'].config[k] = v
end

for k,v in pairs(genericKeyData) do
    NeuronDefaults.profile.buttons['*'].keys[k] = v
    NeuronDefaults.profile.extrabtn['*'].keys[k] = v
    NeuronDefaults.profile.exitbtn['*'].keys[k] = v
    NeuronDefaults.profile.bagbtn['*'].keys[k] = v
    NeuronDefaults.profile.zoneabilitybtn['*'].keys[k] = v
    NeuronDefaults.profile.petbtn['*'].keys[k] = v
    NeuronDefaults.profile.statusbtn['*'].keys[k] = v
    NeuronDefaults.profile.menubtn['*'].config[k] = v
end


local genericStateData = {
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

for k,v in pairs(genericStateData) do
    for i = 1,4 do
        NeuronDefaults.profile.buttons['*'][i]['**'][k] = v
        NeuronDefaults.profile.extrabtn['*'][i]['**'][k] = v
        NeuronDefaults.profile.exitbtn['*'][i]['**'][k] = v
        NeuronDefaults.profile.bagbtn['*'][i]['**'][k] = v
        NeuronDefaults.profile.zoneabilitybtn['*'][i]['**'][k] = v
        NeuronDefaults.profile.petbtn['*'][i]['**'][k] = v
        NeuronDefaults.profile.statusbtn['*'][i]['**'][k] = v
        NeuronDefaults.profile.menubtn['*'].config[k] = v
    end
end



local statusGenericButtonConfig = {
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

local statusGenericButtonData = {
    unit = 2,
    repID = 0,
    repAuto = 0,
}

for k,v in pairs(statusGenericButtonConfig) do
    NeuronDefaults.profile.statusbtn['*'].config[k] = v
end

for k,v in pairs(statusGenericButtonData) do
    NeuronDefaults.profile.statusbtn['*'].data[k] = v
end