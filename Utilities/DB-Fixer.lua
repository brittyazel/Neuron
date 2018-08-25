
local NEURON = Neuron


------------------------------------------------------------
--------------------Data Fixing Functions-------------------
------------------------------------------------------------

function NEURON:DBFixer(profile, oldDBVersion) --converted objectTable from a single string to a table of ints, this fixes the table on login


    ---Added on 8/25/2018. Remove at some point in the future
    if oldDBVersion < 1.1 then --this is the first of many DB fixes. This should be run first before the rest to migrate us into the DBVersion 1.1 state

        local barDBLocationsName = {"bagbar", "menubar", "petbar", "statusbar", "extrabar", "zoneabilitybar", "exitbar" }
        local btnDBLocationsName = {"bagbtn", "menubtn", "petbtn", "statusbtn", "extrabtn", "zoneabilitybtn", "exitbtn" }

        local old_barDBLocationsName = {"bagbars", "menubars", "petbars", "statusbars", "xbars", "zoneabilitybars", "exitbars" }
        local old_btnDBLocationsName = {"bagbtns", "menubtns", "petbtns", "statusbtns", "xbtns", "zoneabilitybtns", "exitbtns" }

        for i = 1,7 do

            if profile["NeuronCDB"][old_barDBLocationsName[i]] then
                profile["NeuronCDB"][barDBLocationsName[i]] = CopyTable(profile["NeuronCDB"][old_barDBLocationsName[i]])
                profile["NeuronCDB"][old_barDBLocationsName[i]] = nil
            end

            if profile["NeuronCDB"][old_btnDBLocationsName[i]] then
                profile["NeuronCDB"][btnDBLocationsName[i]] = CopyTable(profile["NeuronCDB"][old_btnDBLocationsName[i]])
                profile["NeuronCDB"][old_btnDBLocationsName[i]] = nil
            end

        end


        profile["NeuronCDB"]["extrabarFirstRun"] = profile["NeuronCDB"]["xbarFirstRun"]
        profile["NeuronCDB"]["xbarFirstRun"] = nil

        oldDBVersion = 1.1 --increment oldDBVersion up to the latest that this set of code fixes
        NEURON:Print("Neuron database migrated to version " .. 1.1)
    end


    return profile

end