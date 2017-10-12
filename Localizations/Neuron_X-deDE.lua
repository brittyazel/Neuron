--Neuron, a World of Warcraft® user interface addon.
--Copyright© 2006-2014 Connor H. Chenoweth, aka Maul - All rights reserved.

-- German translations by:
-- http://www.curseforge.com/profiles/Murida/
-- http://www.curseforge.com/profiles/angel100780/

local AddOnFolderName, private = ...
-- See http://wow.curseforge.com/addons/neuron-status-bars/localization/
local L = _G.LibStub("AceLocale-3.0"):NewLocale("Neuron", "deDE", false)
if not L then return end
--@localization(locale="deDE", format="lua_additive_table", handle-unlocalized="comment")@


L.DEFAULT = "Default"

L.ACTION = "Aktionsinformationen" -- Needs review
L.ALPHA = "Alpha" -- Needs review
L.ALPHAUP = "Einblenden" -- Needs review
L.ALPHAUP_BATTLE = "Kampf"
L.ALPHAUP_BATTLEMOUSE = "Kampf+Mouseover"
L.ALPHAUP_MOUSEOVER = "Mouseover"
L.ALPHAUP_RETREAT = "Rückzug"
L.ALPHAUP_RETREATMOUSE = "Rückzug+Mouseover"
L.ALPHAUP_SPEED = "Einblendungsgeschwindigkeit" -- Needs review
L.ALT = "alt"
L.ALT0 = "Alt losgelassen"
L.ALT1 = "Alt gedrückt"
L.APPLY = "Anwenden" -- Needs review
L.ARCLENGTH = "Bogenlänge" -- Needs review
L.ARCSTART = "Bogenanfang" -- Needs review
L.AURAIND = "Aura Beobachtungsind." -- Needs review
L.AURATEXT = "Aura Beobachtungstext" -- Needs review
L.AUTOHIDE = "Automatisches Verbergen"
L.BAR_ALPHA = "Alpha Wert muss zwischen Null(0) und Eins(1) liegen"
L.BAR_ARCLENGTH = "Bogenlänge muss zwischen 0 und 359 liegen"
L.BAR_ARCSTART = "Bogenanfang muss zwischen 0 und 359 liegen"
L.BAR_COLUMNS = [=[Geben Sie die Anzahl größer als Null(0) der gewünschten Spalten für die Leiste ein
Weglassen, um auf Spalten zu verzichten]=]
L.BARLOCK_MOD = [=[Zulässige mod Tasten:

|cff00ff00alt|r: entsperre Leiste wenn <alt> Taste gedrückt
|cff00ff00ctrl|r: entsperre Leiste wenn <ctrl> Taste gedrückt
|cff00ff00shift|r: entsperre Leiste wenn <shift> Taste gedrückt]=]
L.BAR_PADH = "Geben Sie eine gültige Nummer für das gewünschte horizontale Tasten-padding ein"
L.BAR_PADHV = "Geben Sie eine gültige Nummer ein, um das horizontale und vertikale Tasten-padding zu erhöhen/senken"
L.BAR_PADV = "Geben Sie eine gültige Nummer für das gewünschte vertikale Tasten-padding ein"
L.BAR_SHAPE1 = "Gerade"
L.BAR_SHAPE2 = "Kreis"
L.BAR_SHAPE3 = "Kreis+Eins"
L.BAR_SHAPES = [=[1=Gerade
2=Kreis
3=Kreis+Eins]=]
L.BAR_STATES = "Leistenzustände" -- Needs review
L.BAR_STRATAS = [=[1=HINTERGRUND
2=NIEDRIG
3=MITTEL
4=HOCH
5=DIALOG]=]
L.BARTYPES_LINE = "Erzeugt eine Leiste für %s"
L.BARTYPES_TYPES = [=[     Typen -
]=]
L.BARTYPES_USAGE = [=[Gebrauch: |cffffff00/neuron create <Typ>|r
]=]
L.BAR_XPOS = "Gültige Zahl für das gewünschte x-Position Offset eingeben"
L.BAR_YPOS = "Gültige Zahl für das gewünschte y-Position Offset eingeben"
L.INSTALL_MESSAGE = [=[Danke, dass Sie Neuron installiert haben!!!

Neuron ist derzeit in einer "|cffffff00Betatest|r" Phase.

Leider habe ich es nicht geschafft, eine Release Version für Patch 5.0.4 fertig zu bekommen. Eine Release Version sollte allerdings bis zur Erweiterung Mists of Pandaria bereit sein!

Das bedeutet, dass nicht alle Features vorhanden sind und es Bugs geben könnte. Aber größtenteils ist Neuron in einem nutzbaren und stabilen Zustand.

Benutze Neuron im Moment nur, wenn es nicht stört, dass gelegentlich Bugs auftreten oder nicht alles machbar ist wie mit Macaroon =)

-Maul]=]
L.BINDER_NOTICE = [=[Neuron Tasten Zuweiser
|cffffffffDas Originale Mouseover Zuweisungssystem|r
Entwickelt von Maul]=] -- Needs review
L.BINDFRAME_BIND = "zuweisen" -- Needs review
L.BINDFRAME_LOCKED = "verriegelt" -- Needs review
L.BINDFRAME_PRIORITY = "Priorität" -- Needs review
L.BINDINGS_LOCKED = [=[Die Zuweisungen für diesen Knopf sind gesperrt.
Links-Klick auf den Knopf zum Entsperren.]=] -- Needs review
L.BINDTEXT = "Zuweisungstext" -- Needs review
L.CANCEL = "Abbruch" -- Needs review
L.CDALPHA = "Abklingzeiten Alpha" -- Needs review
L.CDTEXT = "Abklingzeiten Text" -- Needs review
L.COLUMNS = "Spalten" -- Needs review
L.COMBAT = "Kampf" -- Needs review
L.COMBAT0 = "kein Kampf" -- Needs review
L.COMBAT1 = "Kampf" -- Needs review
L.CONFIRM = "- Bestätigen -" -- Needs review
L.CONFIRM_NO = "Nein" -- Needs review
L.CONFIRM_YES = "Ja" -- Needs review
L.COUNT = "Anzahl" -- Needs review
L.COUNTTEXT = "Anzahl Beschriftung" -- Needs review
L.CREATE_BAR = "Erstelle neue Leiste" -- Needs review
L.CTRL = "STRG" -- Needs review
L.CTRL0 = "STRG losgelassen" -- Needs review
L.CTRL1 = "STRG gedrückt" -- Needs review
L.CUSTOM = "Anpassungen" -- Needs review
L.CUSTOM0 = "Eigene Zustände" -- Needs review
L.CUSTOM_ICON = "Eigenes Symbol" -- Needs review
L.CUSTOM_OPTION = [=[
Für eigene Zustände, fügen Sie den gewünschten Zustandstext ein (|cffffff00/neuron state custom <Zustandstext>|r) wobei <Zustandstext> eine durch Semikolons getrennte Liste von Bedingungen ist

|cff00ff00Beispiel:|r [actionbar:1];[stance:1];[stance3,stealth];[mounted]

|cff00ff00Hinweis:|r die erste Bedingung der Liste wird zum "Heimzustand". Wenn der Zustandsverwalter durcheinander sein sollte, nimmt er diesen Zustand als Standard.]=] -- Needs review
L.CUSTOM_STATES = "Eigene Aktionszustände" -- Needs review
L.DELETE_BAR = "Lösche aktuelle Leiste" -- Needs review
L.DONE = "Fertig" -- Needs review
L.DOWNCLICKS = "Klick" -- Needs review
L.DRUID_CASTER = "Normale Gestalt" -- Needs review
L.DRUID_PROWL = "Schleichen" -- Needs review
L.MULTISPEC = "Multi Spec" -- Needs review
L.EDIT_BINDINGS = "Zuweisungen bearbeiten" -- Needs review
L.EDITFRAME_EDIT = "bearbeiten" -- Needs review
L.EMPTY_BUTTON = "leerer Knopf" -- Needs review
L.EXTRABAR = "Zusatzleiste" -- Needs review
L.EXTRABAR0 = "keine Zusatzleiste" -- Needs review
L.EXTRABAR1 = "Zusatzleiste" -- Needs review
L.FISHING = "Angeln" -- Needs review
L.FISHING0 = "Keine Angelrute" -- Needs review
L.FISHING1 = "Angelrute" -- Needs review
L.GENERAL = "Allgemeine Einstellungen" -- Needs review
L.GROUP = "Gruppe" -- Needs review
L.GROUP0 = "keine Gruppe" -- Needs review
L.GROUP1 = "Gruppe: Schlachtzug" -- Needs review
L.GROUP2 = "Gruppe: Gruppe" -- Needs review
L.HIDDEN = "Versteckt" -- Needs review
L.HOMESTATE = "Heimzustand" -- Needs review
L.HPAD = "Horiz Pad" -- Needs review
L.HVPAD = "H + V Pad" -- Needs review
L.INVALID_INDEX = "Ungültiger Index" -- Needs review
L.NEURON = "Neuron" -- Needs review
L.KEYBIND_NONE = "keine" -- Needs review
L.KEYBIND_TOOLTIP1 = "Drücke eine Tase, um diese zuzuweisen" -- Needs review
L.KEYBIND_TOOLTIP2 = [=[Links-Klick zum |cfff00000SPERREN|r der Zuweisungen von %s

Rechts-Klick um aus dieser Zuweisung von %s eine |cff00ff00PRIORITÄTS|r Zuweisung zu machen

Drücke |cfff00000ESC|r um die aktuellen Zuweisungen von %s zu entfernen]=] -- Needs review
L.KEYBIND_TOOLTIP3 = "Derzeitige Zuweisung(en):" -- Needs review
L.LASTSTATE = "Sollte nicht gesehen werden!" -- Needs review
L.LOCKBAR = "Sperre Aktionen" -- Needs review
L.LOCKBAR_ALT = "- Entsperre mit ALT" -- Needs review
L.LOCKBAR_CTRL = "- Entsperre mit STRG" -- Needs review
L.LOCKBAR_SHIFT = "- Entsperre mit UMSCHALT" -- Needs review
L.MACRO = "Makro Daten" -- Needs review
L.MACRO_EDITNOTE = "Hier klicken, um Makro Notiz zu ändern" -- Needs review
L.MACRO_NAME = "-Macro Name-" -- Needs review
L.MACROTEXT = "Makro Text" -- Needs review
L.MACRO_USENOTE = "Makro Notiz als Tooltip verwenden" -- Needs review
L.MINIMAP_TOOLTIP1 = "Links-Klick um Leisten zu konfigurieren" -- Needs review
L.MINIMAP_TOOLTIP2 = "Rechts-Klick um Knöpfe zu bearbeiten" -- Needs review
L.MINIMAP_TOOLTIP3 = "Mittel-Klick oder Alt-Klick um Tastenzuweisungen zu bearbeiten" -- Needs review
L.OBJECTS = "Objekt Editor" -- Needs review
L.OFF = "Aus" -- Needs review
L.OPTIONS = "Einstellungen" -- Needs review
L.OVERRIDE = "Übergehen" -- Needs review
L.OVERRIDE0 = "Keine Übergehungsleiste" -- Needs review
L.OVERRIDE1 = "Übergehungsleiste" -- Needs review
L.PAGED = "mit Seiten" -- Needs review
L.PAGED1 = "Seite 1" -- Needs review
L.PAGED2 = "Seite 2" -- Needs review
L.PAGED3 = "Seite 3" -- Needs review
L.PAGED4 = "Seite 4" -- Needs review
L.PAGED5 = "Seite 5" -- Needs review
L.PAGED6 = "Seite 6" -- Needs review
L.PATH = "Pfad" -- Needs review
L.PET = "Begleiter" -- Needs review
L.PET0 = "Kein Begleiter" -- Needs review
L.PET1 = "Begleiter Existiert" -- Needs review
L.PETASSIST = "Assistieren" -- Needs review
L.PETATTACK = "Angriff" -- Needs review
L.PETDEFENSIVE = "Verteidigung" -- Needs review
L.PETFOLLOW = "Folgen" -- Needs review
L.PETMOVETO = "Bewegen zu" -- Needs review
L.PETPASSIVE = "Passiv" -- Needs review
L.POINT = "Punkt" -- Needs review
L.POSSESS = "Besitz" -- Needs review
L.POSSESS0 = "kein Besitz" -- Needs review
L.POSSESS1 = "Besitz" -- Needs review
L.PRESET_STATES = "Voreingestellte Aktionszustände" -- Needs review
L.PRIEST_HEALER = "Heilergestalt" -- Needs review
L.PROWL = "Schleichen" -- Needs review
L.RANGEIND = "Reichweiten Ind." -- Needs review
L.REACTION = "Reaktion" -- Needs review
L.REACTION0 = "Freundlich" -- Needs review
L.REACTION1 = "Feindlich" -- Needs review
L.REMAP = "Primärer Zustand zum Neuzuweisen" -- Needs review
L.REMAPTO = "Zustand zuweisen zu" -- Needs review
L.ROGUE_MELEE = "Nahkampf" -- Needs review
L.SCALE = "Skalierung" -- Needs review
L.SEARCH = "Suche" -- Needs review
L.SELECT_BAR = "Keine Leiste ausgewählt oder Befehl ungültig" -- Needs review
L.SELECT_BAR_TYPE = "- Wähle Leisten Typ -" -- Needs review
L.SHAPE = "Form" -- Needs review
L.SHIFT = "Umschalttaste" -- Needs review
L.SHIFT0 = "Umschalttaste losgelassen" -- Needs review
L.SHIFT1 = "Umschalttaste gedrückt" -- Needs review
L.SHOWGRID = "Zeige Raster" -- Needs review
L.SLASH1 = "/neuron" -- Needs review
L.SLASH_CMD1 = "Menü" -- Needs review
L.SLASH_CMD10 = "Einrasten" -- Needs review
L.SLASH_CMD10_DESC = "Einrasten für aktuelle Leiste umschalten" -- Needs review
L.SLASH_CMD11 = "AutoVerstecken" -- Needs review
L.SLASH_CMD11_DESC = "AutoVerstecken für aktuelle Leiste umschalten" -- Needs review
L.SLASH_CMD12 = "Verbergen" -- Needs review
L.SLASH_CMD12_DESC = "Umschalten, ob aktuelle Leiste immer sichtbar oder verborgen ist" -- Needs review
L.SLASH_CMD13 = "Form" -- Needs review
L.SLASH_CMD13_DESC = "Ändern der Form der aktuellen Leiste" -- Needs review
L.SLASH_CMD14 = "Name" -- Needs review
L.SLASH_CMD14_DESC = "Ändern des Namens der aktuellen Leiste" -- Needs review
L.SLASH_CMD15 = "Ebene" -- Needs review
L.SLASH_CMD15_DESC = "Ändert die Rahmenebene der aktuellen Leiste" -- Needs review
L.SLASH_CMD16 = "Alpha" -- Needs review
L.SLASH_CMD16_DESC = "Ändern des Alphawertes (Transparenz) der aktuellen Leiste" -- Needs review
L.SLASH_CMD17 = "AlphaUp" -- Needs review
L.SLASH_CMD17_DESC = "Setzt den Zustand der aktuellen Leiste auf 'alpha up'" -- Needs review
L.SLASH_CMD18 = "Bogenanfang" -- Needs review
L.SLASH_CMD18_DESC = "Setze die Bogenposition der aktuellen Leiste (in Grad)" -- Needs review
L.SLASH_CMD19 = "ArcLen" -- Needs review
L.SLASH_CMD19_DESC = "Setze die Bogenlänge der aktuellen Leiste (in Grad)" -- Needs review
L.SLASH_CMD1_DESC = "Öffne das Hauptmenü" -- Needs review
L.SLASH_CMD2 = "Erzeugen" -- Needs review
L.SLASH_CMD20 = "Spalten" -- Needs review
L.SLASH_CMD20_DESC = "Setze die Anzahl der Spalten für die aktuelle Leiste (für Form Mehrfachspalten)" -- Needs review
L.SLASH_CMD21 = "PadH" -- Needs review
L.SLASH_CMD21_DESC = "Setze das horizontale Padding der aktuellen Leiste" -- Needs review
L.SLASH_CMD22 = "PadV" -- Needs review
L.SLASH_CMD22_DESC = "Setze das vertikale Padding der aktuellen Leiste" -- Needs review
L.SLASH_CMD23 = "PadHV" -- Needs review
L.SLASH_CMD23_DESC = "Ändere das horizontale und vertikale Padding der aktuellen Leiste stufenweise" -- Needs review
L.SLASH_CMD24 = "X" -- Needs review
L.SLASH_CMD24_DESC = "Ändere die Position der aktuellen Leiste auf der horizontalen Achse" -- Needs review
L.SLASH_CMD25 = "Y" -- Needs review
L.SLASH_CMD25_DESC = "Ändere die Position der aktuellen Leiste auf der vertikalen Achse" -- Needs review
L.SLASH_CMD26 = "Zustand" -- Needs review
L.SLASH_CMD26_DESC = [=[Wechsle einen Aktionszustand für die Aktuelle Leiste (|cffffff00/neuron state <Zustand>|r).
    Gebe |cffffff00/neuron statelist|r ein für gültige Zustände]=] -- Needs review
