# Neuron

Neuron is a full featured action Bar addon for [World of Warcraft: Battle for Azeroth](https://worldofwarcraft.com/en-us/), updated for Patch 8.1

## Manual Install:
I do not recommend downloading this addon directly from Github, as there are CurseForge packaging modifications made the the addon upon release. These modifications include updating all included libraries to their latest release versions and pulling in all of the crowd sourced localizations. I have made an effort to pull in periodic samplings of these, but what you will find in the packaged versions on CurseForge or WowInterface will be much more up to date.


## Translating
The efforts to translate Neuron into many languages is a community project, and it could use your help!

Head **[here](https://wow.curseforge.com/projects/neuron/localization)** to start translating.

## Download:
The addon can be downloaded at these places:
* **[Curse](https://www.curseforge.com/wow/addons/neuron)** 
* **[Curseforge](https://wow.curseforge.com/projects/neuron)**
* **[WowInterface](https://www.wowinterface.com/downloads/info10636-Neuron.html)**

## Theme Support:

Neuron inherits all theming courtesy of the **[Masque](https://mods.curse.com/addons/wow/masque "Masque")** addon. Neuron has full Masque compatibility, and the theming options found in Masque are quite in-depth, not to mention the robust portfolio of skins made to support Masque. In short, you can make your bars look any way you like!


## Features:
* Neuron features an unlimited number of macros. You can create as many bars/buttons as you want/need per character!
* Are you a clicker extraordinaire? As many buttons on the screen you want where you want, when you want!
* Macros the size of Texas! Up to 1024 characters in length!
* Maul's unique mouse-over key-binding system - where the mouse-over binding system was born!
* Many other of the favorite desired bar addon features and then some!
* And, last but not least, **MASQUE support!**


## Graphical Editor:
Neuron contains a graphical bar editor that allows for nearly endless customization to bar shape, size, orientation, and much more! Further, Neuron has neither the limitations on max number of bars nor on the max number of buttons per bar, as you might find in addons such as Bartender4 or Dominoes. 

If the command line is your thing, all of the options found in the graphical bar editor can also be set using the below command structure.


## Commands:
Type /neuron alone to display a list of available commands, which are:

* **menu:** Toggle the main menu
* **create:** Create a blank bar
* **delete:** Delete the currently selected bar
* **config:** Toggle configuration mode for all bars
* **add:** Adds buttons to the currently selected bar (add or add #)
* **remove:** Removes buttons from the currently selected bar (remove or remove #)
* **edit:** Toggle edit mode for all buttons
* **bind:** Toggle binding mode for all buttons
* **scale:** Scale a bar to the desired size.
* **snapto:** Toggle SnapTo for current bar
* **autohide:** Toggle AutoHide for current bar
* **shape:** Change current bar's shape
* **name:** Change current bar's name
* **strata:** Change current bar's frame strata
* **alpha:** Change current bar's alpha (transparency)
* **alphaup:** Set current bar's conditions to 'alpha up'
* **arcstart:** Set current bar's starting arc location (in degrees)
* **arclen:** Set current bar's arc length (in degrees)
* **columns:** Set the number of columns for the current bar
* **padh:** Set current bar's horizontal padding
* **padv:** Set current bar's vertical padding
* **padhv:** Adjust both horizontal and vertical padding of the current bar incrementally
* **showgrid:** Toggle the current bar's showgrid flag
* **x:** Change current bar's horizontal axis position
* **y:** Change current bar's vertical axis position
* **state:** Toggle states for the current bar (/neuron state &lt;state&gt;). Type /neuron statelist for vaild states
* **statelist:** Print a list of valid states
* **load:** Load a profile
* **lock:** Lock buttons

## Development:
Neuron development is all done using the **[Intellij IDEA](https://www.jetbrains.com/idea/download/#section=windows)** Community Edition IDE and with the assistance of the fantastic **[EmmyLua](https://plugins.jetbrains.com/plugin/9768-emmylua)** plugin. Detailed instructions on how I set up my development environment can be found **[here](https://github.com/Ellypse/IntelliJ-IDEA-Lua-IDE-WoW-API/wiki)**. Likewise, in game I make use of the addons **[BugGrabber](https://www.curseforge.com/wow/addons/bug-grabber)**, **[BugSack](https://www.curseforge.com/wow/addons/bugsack)**, and **[ViragDevTool](https://www.curseforge.com/wow/addons/varrendevtool)**, and in game tools such as **"/eventtrace"**

Development of Neuron requires an understanding of **[Lua syntax](https://www.lua.org/manual/5.3/manual.html)**, the **[WoW API](https://wow.gamepedia.com/World_of_Warcraft_API)**, and a working understanding of Git/GitHub. If you want to help with Neuron's development, I suggest: 
1. Forking the project on [GitHub](https://github.com/brittyazel/Neuron) (some people use [GitHub Desktop](https://desktop.github.com/), but I personally use [GitKraken](https://www.gitkraken.com/))
2. Setting up your aforementioned development environment
3. Backing up your WTF folder
4. [Symlinking](https://www.howtogeek.com/howto/16226/complete-guide-to-symbolic-links-symlinks-on-windows-or-linux/) your cloned Neuron git folder to your "World of Warcraft>\_retail_>Interface>Addons" folder
5. Making your first change

A good place to start coding is by looking through the **[issue tracker](https://github.com/brittyazel/Neuron/issues)** to find any issues marked as "[good first issue](https://github.com/brittyazel/Neuron/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22)". All code change submissions should come in the form of pull requests, so that I can review it and provide comments before merging.



## Credits:
Translators:
* German: Aszkarath
* French: Cinedelle
* Brazilian Portuguese: Alanbre20
* Russian: Hubbotu

**Disclaimer:**

Neuron is a fork of the amazing *Ion Action Bars* addon started by Connor Chenoweth aka **Maul**, for World of Warcraft Legion and onwards. All credit for the bulk of this addon should go to him accordingly, along with SLOKnightFall for his maintainership throughout the years.
**I, Soyier, take no credit for the idea or implementation of this addon prior to my adoption of the code in the Fall quarter of 2017.**
