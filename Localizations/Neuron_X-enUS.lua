--Neuron, a World of Warcraft® user interface addon.
--Copyright© 2006-2014 Connor H. Chenoweth, aka Maul - All rights reserved.
--Copyright© 2017 Britt W. Yazel, aka Soyier - All rights reserved.

local AddOnFolderName, private = ...

local L = _G.LibStub("AceLocale-3.0"):NewLocale("Neuron", "enUS", true)

if not L then return end


L["Command List"] = true

L["Menu"] = true
L["Menu_Description"] = "Open the main menu"

L["Create"] = true
L["Create_Description"] = "Create a blank bar of the given type"

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

L["AuraText"] = true
L["AuraText_Description"] = "Toggle aura watch text on the current bar"

L["AuraInd"] = true
L["AuraInd_Description"] = "Toggle aura button indicators on the current bar"

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

L["BlizzBar"] = true
L["BlizzBar_Description"] = "Toggle Blizzard's Action Bar"

L["Animate"] = true
L["Animate_Description"] = "Toggle Neuron's Orb Animation"

L["MoveSpecButtons"] = true
L["MoveSpecButtons_Description"] = "Copies the buttons from one spec to a second"


-----------------------------------------------
------------------General----------------------
-----------------------------------------------

L.BARTYPES_USAGE = "Usage: |cffffff00/neuron create <type>|r\n"
L.BARTYPES_TYPES = "     Types -\n"
L.BARTYPES_LINE = "Creates a bar for %ss"

L.SELECT_BAR = "No bar selected or command invalid"

L.CUSTOM_OPTION = "\n\nFor custom states, add a desired state string (|cffffff00/neuron state custom <state string>|r) where <state string> is a semicolon seperated list of state conditions\n\n|cff00ff00Example:|r [actionbar:1];[stance:1];[stance3,stealth];[mounted]\n\n|cff00ff00Note:|r the first state listed will be considered the \"home state\". If the state manager ever gets confused, that is the state it will default to."

L.VALIDSTATES = "\n|cff00ff00Valid states:|r "
L.INVALID_INDEX = "Invalid index"
L.STATE_HIDE = "hide"
L.STATE_SHOW = "show"

L.HOMESTATE = "Home State"
L.LASTSTATE = "Should not see!"

L.PAGED = "Paged"
L.STANCE = "Stance"
L.PET = "Pet"
L.ALT = "Alt"
L.CTRL = "Ctrl"
L.SHIFT = "Shift"
L.STEALTH = "Stealth"
L.REACTION = "Reaction"
L.COMBAT = "Combat"
L.GROUP = "Group"
L.FISHING = "Fishing"
L.VEHICLE = "Vehicle"
L.CUSTOM = "Custom"
L.POSSESS = "Possess"
L.OVERRIDE = "Override"
L.EXTRABAR = "Extrabar"

L.PAGED1 = "Page 1"
L.PAGED2 = "Page 2"
L.PAGED3 = "Page 3"
L.PAGED4 = "Page 4"
L.PAGED5 = "Page 5"
L.PAGED6 = "Page 6"

L.PET0 = "No Pet"
L.PET1 = "Pet Exists"

L.ALT0 = "Alt Up"
L.ALT1 = "Alt Down"
L.CTRL0 = "Control Up"
L.CTRL1 = "Control Down"
L.SHIFT0 = "Shift Up"
L.SHIFT1 = "Shift Down"

L.STEALTH0 = "No Stealth"
L.STEALTH1 = "Stealth"
L.REACTION0 = "Friendly"
L.REACTION1 = "Hostile"
L.COMBAT0 = "No Combat"
L.COMBAT1 = "Combat"

L.GROUP0 = "No Group"
L.GROUP1 = "Group: Raid"
L.GROUP2 = "Group: Party"
L.FISHING0 = "No Fishing Pole"
L.FISHING1 = "Fishing Pole"

L.VEHICLE0 = "No Vehicle"
L.VEHICLE1 = "Vehicle"
L.POSSESS0 = "No Possess"
L.POSSESS1 = "Possess"
L.OVERRIDE0 = "No Override Bar"
L.OVERRIDE1 = "Override Bar"
L.EXTRABAR0 = "No Extra Bar"
L.EXTRABAR1 = "Extra Bar"

L.CUSTOM0 = "Custom States"


