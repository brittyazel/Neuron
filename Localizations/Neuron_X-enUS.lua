-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local L = LibStub("AceLocale-3.0"):NewLocale("Neuron", "enUS", true)

if not L then return end

L["Command List"] = true

L["Menu"] = true
L["Menu_Description"] = "Open the main menu"

L["Create"] = true
L["Create_Description"] = "Create a blank bar of the given type"

L["Select"] = true
L["Select_Description"] = "Switch the currently selected bar"

L["Delete"] = true
L["Delete_Description"] = "Delete the currently selected bar"

L["Config"] = true
L["Config_Description"] = "Toggle configuration mode for all bars"

L["Add"] = true
L["Add_Description"] = "Adds buttons to the currently selected bar"

L["Remove"] = true
L["Remove_Description"] = "Removes buttons from the currently selected bar"

L["Edit"] = true
L["Edit_Description"] = "Toggle edit mode for all buttons"

L["Bind"] = true
L["Bind_Description"] = "Toggle binding mode for all buttons"

L["Scale"] = true
L["Scale_Description"] = "Scale a bar to the desired size"

L["SnapTo"] = true
L["SnapTo_Description"] = "Toggle SnapTo for current bar"

L["AutoHide"] = true
L["AutoHide_Description"] = "Toggle AutoHide for current bar"

L["Conceal"] = true
L["Conceal_Description"] = "Toggle if current bar is shown or concealed at all times"

L["Shape"] = true
L["Shape_Description"] = "Change current bar's shape"

L["Name"] = true
L["Name_Description"] = "Change current bar's name"

L["Strata"] = true
L["Strata_Description"] = "Change current bar's frame strata"

L["Alpha"] = true
L["Alpha_Description"] = "Change current bar's alpha (transparency)"

L["AlphaUp"] = true
L["AlphaUp_Description"] = "Set current bar's conditions to 'alpha up'"

L["ArcStart"] = true
L["ArcStart_Description"] = "Set current bar's starting arc location (in degrees)"

L["ArcLen"] = true
L["ArcLen_Description"] = "Set current bar's arc length (in degrees)"

L["Columns"] = true
L["Columns_Description"] = "Set the number of columns for the current bar (for shape Multi-Column)"

L["PadH"] = true
L["PadH_Description"] = "Set current bar's horizontal padding"

L["PadV"] = true
L["PadV_Description"] = "Set current bar's vertical padding"

L["PadHV"] = true
L["PadHV_Description"] = "Adjust both horizontal and vertical padding of the current bar incrementally"

L["X"] = true
L["X_Description"] = "Change current bar's horizontal axis position"

L["Y"] = true
L["Y_Description"] = "Change current bar's vertical axis position"

L["State"] = true
L["State_Description"] = "Toggle an action state for the current bar"

L["Vis"] = true
L["Vis_Description"] = "Toggle visibility states for the current bar"

L["ShowGrid"] = true
L["ShowGrid_Description"] = "Toggle the current bar's showgrid flag"

L["Lock"] = true
L["Lock_Description"] = "Toggle bar lock."

L["Tooltips"] = true
L["Tooltips_Description"] = "Toggle tooltips for the current bar's action buttons"

L["SpellGlow"] = true
L["SpellGlow_Description"] = "Toggle spell activation animations on the current bar"

L["BindText"] = true
L["BindText_Description"] = "Toggle keybind text on the current bar"

L["MacroText"] = true
L["MacroText_Description"] = "Toggle macro name text on the current bar"

L["CountText"] = true
L["CountText_Description"] = "Toggle spell/item count text on the current bar"

L["CDText"] = true
L["CDText_Description"] = "Toggle cooldown counts text on the current bar"

L["CDAlpha"] = true
L["CDAlpha_Description"] = "Toggle a button's transparancy while on cooldown"

L["UpClick"] = true
L["UpClick_Description"] = "Toggle if buttons on the current bar respond to up clicks"

L["DownClick"] = true
L["DownClick_Description"] = "Toggle if buttons on the current bar respond to down clicks"

L["TimerLimit"] = true
L["TimerLimit_Description"] = "Sets the minimum time in seconds to begin showing text timers"

L["StateList"] = true
L["StateList_Description"] = "Print a list of valid states"

