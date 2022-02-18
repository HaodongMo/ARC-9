function ARC9.AttemptGiveNPCWeapon()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    local tr = LocalPlayer():GetEyeTrace()

    if tr.Entity:IsValid() and tr.Entity:IsNPC() then
        net.Start("arc9_givenpcweapon")
        net.WriteEntity(tr.Entity)
        net.SendToServer()
    end
end