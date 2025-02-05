-- Making wire_holograms_display_owners require admin

local RED = Color( 255, 0, 0 )

hook.Add( "InitPostEntity", "DetectionPP_SetupHolos", function()
    if not WireLib then return end

    local function WireHologramsShowOwners()
        for _,ent in pairs( ents.FindByClass( "gmod_wire_hologram" ) ) do
            local id = ent:GetNWInt( "ownerid" )

            for _,ply in pairs( player.GetAll() ) do
                if ply:UserID() == id then
                    local vec = ent:GetPos():ToScreen()

                    draw.DrawText( ply:Name() .. "\n" .. ply:SteamID(), "DermaDefault", vec.x, vec.y, RED, 1 )
                    break
                end
            end
        end
    end

    local display_owners = false
    concommand.Add( "wire_holograms_display_owners", function( Ply )
        if not Ply:IsAdmin() and not Ply:IsSuperAdmin() then return end

        display_owners = not display_owners
        if display_owners then
            hook.Add( "HUDPaint", "wire_holograms_showowners", WireHologramsShowOwners )
        else
            hook.Remove("HUDPaint", "wire_holograms_showowners")
        end
    end )
end)
