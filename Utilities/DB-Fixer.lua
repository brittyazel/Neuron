
local NEURON = Neuron


------------------------------------------------------------
--------------------Data Fixing Functions-------------------
------------------------------------------------------------

function NEURON:fixObjectTable(profile) --converted objectTable from a single string to a table of ints, this fixes the table on login

    local barDBLocations = {"NeuronGDB", "NeuronCDB", "NeuronCDB", "NeuronCDB", "NeuronCDB", "NeuronCDB", "NeuronCDB"}
    local barDBLocationsName = {"bars", "bagbars", "menubars", "petbars", "statusbars", "xbars", "zoneabilitybars"}


    for i = 1,#barDBLocations do

        for j, bar in pairs(profile[barDBLocations[i]][barDBLocationsName[i]]) do

            if(bar.objectList) then --add safety check in case the profile is really old and this table doesn't exist
                if type(bar.objectList) == "string" then

                    local function split(source, delimiters)
                        local elements = {}
                        local pattern = '([^'..delimiters..']+)'
                        string.gsub(source, pattern, function(value) elements[#elements + 1] = value; end);
                        return elements
                    end
                    if bar.name then
                        NEURON:Print("fixing data for: " .. bar.name)
                    end
                    bar.objectList = split(bar.objectList, ";")
                end
            else

                bar["objectList"] = {}

            end
        end

    end

end