---class specific state names
L.DRUID_CASTER = "Caster Form"
L.PRIEST_HEALER = "Healer Form"
L.ROGUE_MELEE = "Melee"
L.WARLOCK_CASTER = "Caster Form"
L.ROGUE_SHADOW_DANCE = "Shadow Dance"

L.MINIMAP_TOOLTIP1 = "Left-Click to Configure Bars"
L.MINIMAP_TOOLTIP2 = "Right-Click to Edit Buttons"
L.MINIMAP_TOOLTIP3 = "Middle-Click or Alt-Click to Edit Key Bindings"
L.MINIMAP_TOOLTIP4 = "Shift-Click for Main Menu"

L.KEYBIND_TOOLTIP1 = "\nHit a key to bind it to"
L.KEYBIND_TOOLTIP2 = "Left-Click to |cfff00000LOCK|r this %s's bindings\n\nRight-Click to make this %s's bindings a |cff00ff00PRIORITY|r bind\n\nHit |cfff00000ESC|r to clear this %s's current binding(s)"
L.KEYBIND_TOOLTIP3 = "Current Binding(s):"

L.EDITFRAME_EDIT = "edit"

L.EMPTY_BUTTON = "Empty Button"
L.EDIT_BINDINGS = "Edit Bindings"
L.KEYBIND_NONE = "none"

L.BINDFRAME_BIND = "bind"
L.BINDFRAME_LOCKED = "locked"
L.BINDFRAME_PRIORITY = "priority"
L.BINDINGS_LOCKED	= "This button's bindings are locked.\nLeft-Click button to unlock."
L.BINDER_NOTICE = "Neuron Key Binder\n|cffffffffThe Original Mouseover Binding System|r\nDeveloped by Maul"

L.OFF = "Off"
L.ALPHAUP_BATTLE = "Combat"
L.ALPHAUP_MOUSEOVER = "Mouseover"
L.ALPHAUP_BATTLEMOUSE = "Combat+Mouseover"
L.ALPHAUP_RETREAT = "Retreat"
L.ALPHAUP_RETREATMOUSE = "Retreat+Mouseover"

L.BAR_SHAPES = "\n1=Linear\n2=Circle\n3=Circle+One"
L.BAR_SHAPE1 = "Linear"
L.BAR_SHAPE2 = "Circle"
L.BAR_SHAPE3 = "Circle+One"
L.BAR_STRATAS = "\n1=BACKGROUND\n2=LOW\n3=MEDIUM\n4=HIGH\n5=DIALOG"
L.BAR_ALPHA = "Alpha value must be between zero(0) and one(1)"
L.BAR_ARCSTART = "Arc start must be between 0 and 359"
L.BAR_ARCLENGTH = "Arc length must be between 0 and 359"
L.BAR_COLUMNS = "Enter a number of desired columns for the bar higher than zero(0)\nOmit number to turn off columns"
L.BAR_PADH = "Enter a valid number for desired horizontal button padding"
L.BAR_PADV = "Enter a valid number for desired vertical button padding"
L.BAR_PADHV = "Enter a valid number to increase/decrease both the horizontal and vertical button padding"
L.BAR_XPOS = "Enter a valid number for desired x position offset"
L.BAR_YPOS = "Enter a valid number for desired y position offset"

L.BARLOCK_MOD = "Valid mod keys:\n\n|cff00ff00alt|r: unlock bar when the <alt> key is down\n|cff00ff00ctrl|r: unlock bar when the <ctrl> key is down\n|cff00ff00shift|r: unlock bar when the <shift> key is down"
L.TOOLTIPS = "Valid options:\n\n|cff00ff00enhanced|r: display additional ability info\n|cff00ff00combat|r: hide/show tooltips while in combat"
L.SPELLGLOWS = "Valid options:\n\n|cff00ff00default|r: use Blizzard default spell glow animation\n|cff00ff00alt|r: use alternate subdued spell glow animation"
L.TIMERLIMIT_SET = "Timer limit set to %d seconds"
L.TIMERLIMIT_INVALID = "Invalid timer limit"

L.PETATTACK = "Attack"
L.PETFOLLOW = "Follow"
L.PETMOVETO = "Move To"
L.PETASSIST = "Assist"
L.PETDEFENSIVE = "Defensive"
L.PETPASSIVE = "Passive"


