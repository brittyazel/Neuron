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

L["How to use"] = true
L["Command"] = true
L["Option"] = true

L["No bar selected or command invalid"] = true

L["Custom_Option"] = "For custom states, add a desired state string (|cffffff00/neuron state custom <state string>|r) where <state string> is a semicolon seperated list of state conditions"


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

L["No Stealth"] = true
L["Stealth"] = true
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

L["Custom States"] = true


---class specific state names
L["Caster Form"] = true
L["Healer Form"] = true
L["Melee"] = true
L["Shadow Dance"] = true

L["Left-Click to Configure Bars"] = true
L["Right-Click to Edit Buttons"] = true
L["Middle-Click or Alt-Click to Edit Key Bindings"] = true
L["Shift-Click for Main Menu"] = true


L["Keybind_Tooltip_1"] = "\nHit a key to bind it to"
L["Keybind_Tooltip_2"] = "Left-Click to |cfff00000LOCK|r this %s's bindings\n\nRight-Click to make this %s's bindings a |cff00ff00PRIORITY|r bind\n\nHit |cfff00000ESC|r to clear this %s's current binding(s)"
L["Keybind_Tooltip_3"] = "Current Binding(s):"


L["edit"] = true
L["Empty Button"] = true
L["Edit Bindings"] = true
L["None"] = true

L["bind"] = true
L["locked"] = true
L["priority"] = true
L["Bindings_Locked_Notice"]	= "This button's bindings are locked.\nLeft-Click button to unlock."
L["Keybind_Credits"] = "Neuron Key Binder\n|cffffffffThe Original Mouseover Binding System|r\nDeveloped by Maul"

L["Off"] = true
L["Combat"] = true
L[ "Mouseover"] = true
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

L["Bar_Lock_Modifier_Instructions"] = "Valid mod keys:\n\n|cff00ff00alt|r: unlock bar when the <alt> key is down\n|cff00ff00ctrl|r: unlock bar when the <ctrl> key is down\n|cff00ff00shift|r: unlock bar when the <shift> key is down"
L["Tooltip_Instructions"] = "Valid options:\n\n|cff00ff00enhanced|r: display additional ability info\n|cff00ff00combat|r: hide/show tooltips while in combat"
L["Spellglow_Instructions"] = "Valid options:\n\n|cff00ff00default|r: use Blizzard default spell glow animation\n|cff00ff00alt|r: use alternate subdued spell glow animation"

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

L["Auto Hide"] = true
L["Show Grid"] = true
L["Snap To"] = true
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
L["Show Bar Border"] = true

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

L["Bind Text"] = true
L["Macro Text"] = true
L["Count Text"] = true
L["Range Indicator"] = true
L["Cooldown Text"] = true
L["Cooldown Alpha"] = true
L["Aura Watch Text"] = true
L["Aura Watch Indicator"] = true

L["Point"] = true
L["X Position"] = true
L["Y Position"] = true

--[[L["Enable Spell Binding Mode"] = true
L["Toggle Spell Binding Mode"] = true
L["Enable Macro Binding Mode"] = true
L["Toggle Macro Binding Mode"] = true]]

L["Display the Blizzard Bar"] = true
L["Shows / Hides the Default Blizzard Bar"] = true

L["Animate Icon"] = true
L["Toggles the Animation of the Neuron Orb Icon"] = true

L["Display Minimap Button"] = true
L["Toggles the minimap button."] = true

L["Bar Visibility Toggles"] = true
L["Target"] = true
L["Has Target"] = true
L["No Target"] = true
L["Indoors"] = true
L[ "Outdoors"] = true
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

L["Track Character XP"] = true
L["Track Artifact Power"] = true
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
L["Faction & Standing"] = true
L["Type"] = true

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





------------------------------------------------------------
----------------------FAQ Strings---------------------------
------------------------------------------------------------

L["F.A.Q."] = true
L["Frequently Asked Questions"] = true
L["FAQ_Intro"] = [[
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

L["Changelog"] = true

L["Changelog_Latest_Version"] = [[
|cffffd200Changelog:|r

Neuron 0.9.0 Update Changes:

 -Initial release

]]

L["Bar Configuration"] = true
L["Bar_Configuration_FAQ"] = [[
|cffffd200Bar Editor Mode|r
To enter the Bar Editor, left click on the NEURON icon or type "/neuron config" into the chat window. You will know that the mode is enabled because any hidden bars (IE the Pet or Extra Action Bars) will be displayed and the bars will display a highlight & name on mouse over.

To exit the Bar Editor Mode, left click the NEURON icon, enter the text line command, or hit the Escape key. Once you leave this mode, any bars set to hidden will disappear once again.

|cffffd200Bar Configuration Menu|r
To open the Bar Configuration Menu, right click on any bar when the Bar Editor Mode is enabled. The first time the menu is opened it will be on the general options tab. If it is opened a second time after being closed, it will open to the last displayed tab.
]]

L["General Options"] = true
L["General_Bar_Configuration_Option_FAQ"] = [[
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



L["Bar States"] = true

L["Bar_State_Configuration_FAQ"] = [[
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



L["Spell Target Options"] = true
L["Spell_Target_Options_FAQ"]= [[

|cffffd200Spell Target Options|r
Spell target options allow you to automatically add certain cast modifiers to spells added to the bar.  Only spells dragged to the bar from the spell book will have these modifiers added.  A way to check to see if a spell will be affected is to look at the button using the macro editor.  If the macro has "#autowrite" at the beginning, then it can use the targeting options.

|cffffd200Self-Cast by Modifier:|r  When enabled, any spell cast while holding the selected modifier key will try to be cast on your character. Note the selected modifier for this setting is global and will be the same for every bar.  Changing it on one bar will change it for all.

|cffffd200Focus-Cast by modifier:|r  When enabled, any spell cast while holding the selected modifier key will try to be cast on your character's focus target. Note the selected modifier for this setting is global and will be the same for every bar.  Changing it on one bar will change it for all.

|cffffd200Right-Click Self-cast:|r When enabled, any spell cast by right-clicking on the button will try to be cast on your character

|cffffd200Mouse-Over Casting:|r  When enabled, any spell cast while holding the selected modifier key will try to be cast on the mob that the mouse cursor is currently over.  If the modifier for this option is set to "None" then it will always be on.]]


L["Flyout"] = true
L["Flyout_FAQ"] = [[
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