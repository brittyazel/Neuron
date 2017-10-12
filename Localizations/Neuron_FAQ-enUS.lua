--Neuron, a World of Warcraft� user interface addon.
--Copyright� 2006-2014 Connor H. Chenoweth, aka Maul - All rights reserved.

--English spelling validated by Eledryn

local L = LibStub("AceLocale-3.0"):NewLocale("Neuron", "enUS", true)

L.LINE1 = "TEST"
L.LINE2 = "TEST"
L.LINE3 = "TEST"
L.LINE4 = "TEST"
L.LINE5 = "TEST"

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