L["Command"] = true
L.APPLY = "Apply"
L.CANCEL = "Cancel"
L.DONE = "Done"
L.CREATE_BAR = "Create New Bar"
L.DELETE_BAR = "Delete Current Bar"
L.SELECT_BAR_TYPE = "- Select Bar Type -"
L.CONFIRM = "- Confirm -"
L.CONFIRM_YES = "Yes"
L.CONFIRM_NO = "No"
L.GENERAL = "General Options"
L.BAR_STATES = "Bar States"
L.OBJECTS = "Object Editor"
L.MACRO = "Macro Data"
L.ACTION = "Action Data"
L.OPTIONS = "Options"

L.MACRO_NAME = "-macro name-"
L.MACRO_EDITNOTE = "Click here to edit macro note"
L.MACRO_USENOTE = "Use macro note as button tooltip"

L.COUNT = "Count"
L.SEARCH = "Search"
L.CUSTOM_ICON = "Custom Icon"
L.PATH = "path"

L.AUTOHIDE = "Auto Hide"
L.SHOWGRID = "Show Grid"
L.SNAPTO = "Snap To"
L.HIDDEN = "Hidden"
L.UPCLICKS = "Up Clicks"
L.DOWNCLICKS = "Down Clicks"
L.MULTISPEC = "Multi Spec"
L.SPELLGLOW = "Spell Alerts"
L.SPELLGLOW_DEFAULT = " - Default Alert"
L.SPELLGLOW_ALT = " - Subdued Alert"
L.LOCKBAR = "Lock Actions"
L.LOCKBAR_SHIFT = " - Unlock on SHIFT"
L.LOCKBAR_CTRL = " - Unlock on CTRL"
L.LOCKBAR_ALT = " - Unlock on ALT"
L.TOOLTIPS_OPT = "Enable Tooltips"
L.TOOLTIPS_ENH = " - Enhanced"
L.TOOLTIPS_COMBAT = " - Hide in Combat"

L.PRESET_STATES = "Preset Action States"
L.CUSTOM_STATES = "Custom Action States"


L.REMAP = "Select a stance to remap:"
L.REMAPTO = "Remap selected stance to:"


L.SCALE = "Scale"
L.ALPHA = "Alpha"
L.ALPHAUP = "Alpha Up"
L.ALPHAUP_SPEED = "A/U Speed"
L.STRATA = "Strata"
L.SHAPE = "Shape"
L.HPAD = "Horiz Pad"
L.VPAD = "Vert Pad"
L.HVPAD = "H + V Pad"
L.COLUMNS = "Columns"
L.ARCSTART = "Arc Start"
L.ARCLENGTH = "Arc Length"

L.BINDTEXT = "Bind Text"
L.MACROTEXT = "Macro Text"
L.COUNTTEXT = "Count Text"
L.RANGEIND = "Range Ind"
L.CDTEXT = "Cooldown Text"
L.CDALPHA = "Cooldown Alpha"
L.AURATEXT = "Aura Watch Text"
L.AURAIND = "Aura Watch Ind"

L.POINT = "Point"
L.XPOS = "X Pos"
L.YPOS = "Y Pos"

L.BOUND_SPELL_KEYBIND = "Enable Spell Binding Mode"
L.BOUND_TOGGLE_SPELL_KEYBIND = "Toggle Spell Binding Mode"
L.BOUND_MACRO_KEYBIND = "Enable Macro Binding Mode"
L.BOUND_TOGGLE_MACRO_KEYBIND = "Toggle Macro Binding Mode"


L.OPTIONS_BLIZZBAR = "Show Blizzard's Action Bar"
L.OPTIONS_ANIMATE = "Enable Neuron's Orb Animation"
L.OPTIONS_DRAENORBAR = "Show the Draenor Garrison Action Icon"

L.BAR_VISABLE_STATES = "Bar Visibility Toggles"
L.TARGET = "Target"
L.TARGET1 = "Has Target"
L.TARGET0 = "No Target"
L.INDOORS = "Indoors"
L.OUTDOORS = "Outdoors"
L.MOUNTED = "Mounted"
L.FLYING = "Flying"
L.RESTING = "Resting"
L.SWIMMING = "Swimming"
L.HARM = "Harm"
L.HELP = "Help"
L.GUI_SPEC1 = "Display button for spec 1"
L.GUI_SPEC2 = "Display button for spec 2"
L.GUI_SPEC3 = "Display button for spec 3"
L.GUI_SPEC4 = "Display button for spec 4"


