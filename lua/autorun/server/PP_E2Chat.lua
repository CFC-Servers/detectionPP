local IsValid = IsValid
local math_min = math.min
local CHAT_DISTANCE = 250 * 250

hook.Add( "InitPostEntity", "DetectionPP_SetupChat", function()
    if not WireLib then return end

    -- Stealing and overwriting the hook
    local hookFunc = hook.GetTable().PlayerSay.Exp2TextReceiving
    local _, ChatAlert = debug.getupvalue( hookFunc, 3 )

    hook.Add( "PlayerSay", "Exp2TextReceiving", function( ply, text, teamchat )
        local entry = { text, CurTime(), ply, teamchat }
        TextList[ply:EntIndex()] = entry
        TextList.last = entry

        chipHideChat = false
        local hideCurrent = false
        for e,_ in pairs( ChatAlert ) do
            if IsValid( e ) then
                if chipHideChat and ply == e.player then
                    hideCurrent = chipHideChat
                else
                    local plyPos = ply:GetPos()

                    local owner = e.player
                    local ownerDist = plyPos:DistanceToSqr( owner:GetPos() )
                    local chipDist = plyPos:DistanceToSqr( e:GetPos() )
                    local shortest = math_min( ownerDist, chipDist )

                    if shortest <= CHAT_DISTANCE then
                        chipHideChat = nil
                        e.context.data.runByChat = entry
                        e:Execute()
                        e.context.data.runByChat = nil
                    end
                end

            else
                ChatAlert[e] = nil
            end
        end

        if hideCurrent then return "" end

    end )
end )
