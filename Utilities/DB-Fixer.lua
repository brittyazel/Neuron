------------------------------------------------------------
--------------------Data Fixing Functions-------------------
------------------------------------------------------------

function Neuron:DBFixer(profile, oldDBVersion) --converted objectTable from a single string to a table of ints, this fixes the table on login


    ---Added on 8/25/2018. Remove at some point in the future
    ---The purpose of this migration was to rename many of the DB tables to values that make more sense
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
        Neuron:Print("Neuron database migrated to version " .. 1.1)
    end


    ---Added on 8/26/2018. Remove at some point in the future
    ---The purpose of this migrate is to get rid of the GDB/CDB divide
    ---this code takes everything that was in the NeuronCDB and NeuronGDB databases and merges them with all their contents taking the top level
    if oldDBVersion < 1.2 then

        for k1,v1 in pairs(profile.NeuronGDB) do

            if k1 == "bars" or k1 == "buttons" or k1 == "throttle" or k1 == "timerLimit" or k1 == "snapToTol" or k1 == "blizzbar" or k1 == "firstRun" or k1 == "NeuronIcon" then
                profile[k1] = v1
            end

        end

        for k1,v1 in pairs(profile.NeuronCDB) do
            if k1 ~= "bars" and k1 ~= "buttons" then
                profile[k1] = v1
            end
        end

        if not profile.bars then
            profile.bars = {}
        end

        for k1,v1 in pairs(profile.NeuronCDB.bars) do

            if not profile.bars[k1] then
                profile.bars[k1] = {}
            end

            for k2,v2 in pairs(v1) do
                profile.bars[k1][k2] = v2
            end

        end

        if not profile.buttons then
            profile.buttons = {}
        end

        for k1,v1 in pairs(profile.NeuronCDB.buttons) do

            if not profile.buttons[k1] then
                profile.buttons[k1] = {}
            end

            for k2,v2 in pairs(v1) do
                profile.buttons[k1][k2] = v2
            end
        end


        oldDBVersion = 1.2 --increment oldDBVersion up to the latest that this set of code fixes
        Neuron:Print("Neuron database migrated to version " .. 1.2)

    end

end