L.SPELL_TARGETING_OPTIONS = "Spell Target Options"

L.SPELL_TARGETING_SELF_CAST_MODIFIER = "Self-Cast by modifier"
L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE = "Toggle the use of the modifier-based self-cast functionality."
L.SPELL_TARGETING_SELF_CAST_MODIFIER_SELECT = "Select the Self-Cast Modifier"

L.SPELL_TARGETING_FOCUS_CAST_MODIFIER ="Focus-Cast by modifier"
L.SPELL_TARGETING_FOCUS_CAST_MODIFIER_TOGGLE = "Toggle the use of the modifier-based focus-cast functionality."
L.SPELL_TARGETING_FOCUS_CAST_MODIFIER_SELECT = "Select the Focus-Cast Modifier"

L.SPELL_TARGETING_SELF_CAST_RIGHTCLICK = "Right-click Self-Cast"
L.SPELL_TARGETING_SELF_CAST_RIGHTCLICK_TOGGLE = "Toggle the use of the right-click self-cast functionality."

L.SPELL_TARGETING_MOUSEOVER_CAST = "Mouse-Over Casting"
L.SPELL_TARGETING_MOUSEOVER_CAST_MODIFIER_TOGGLE = "Toggle the use of the modifier-based mouse-over cast functionality."
L.SPELL_TARGETING_MOUSEOVER_CAST_MODIFIER_SELECT = "Select a modifier for Mouse-Over Casting"
L.SPELL_TARGETING_MOUSEOVER_CAST_MODIFIER = "Mouse-Over Casting Modifier"

L.SPELL_TARGETING_SELF_CAST_RIGHTCLICK_SELECT = "Select the Self-Cast Modifier"

L.SPELL_TARGETING_MODIFIER_NONE_REMINDER = "\"None\" as modifier for Self & Focus Casting means its disabled. \nFor Mouse-Over Casting it means its always active, and no modifier is required."

L.ZONEABILITY_BAR_BORDER = "Show Bar Border"

L.XP_BAR = "XP Bar"
L.REP_BAR = "Rep Bar"
L.CAST_BAR = "Cast Bar"
L.MIRROR_BAR = "Mirror Bar"
L.STATUSBAR_BAR = "Undefined Status Bar"

L.TRACK_XP = "Track Character XP"
L.TRACK_AP = "Track Artifact Power"
L.TRACK_HONOR = "Track Honor Points"

L.WIDTH ="Width"
L.HEIGHT = "Height"
L.BARFILL = "Bar Fill"
L.BORDER = "Border"
L.ORIENT = "Orientation"

L.CENTER_TEXT = "Center Text"
L.LEFT_TEXT = "Left Text"
L.RIGHT_TEXT = "Right Text"
L.MOUSE_TEXT = "Mouseover Text"
L.TOOLTIP_TEXT = "Tooltip Text"

L.UNIT_WATCH = "Unit"
L.CAST_ICON = "Cast Icon"

L.TEXT_BLANK = "None"
L.TEXT_SPELL = "Spell"
L.TEXT_TIMER = "Timer"
L.TEXT_CURRNEXT = "Current/Next"
L.TEXT_RESTED = "Rested Levels"
L.TEXT_PERCENT = "Percent"
L.TEXT_BUBBLES = "Bubbles"
L.TEXT_FACTION = "Faction & Standing"
L.TEXT_TYPE = "Type"

L.AUTO_SELECT = "Auto Select"

L.BARFILL_DEFAULT = "Default"
L.BARFILL_CONTRAST = "Contrast"
L.BARFILL_CARPAINT = "Carpaint"
L.BARFILL_GEL = "Gel"
L.BARFILL_GLASSED = "Glassed"
L.BARFILL_SOFT = "Soft"
L.BARFILL_VELVET = "Velvet"

L.BORDER_TOOLTIP = "Tooltip"
L.BORDER_SLIDER = "Slider"
L.BORDER_DIALOG = "Dialog"
L.BORDER_NONE = "None"

L.ORIENT_HORIZ = "Horizontal"
L.ORIENT_VERT = "Vertical"





------------------------------------------------------------
----------------------FAQ Strings---------------------------
------------------------------------------------------------

