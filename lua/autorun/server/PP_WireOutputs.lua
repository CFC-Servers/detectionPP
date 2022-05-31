local type = type
local tonumber = tonumber
local tostring = tostring

local function setupTriggerOutput()
    local GetOwner = WireLib.GetOwner
    TrigOut = TrigOut or WireLib.TriggerOutput

    function WireLib.TriggerOutput( Ent, OutputName, Value, Iterate )
        local Type = type( Value )

        if ( Type == "Entity" or Type == "Vehicle" ) and IsValid( Value ) then
            if GetOwner( Value ) and not Value:CPPICanTool( GetOwner( Ent ) ) then
                Value = nil
            end
        elseif Type == "Player" then
            if GetOwner( Ent ) ~= Value then
                Value = nil
            end
        elseif Type == "table" then
            local Owner = GetOwner( Ent )

            for K, V in pairs( Value ) do -- This makes me feel bad. I'm sorry.
                local VType = type( V )

                if ( VType == "Entity" or VType == "Vehicle" ) and not V:CPPICanTool( Owner ) then
                    Value[K] = nil
                elseif VType == "Player" then
                    if V:InVehicle() and GetOwner( V:GetVehicle() ) ~= Owner or Owner ~= V  then
                        Value[K] = nil
                    end
                end
            end
        end

        TrigOut( Ent, OutputName, Value, Iterate )
    end

    Wire_TriggerOutput = WireLib.TriggerOutput
end

local ORIGIN = Vector( 0, 0, 0 )

-- Override the linking/targeting behavior of Beacon Sensors combined with Target Finders
local function setupTargetFinder()
    local function GetBeaconPos( self, sensor )
        local ch = 1
        if sensor.Inputs and sensor.Inputs.Target.SrcId then
            ch = tonumber( sensor.Inputs.Target.SrcId )
        end

        if self.SelectedTargets[ch] then
            if not self.SelectedTargets[ch]:IsValid() then
                self.SelectedTargets[ch] = nil
                Wire_TriggerOutput( self, tostring( ch ), 0 )
                return sensor:GetPos()
            end

            local Tgt = self.SelectedTargets[ch]
            return Tgt:CPPICanTool( GetOwner( self ) ) and Tgt:GetPos() or ORIGIN
        end

        return sensor:GetPos()
    end

    -- Replace the GetBeaconPos func on Target Finders with our own
    local targetFinder = scripted_ents.GetStored( "gmod_wire_target_finder" ).t
    targetFinder.GetBeaconPos = GetBeaconPos
end

-- Checking all wire entity/table/array outputs for entities
hook.Add( "InitPostEntity", "DetectPP_SetupWireOutputs", function()
    if not WireLib then return end

    setupTriggerOutput()
    setupTargetFinder()
end )