L.SLASH_CMD27 = "Vis" -- Needs review
L.SLASH_CMD27_DESC = [=[Wechsle Sichtbarkeitszustand für die aktuelle Leiste (|cffffff00/neuron vis <Zustand> <index>|r)
|cffffff00<index>|r = "show" | "hide" | <num>.
Beispiel: |cffffff00/neuron vis paged hide|r versteckt alle mit Seiten
Beispiel: |cffffff00/neuron vis paged 1|r wechselt Sichtbarkeit wenn der Zustandsverwalter auf Seite 1 ist]=] -- Needs review
L.SLASH_CMD28 = "RasterZeigen" -- Needs review
L.SLASH_CMD28_DESC = "Wechselt das RasterZeigen flag der aktuellen Leiste" -- Needs review
L.SLASH_CMD29 = "Sperren" -- Needs review
L.SLASH_CMD29_DESC = "Schalte Leistensperre um. |cffffff00/lock <mod key>|r um umzuschalten, ob Fähigkeiten entfernt werden können während die Taste <mod key> gedrückt ist (Bsp: |cffffff00/lock shift|r)" -- Needs review
L.SLASH_CMD2_DESC = [=[Erzeuge eine leere Leiste des angegebenen Typs (|cffffff00/neuron create <Typ>|r)
    Gebe |cffffff00/neuron bartypes|r ein für eine Liste der verfügbaren Typen]=] -- Needs review