L.FAQ_TITLE = "F.A.Q."
L.FAQ_TITLE_LONG = "Frequently Asked Questions"
L.FAQ = [[
|cffffd200Neuron F.A.Q:|r

Below you will find answers to various questions that may arise as you use Neuron. Though please note that not all answers may be found here.

For questions not answered here, please direct them here:
|cff33c7ff https://mods.curse.com/addons/wow/279283-neuron |r

Further, if you encounter any bugs or missing features, please direct all inquiries here:
|cff33c7ff https://github.com/brittyazel/Neuron/issues |r

The source code can be found here:
|cff33c7ff https://github.com/brittyazel/Neuron |r

Thank you again for using Neuron.

]]

L.CHANGELOG_TITLE = "Changelog"
L.CHANGELOG = [[
|cffffd200Changelog:|r

Neuron 0.9.0 Update Changes:

 -Initial release

]]

L.FAQ_BAR_CONFIGURE_TITLE = "Bar Configuration"
L.FAQ_BAR_CONFIGURE = [[
|cffffd200Bar Editor Mode|r
To enter the Bar Editor, left click on the NEURON icon or type "/neuron config" into the chat window. You will know that the mode is enabled because any hidden bars (IE the Pet or Extra Action Bars) will be displayed and the bars will display a highlight & name on mouse over.

To exit the Bar Editor Mode, left click the NEURON icon, enter the text line command, or hit the Escape key. Once you leave this mode, any bars set to hidden will disappear once again.

|cffffd200Bar Configuration Menu|r
To open the Bar Configuration Menu, right click on any bar when the Bar Editor Mode is enabled. The first time the menu is opened it will be on the general options tab. If it is opened a second time after being closed, it will open to the last displayed tab.
]]

L.FAQ_BAR_CONFIGURE_GENERAL_OPTIONS_TITLE = "General Options"
L.FAQ_BAR_CONFIGURE_GENERAL_OPTIONS = [[
|cffffd200Bar Listing Section|r
To the far left of the menu there will be a section that lists all of the bars that have been created. Clicking on a name will select that bar and update the menu to display the options for the selected bar.

|cffffd200Bar Name Field|r
To the right of the Bar Listing, there is a text field that displays the name of the currently selected bar in white. You can rename the bar by clicking in the text field and editing the text. To save any changes press the Enter button when finished.

|cffffd200Bar Display Options|r
Under the Bar Name Field are the display options for the bar. These options allow you to change how the bar will be displayed.

|cffffd200Auto Hide:|r   When enabled, then the bar will automatically be hidden until you mouse over it again.
|cffffd200Show Grid:|r  When enabled, empty grid boxes on a bar will be displayed.
|cffffd200Snap To:|r  When enabled, repositioning a bar close to another bar will cause it to snap to so it will be centered with the other bar.
|cffffd200Up Clicks:|r  When selected, actions will trigger when the bound key is released.
|cffffd200Down Clicks:|r  When selected, actions will trigger when the bound key is pressed.
|cffffd200Multi Spec:|r  When enabled, the bar will automatically swap when your character changes spec.
|cffffd200Hidden:|r  When selected, the bar will be completely hidden. The only way to see the bar is to be in the edit mode. If a bar is set to be hidden, it will have a red tint to it when shown in the edit mode.
|cffffd200Lock Actions:|r  When enabled, you will no longer be able to drag items from the bars.
|cffffd200Unlock on <Shift, Ctrl, Alt> :|r  When Lock Actions is enabled, these options will be shown. Selecting any of these options will allow you to drag items from locked bars when the corresponding key is held.
|cffffd200Enable Tooltips:|r  When enabled, tooltips will be shown when you mouse over an item on the bar.
|cffffd200Enhanced:|r  If tooltips are enabled, this option will be displayed. If selected, then enhanced tooltips will be shown if available.
|cffffd200Hide In Combat:|r  If tooltips are enabled, this option will be displayed. If selected, then all tooltips will be hidden while a player is in combat.

|cffffd200Bar Layout Options|r
To the left of the Bar Display Options is the Bar Layout options. These settings give you the ability to change the layout of the bars.

|cffffd200Scale:|r This sets the scale of the bar. The default value is 1. Changing this to a smaller number will shrink the bar, while increasing the number will make the bar get larger.
|cffffd200Shape:|r Changes the button layout of the bar.
|cffffd200Columns:|r Will only be displayed when Linear is selected in the Shape selector. Default is Off. Increasing the count will divide the number of buttons on a bar into the entered number of columns.
|cffffd200Arc Start:|r  Will only be displayed when one of the Circle options is selected in the Shape selector. Sets the current bar's starting arc location (in degrees).
|cffffd200Arc Length:|r  Will only be displayed when one of the Circle options is selected in the Shape selector.  Sets the current bar's arc length (in degrees).
|cffffd200Horizontal Pad:|r Sets the current bar's horizontal padding.
|cffffd200Vertical Pad:|r Sets the current bar's vertical padding.
|cffffd200H+V Pad:|r Adjust both horizontal and vertical padding of the current bar incrementally.
|cffffd200Strata:|r Changes the strata that the bar will be shown on. The lower the strata, then the more likely other items may get displayed over it.
|cffffd200Alpha:|r Changes the transparency of a bar.
|cffffd200Alpha up:|r Choosing one of these options will cause a bar's transparency setting to be temporarily disabled when the chosen action occurs.
|cffffd200A/U Speed:|r This is how fast a bar's transparency will change when the Alpha Up action occurs.
|cffffd200X Pos:|r Changes the current bar's horizontal axis position.
|cffffd200Y Pos:|r Changes tje current bar's vertical axis position

|cffffd200Create Bar Button|r
At the bottom left of the option menu is the Create Bar Button. Use this button to add additional bars. Once selected, you will be prompted to choose what type of bar to create. After you have selected a type, the new bar will appear on screen and in the Bar Listing Section. Newly created bars will have a button count of 0.

|cffffd200Button Count & Add/Remove Button Arrows|r
At the bottom center of the option menu is the current count of how many buttons the selected bar has. On either side are arrows that when clicked will increase or decrease the button count.

|cffffd200Delete Current Bar|r
At the bottom left of the option menu is the Delete Current Bar Button. When pressed, you will be given a Yes/No choice to confirm the deletion of the currently selected bar. If you select Yes, the bar will be deleted and removed from the screen & listing. This option cannot be undone.
]]



