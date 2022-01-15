

function SWEP:DoRHIK()
    local vm = self:GetOwner():GetViewModel()

    local delta = self:Curve(self.CustomizeDelta)

    for _, bone in ipairs(ARC9.LHIKBones) do
        local vmbone = vm:LookupBone(bone)

        if !vmbone then continue end -- Happens when spectating someone prolly

        local vmtransform = vm:GetBoneMatrix(vmbone)

        if !vmtransform then continue end -- something very bad has happened

        local vm_pos = vmtransform:GetTranslation()
        local vm_ang = vmtransform:GetAngles()

        local newtransform = Matrix()

        newtransform:SetTranslation(LerpVector(delta, vm_pos, vm_pos - (EyeAngles():Up() * 128) - (EyeAngles():Forward() * 128)))
        newtransform:SetAngles(vm_ang)

        vm:SetBoneMatrix(vmbone, newtransform)
    end

    for _, bone in ipairs(ARC9.RHIKBones) do
        local vmbone = vm:LookupBone(bone)

        if !vmbone then continue end -- Happens when spectating someone prolly

        local vmtransform = vm:GetBoneMatrix(vmbone)

        if !vmtransform then continue end -- something very bad has happened

        local vm_pos = vmtransform:GetTranslation()
        local vm_ang = vmtransform:GetAngles()

        local newtransform = Matrix()

        newtransform:SetTranslation(LerpVector(delta, vm_pos, vm_pos - (EyeAngles():Up() * 128) - (EyeAngles():Forward() * 128)))
        newtransform:SetAngles(vm_ang)

        vm:SetBoneMatrix(vmbone, newtransform)
    end
end