L.SLASH_CMD3 = "Löschen" -- Needs review
L.SLASH_CMD30 = "Tooltips" -- Needs review
L.SLASH_CMD30_DESC = "Schalte Tooltips für die Aktionsknöpfe der aktuellen Leiste um" -- Needs review
L.SLASH_CMD31 = "SpellGlow" -- Needs review
L.SLASH_CMD31_DESC = "Schalte Zauberaktivierungsanimationen der aktuellen Leiste um" -- Needs review
L.SLASH_CMD32 = "Zuweisungstext" -- Needs review
L.SLASH_CMD32_DESC = "Schalte Tastenzuweisungstext für die aktuelle Leiste um" -- Needs review
L.SLASH_CMD33 = "MakroText" -- Needs review
L.SLASH_CMD33_DESC = "Schalte Makronamen-Text für die aktuelle Leiste um" -- Needs review
L.SLASH_CMD34 = "Anzahlbeschriftung" -- Needs review
L.SLASH_CMD34_DESC = "Schalte Anzahlbeschriftung für die aktuelle Leiste um" -- Needs review
L.SLASH_CMD35 = "CDText" -- Needs review
L.SLASH_CMD35_DESC = "Schalte Abklingzeitzähler für die aktuelle Leiste um" -- Needs review
L.SLASH_CMD36 = "CDAlpha" -- Needs review
L.SLASH_CMD36_DESC = "Schalte die Transparenz eines Kopfes um, während Abklingzeit" -- Needs review
L.SLASH_CMD37 = "AuraText" -- Needs review
L.SLASH_CMD37_DESC = "Schalte Aurenbeobachtungsbeschriftung auf der aktuellen Leiste um" -- Needs review
L.SLASH_CMD38 = "AuraInd" -- Needs review
L.SLASH_CMD38_DESC = "Schalte Aurenindikatoren für Knöpfe auf der aktuellen Leiste um" -- Needs review
L.SLASH_CMD39 = "UpClick" -- Needs review
L.SLASH_CMD39_DESC = "Schalte um, ob Knöpfe auf der aktuellen Leiste auf loslassen der Maustaste reagieren sollen" -- Needs review
L.SLASH_CMD3_DESC = "Lösche die aktuell ausgewählte Leiste" -- Needs review
L.SLASH_CMD4 = "Konfiguration" -- Needs review
L.SLASH_CMD40 = "DownClick" -- Needs review
L.SLASH_CMD40_DESC = "Schalte um, ob Knöpfe auf der aktuellen Leiste auf Runterklicken reagieren sollen" -- Needs review
L.SLASH_CMD41 = "TimerLimit" -- Needs review
L.SLASH_CMD41_DESC = "Setze die minimale Zeit in Sekunden ab der Timer Beschriftungen angezeigt werden sollen" -- Needs review
L.SLASH_CMD42 = "StateList" -- Needs review
L.SLASH_CMD42_DESC = "Gibt eine Liste der gültigen Zustände aus" -- Needs review
L.SLASH_CMD43 = "BarTypes" -- Needs review
L.SLASH_CMD43_DESC = "Gibt eine Liste der verfügbaren Leistentypen aus" -- Needs review
L.SLASH_CMD44 = "BlizzBar" -- Needs review
L.SLASH_CMD44_DESC = "Schaltet Sichtbarkeit der Blizzard Aktionsleisten um" -- Needs review
L.SLASH_CMD45 = "VehicleBar" -- Needs review
L.SLASH_CMD45_DESC = "Schaltet Sichtbarkeit der Blizzard Fahrzeugleisten um" -- Needs review
L.SLASH_CMD4_DESC = "Wechselt Konfigurationsmodus für alle Leisten" -- Needs review
L.SLASH_CMD5 = "Add" -- Needs review
L.SLASH_CMD5_DESC = "Fügt Knöpfe zur aktuell ausgewählten Leiste hinzu (|cffffff00add|r oder |cffffff00add #|r)" -- Needs review
L.SLASH_CMD6 = "Remove" -- Needs review
L.SLASH_CMD6_DESC = "Entfernt Knöpfe der aktuell ausgewählten Leiste (|cffffff00remove|r oder |cffffff00remove #|r)" -- Needs review
L.SLASH_CMD7 = "Edit" -- Needs review
L.SLASH_CMD7_DESC = "Schaltet Bearbeitungsmodus für alle Knöpfe um" -- Needs review
L.SLASH_CMD8 = "Bind" -- Needs review
L.SLASH_CMD8_DESC = "Schaltet Zuweisungsmodus für alle Knöpfe um" -- Needs review
L.SLASH_CMD9 = "Scale" -- Needs review
L.SLASH_CMD9_DESC = "Skaliere eine Leiste zur gewünschten Größe" -- Needs review
L.SLASH_HINT1 = [=[
/neuron |cff00ff00<Befehl>|r <Optionen>]=] -- Needs review
L.SLASH_HINT2 = [=[
Befehlsliste -
]=] -- Needs review
L.SNAPTO = "Einrasten" -- Needs review
L.SPELLGLOW = "Zauberbenachrichtigungen" -- Needs review
L.SPELLGLOW_ALT = "- Gedämpfte Benachrichtigung" -- Needs review
L.SPELLGLOW_DEFAULT = "- Standard Benachrichtigung" -- Needs review
L.SPELLGLOWS = [=[Gültige Optionen:

|cff00ff00default|r: benutze Blizzard standard Zauberleuchtanimationen
|cff00ff00alt|r: benutze alternative gedämpfte Zauberleuchtanimationen]=] -- Needs review
L.STANCE = "Haltung" -- Needs review
L.STATE_HIDE = "verstecken" -- Needs review
L.STATE_SHOW = "zeigen" -- Needs review
L.STEALTH = "Tarnung" -- Needs review
L.STEALTH0 = "keine Tarnung" -- Needs review
L.STEALTH1 = "Tarnung" -- Needs review
L.STRATA = "Ebene" -- Needs review
L.TIMERLIMIT_INVALID = "Ungültiges Timer limit" -- Needs review
L.TIMERLIMIT_SET = "Timer limit gesetzt auf %d Sekunden" -- Needs review
L.TOOLTIPS = [=[Gültige Optionen:

|cff00ff00enhanced|r: zeige zusätzliche Fähigkeiten-Informationen
|cff00ff00combat|r: zeige/verstecke Tooltips während des Kampfes]=] -- Needs review
L.TOOLTIPS_COMBAT = "- Im Kampf verstecken" -- Needs review
L.TOOLTIPS_ENH = "- Erweitert" -- Needs review
L.UPCLICKS = "Maustaste loslassen" -- Needs review
L.VALIDSTATES = [=[
|cff00ff00Zulässige Zustände:|r ]=] -- Needs review
L.VEHICLE = "Fahrzeug" -- Needs review
L.VEHICLE0 = "kein Fahrzeug" -- Needs review
L.VEHICLE1 = "Fahrzeug" -- Needs review
L.VPAD = "Vert Pad" -- Needs review
L.WARLOCK_CASTER = "Normale Gestalt" -- Needs review
L.XPOS = "X Pos" -- Needs review
L.YPOS = "Y Pos" -- Needs review