L.FAQ_BAR_CONFIGURE_BAR_STATES_TITLE = "Bar States"

L.FAQ_BAR_CONFIGURE_BAR_STATES = [[
|cffffd200Bar States Selector|r
The Bar States options allows for custom states and visibility triggers to be added to a bar.  A bar state is what items are currently shown on it. Adding additional states will allow you to automatically change what is displayed when a set state is triggered.  The default state is called the home state.

|cffffd200Preset Action States|r

|cffffd200Paged:|r  When this is selected you can set 6 different pages of buttons.  The ability to switch between the pages is via the game's key binding settings.  The settings are Next & Previous Action Bar found under the Action Bar section.
|cffffd200Stance:|r  This option is only available if a character has different stances available.  When selected, switching stances will change the displayed buttons.
|cffffd200Pet:|r  When this is selected you can have the bar change whenever a character gains control of a pet.

|cffffd200Custom Action States|r
Neuron allows you to create your own custom bar states.  This is done by entering the desired state conditions, separated by a semicolon.  If you enter an improperly formatted state, an error message will be displayed in the chat window. It is advised not to use any Preset Action States when using custom states.  Custom Actions state can be formed by using the majority of the default game macro conditionals, with "no" being added to the front of the conditional to check for a false state.  IE [nocombat]

Example:  [actionbar:1];[stance:1];[stance3,stealth];[mounted]

|cffffd200Bar Visibility Toggles|r
These options allow you to customize when a bar should be displayed or hidden.  If a selection has a green mark next to it, then the bar will be shown when that condition is met.  By unselecting the option, the bar will be hidden if the condition is met.
]]



L.FAQ_BAR_CONFIGURE_SPELL_TARGET_TITLE = "Spell Target Options"
L.FAQ_BAR_CONFIGURE_SPELL_TARGET = [[
|cffffd200Spell Target Options|r
Spell target options allow you to automatically add certain cast modifiers to spells added to the bar.  Only spells dragged to the bar from the spell book will have these modifiers added.  A way to check to see if a spell will be affected is to look at the button using the macro editor.  If the macro has "#autowrite" at the beginning, then it can use the targeting options.

|cffffd200Self-Cast by Modifier:|r  When enabled, any spell cast while holding the selected modifier key will try to be cast on your character. Note the selected modifier for this setting is global and will be the same for every bar.  Changing it on one bar will change it for all.

|cffffd200Focus-Cast by modifier:|r  When enabled, any spell cast while holding the selected modifier key will try to be cast on your character's focus target. Note the selected modifier for this setting is global and will be the same for every bar.  Changing it on one bar will change it for all.

|cffffd200Right-Click Self-cast:|r When enabled, any spell cast by right-clicking on the button will try to be cast on your character

|cffffd200Mouse-Over Casting:|r  When enabled, any spell cast while holding the selected modifier key will try to be cast on the mob that the mouse cursor is currently over.  If the modifier for this option is set to "None" then it will always be on.]]