L["BarTypes"] = true
L["BarTypes_Description"] = "Print a list of available bar types to make"

L["BlizzUI"] = true
L["BlizzUI_Description"] = "Toggle Blizzard's DefaultUI"

L["MoveSpecButtons"] = true
L["MoveSpecButtons_Description"] = "Copies the buttons from one spec to a second"



-----------------------------------------------
------------------General----------------------
-----------------------------------------------

L["How to use"] = true
L["Command"] = true
L["Option"] = true

L["No bar selected or command invalid"] = true

L["Custom_Option"] = "For custom states, add a desired state string (/neuron state custom <state string>) where <state string> is a semicolon seperated list of state conditions"


L["Valid States"]=true
L["Invalid index"] = true


L["Hide"] = true
L["Show"] = true

L["Home State"] = true
L["Last State"] = true


L["Paged"] = true
L["Stance"] = true
L["Pet"] = true
L["Alt"] = true
L["Ctrl"] = true
L["Shift"] = true
L["Stealth"] = true
L["Reaction"] = true
L["Combat"]  = true
L["Group"] = true
L["Fishing"] = true
L["Vehicle"] = true
L["Custom"] = true
L["Possess"] = true
L["Override"] = true
L["Extrabar"] = true


L["Page 1"] = true
L["Page 2"] = true
L["Page 3"] = true
L["Page 4"] = true
L["Page 5"] = true
L["Page 6"] = true


L["No Pet"] = true
L["Pet Exists"] = true

L["Alt Up"] = true
L["Alt Down"] = true
L["Control Up"] = true
L["Control Down"] = true
L["Shift Up"] = true
L["Shift Down"] = true

L["Vanish"] = true
L["Shapeshift"] = true
L["No Stealth"] = true
L["Friendly"] = true
L["Hostile"] = true
L["Out of Combat"] = true
L["In Combat"] = true

L["No Group"] = true
L["Group: Raid"] = true
L["Group: Party"] = true
L["No Fishing Pole"] = true
L["Fishing Pole"] = true

L["No Vehicle"] = true
L["Vehicle"] = true
L["No Possess"] = true
L["Possess"] = true
L["No Override Bar"] = true
L["Override Bar"] = true
L["No Extra Bar"] = true
L["Extra Bar"] = true

L["Vehicle Exit Bar"] = true

L["Custom States"] = true


---class specific state names
L["Caster Form"] = true
L["Healer Form"] = true
L["Melee"] = true
L["Shadow Dance"] = true


L["Left-Click"] = true
L["Right-Click"] = true

L["Configure Bars"] = true
L["Configure Buttons"] = true

L["Toggle Keybind Mode"] = true
L["Open the Interface Menu"] = true


L["Keybind_Tooltip_1"] = "Press a key to bind it to"
L["Keybind_Tooltip_2"] = "Current Binding(s)"
L["Keybind_Tooltip_3"] = "Left-Click to lock the current binding(s)"
L["Keybind_Tooltip_4"] = "Right-Click to give these bindings maximum priority"
L["Keybind_Tooltip_5"] = "Hit ESC to clear the current binding(s)"

L["Empty Button"] = true
L["Edit Bindings"] = true
L["None"] = true

L["Locked"] = true
L["Priority"] = true
L["Bindings_Locked_Notice"]	= "This button's bindings are locked.\nLeft-Click button to unlock."

L["Off"] = true
L["Combat"] = true
L["Mouseover"] = true
L["Combat + Mouseover"] = true
L["Retreat"] = true
L["Retreat + Mouseover"] = true

L["Bar_Shapes_List"] = "\n1=Linear\n2=Circle\n3=Circle + One"
L["Linear"] = true
L["Circle"] = true
L["Circle + One"] = true
L["Bar_Strata_List"] = "\n1=BACKGROUND\n2=LOW\n3=MEDIUM\n4=HIGH\n5=DIALOG"
L["Bar_Alpha_Instructions"] = "Alpha value must be between zero(0) and one(1)"
L["Bar_ArcStart_Instructions"] = "Arc start must be between 0 and 359"
L["Bar_ArcLength_Instructions"] = "Arc length must be between 0 and 359"
L["Bar_Column_Instructions"] = "Enter a number of desired columns for the bar higher than zero(0)\nOmit number to turn off columns"
L["Horozontal_Padding_Instructions"] = "Enter a valid number for desired horizontal button padding"
L["Vertical_Padding_Instructions"] = "Enter a valid number for desired vertical button padding"
L["Horozontal_and_Vertical_Padding_Instructions"] = "Enter a valid number to increase/decrease both the horizontal and vertical button padding"
L["X_Position_Instructions"] = "Enter a valid number for desired x position offset"
L["Y_Position_Instructions"] = "Enter a valid number for desired y position offset"

L["Bar_Lock_Modifier_Instructions"] = "Valid mod keys:\n\nalt: unlock bar when the <alt> key is down\nctrl: unlock bar when the <ctrl> key is down\nshift: unlock bar when the <shift> key is down"
L["Tooltip_Instructions"] = "Valid options:\n\nenhanced: display additional ability info\ncombat: hide/show tooltips while in combat"
L["Spellglow_Instructions"] = "Valid options:\n\ndefault: use Blizzard default spell glow animation\nalt: use alternate subdued spell glow animation"

L["Timer_Limit_Set_Message"] = "Timer limit set to %d seconds"
L["Timer_Limit_Invalid_Message"] = "Invalid timer limit"


L["Attack"] = true
L["Follow"] = true
L["Move To"] = true
L["Assist"] = true
L["Defensive"] = true
L["Passive"] = true


L["Apply"] = true
L["Cancel"] = true
L["Done"] = true
L["Create New Bar"] = true
L["Delete Current Bar"] = true
L["Select Bar Type"] = true
L["Confirm"] = true
L["Yes"] = true
L["No"] = true
L["General Options"] = true
L["Bar States"] = true
L["Object Editor"] = true
L["Macro Data"] = true
L["Action Data"] = true
L["Options"] = true

L["Macro Name"] = true
L["Click here to edit macro note"] = true
L["Use macro note as button tooltip"] = true

L["Count"] = true
L["Search"] = true
L["Custom Icon"] = true
L["Path"] = true

L["Show Grid"] = true
L["Hidden"] = true
L["Up Clicks"] = true
L["Down Clicks"] = true
L["Multi Spec"] = true
L["Spell Alerts"] = true
L["Default Alert"] = true
L["Subdued Alert"] = true
L["Lock Actions"] = true
L["Unlock on SHIFT"] = true
L["Unlock on CTRL"] = true
L["Unlock on ALT"] = true
L["Enable Tooltips"] = true
L["Enhanced"] = true
L["Hide in Combat"] = true
L["Show Border Style"] = true

L["Preset Action States"] = true
L["Custom Action States"] = true


L["Select a stance to remap:"] = true
L["Remap selected stance to:"] = true


L["Scale"] = true
L["Alpha"] = true
L["AlphaUp Speed"] = true
L["Strata"] = true
L["Shape"] = true
L["Horiz Padding"] = true
L["Vert Padding"] = true
L["H+V Padding"] = true
L["Columns"] = true
L["Arc Start"] = true
L["Arc Length"] = true

L["Keybind Label"] = true
L["Macro Name"] = true
L["Stack/Charge Count Label"] = true
L["Out-of-Range Indicator"] = true
L["Cooldown Countdown"] = true
L["Cooldown Transparency"] = true

L["Point"] = true
L["X Position"] = true
L["Y Position"] = true

L["Display the Blizzard UI"] = true
L["Shows / Hides the Default Blizzard UI"] = true

L["Display Minimap Button"] = true
L["Toggles the minimap button."] = true

L["Bar Visibility Toggles"] = true
L["Target"] = true
L["Has Target"] = true
L["No Target"] = true
L["Indoors"] = true
L["Outdoors"] = true
L["Mounted"] = true
L["Flying"] = true
L["Resting"] = true
L["Swimming"] = true
L["Harm"] = true
L["Help"] = true
L["Display button for specialization 1"] = true
L["Display button for specialization 2"] = true
L["Display button for specialization 3"] = true
L["Display button for specialization 4"] = true


L["Spell Target Options"] = true

L["Self-Cast by modifier"] = true
L["Toggle the use of the modifier-based self-cast functionality."] = true
L["Select the Self-Cast Modifier"] = true