L.FLYOUT = "Flyout"
L.FLYOUT_FAQ = [[
|cffffd200Flyout Menus|r

Neuron allows for the creation of flyout menus of spells, items or companions. It accomplishes this by adding a new macro command and building the menu based on several options. The following are the instructions on how to go about making a custom flyout menu via the NEURON Button Macro Editor:

Format -  /flyout <type>:<keyword>:<shape>:<flyout anchor point>:<macro button anchor point>:<columns|radius>:<click|mouse>:<show/hide flyout arrow>


Types: Use as many comma-delimited types as you want (ex: "spell, item")

Keyword: Use as many comma-delimited keywords as you want (ex: "quest, potion, blah, blah, blah")
    Use ! in front of a keyword to exclude anything containing that keyword (ex: "!hearthstone")

Available Types & Keywords:  Note: Special Keywords such as Any or Favorite need to start with a Capitol letter.

item:id or partial name
Add an item by its item:id or all items in your bags or worn that contain the partial name.
Examples: item:1234, item:Bandage, item:Ore

spell:id or partial name
Add a spell by its numerical id or all spells that contain the partial name.
Examples: spell:1234, spell:Shout, spell:Polymorph

mount:"Flying", "Land", "Favorite", "FFlying", "FavLand" or partial name
Add all flying, land, favorite, favorite flying, favorite land mounts or mounts that contain the partial name.
Examples: mount:flying, mount:Raptor, mount:favflying

companion:"Favorite", "Any" or partial name
Adds favorite pets, all pets or pet that contain the partial name.
Examples: companion:Crash, companion:favorite, companion:any

type:ItemType
Add all items that contain the keyword in one of its type fields. See www.wowpedia.com/ItemType for a full list.
Examples: type:Quest, type:Food, type:Herb, type:Leather

profession:"Primary", "Secondary", "Any" or partial name
Adds all primary professions, secondary professions or any professions.
Examples: profession:Primary, profession:Any, profession:Herb

fun:"Favorite", "Any" or partial name
Adds favorite toys, all toys or toys that contain the partial name.
Examples: toy:Crash, toy:favorite, toy:any


Shapes:
    linear
    circular

Flyout Anchor Point is going to be the anchor point on first button of the flyout and influences the direction it goes. IE if you set it "BOTTOM" then the flyout will be anchored on the bottom row and display the rest of the buttons in a upward direction.

Macro Button Anchor Point is where the flyout will appear in relation to button the macro is in and determines what side of the macro the little flyout indicator arrow will be on if enabled. IE if you set it to RIGHT then the indicator will be on the right side and the flyout will be displayed to the right of the macro button.

Points:
    left
    right
    top
    bottom
    topleft
    topright
    bottomleft
    bottomright
    center


Colums/Radius:
    Any number.  For a Linear style this will be how many columns the flyout will have.  For a Circular style, thiw will be how wide the circle will be.

Click/Mouse:
    click: Displays the flyout when the button is clicked.
    mouse: Displays the flyout on mouse-over.

Show/hide flyout arrow
    show: Displays the flyout indicator arrow
    hide: Hides the indicator arrow.


Examples -

/flyout type:trinket:linear:right:left:6:click:show
This will show all trinkets in a 6 column flyout that displays on a button click

/flyout mount:invincible, phoenix, !dark:circular:center:center:15:mouse:hide
This will display any mounts with invincible & phoenix in the title excluding mounts with the word dark

/flyout companion:Favorite:linear:right:left:4:click:show
This will dislay any companions that are marked as favorite

/flyout spell, item:heal:linear:right:left:4:click:show
This will show all items & spells that have "heal" in the name

Most options may be abbreviated -
/flyout i:bandage:c:c:c:15:c:h is the same as /flyout item:bandage:circular:center:center:15:click:hide
]]