L["Focus-Cast by modifier"] = true
L["Toggle the use of the modifier-based focus-cast functionality."] = true
L["Select the Focus-Cast Modifier"] = true

L["Right-click Self-Cast"] = true
L["Toggle the use of the right-click self-cast functionality."] = true

L["Mouse-Over Casting"] = true
L["Toggle the use of the modifier-based mouse-over cast functionality."] = true
L["Select a modifier for Mouse-Over Casting"] = true
L["Mouse-Over Casting Modifier"] = true

L["Select the Self-Cast Modifier"] = true

L["Spell_Targeting_Modifier_None_Reminder"] = "\"None\" as modifier for Self & Focus Casting means its disabled. \nFor Mouse-Over Casting it means its always active, and no modifier is required."


L["XP Bar"] = true
L["Rep Bar"] = true
L["Cast Bar"] = true
L["Mirror Bar"] = true

L["Action Bar"] = true
L["Zone Action Bar"] = true
L["Status Bar"] = true
L["Stance Bar"] = true
L["Extra Action Bar"] = true
L["Bag Bar"] = true
L["Pet Bar"] = true
L["Menu Bar"] = true

L["Track Character XP"] = true
L["Track Covenant Renown"] = true
L["Track Azerite Power"] = true
L["Track Honor Points"] = true

L["Width"] = true
L["Height"] = true
L["Bar Fill"] = true
L["Border"] = true
L["Orientation"] = true

L["Center Text"] = true
L["Left Text"] = true
L["Right Text"] = true
L["Mouseover Text"] = true
L["Tooltip Text"] = true

L["Unit"] = true
L["Cast Icon"] = true

L["Spell"] = true
L["Timer"] = true
L["Current/Next"] = true
L["Rested Levels"] = true
L["Percent"] = true
L["Bubbles"] = true
L["Faction"] = true
L["Current Level/Rank"] = true
L["Type"] = true
L["Levels"] = true
L["Level"] = true
L["Points"] = true
L["Prestige"] = true


L["Auto Select"] = true

L["Default"] = true
L["Contrast"] = true
L["Carpaint"] = true
L["Gel"] = true
L["Glassed"] = true
L["Soft"] = true
L["Velvet"] = true

L["Tooltip"] = true
L["Slider"] = true
L["Dialog"] = true

L["Horizontal"] = true
L["Vertical"] = true

L["Number of Buttons"] = true

L["Reward"] = true
L["Close"] = true
L["Select an Option"] = true

L["Item"] = true
L["Spell"] = true
L["Mount"] = true
L["Companion"] = true
L["Profession"] = true
L["Fun"] = true
L["Favorite"] = true
L["Keys"] = true
L["Attach Point"] = true
L["Relative To"] = true
L["Radius"] = true
L["Show On"] = true
L["Save"] = true
L["Output"] = true
L["Flyout Options"] = true

L["Left"] = true
L["Right"] = true
L["Top"] = true
L["Bottom"] = true
L["Top-Left"] = true
L["Top-Right"] = true
L["Bottom-Left"] = true
L["Bottom-Right"] = true
L["Center"] = true

L["Click"] = true
L["Generate Macro"] = true
L["Copy and Paste the text below"] = true

L["Pet Actions can not be added to Neuron bars at this time."] = true



L["Profile"] = true
L["Import"] = true
L["Export"] = true
L["Import or Export the current profile:"] = true
L["ImportExport_Desc"] = [[

Below you will find a text representation of your Neuron profile.

To export this profile, select and copy all of the text below and paste it somewhere safe.

To import a profile, replace all of the text below with the text from a previously exported profile.

]]
L["ImportExport_WarningDesc"] = [[

Copying and pasting profile data can be a time consuming experience. It may stall your game for multiple seconds.

WARNING: This will overwrite the current profile, and any changes you have made will be lost.
]]
L["ImportWarning"] = "Are you absolutely certain you wish to import this profile? The current profile will be overwritten."
L["No data to import."] = true
L["Decoding failed."] = true
L["Decompression failed."] = true
L["Data import Failed."] = true
L["Aborting."] = true

L["Experimental"] = true
L["Experimental Options"] = true
L["Experimental_Options_Warning"] = [[

Warning:

Here you will fill find experimental and potentially dangerous options.

Use at your own risk.

]]