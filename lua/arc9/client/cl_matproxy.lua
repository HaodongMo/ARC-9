matproxy.Add({
    name = "CustomCamo",
    init = function( self, mat, values )
        -- Store the name of the variable we want to set
        self.DetailResult = values.camotexture
        self.ScaleResult = values.camoscale
        self.BlendResult = values.blend

        if self.DetailResult then
            self.DefaultTexture = mat:GetTexture(self.DetailResult)
        end

        if self.ScaleResult then
            self.DefaultScale = mat:GetFloat(self.ScaleResult)
        end

        if self.BlendResult then
            self.DefaultBlend = mat:GetFloat(self.BlendResult)
        end
    end,
    bind = function( self, mat, ent )
        if self.DetailResult and ent.CustomCamoTexture then
            -- mat:SetString(self.DetailResult, self.CustomCamoTexture)
            mat:SetTexture(self.DetailResult, ent.CustomCamoTexture)
            self.ShouldRecomputeIfSet = true
        elseif self.DetailResult then
            self.DefaultTexture = nil
            if !self.DefaultTexture then
                mat:SetUndefined(self.DetailResult)
                if self.ShouldRecomputeIfSet then
                    mat:Recompute()
                    self.ShouldRecomputeIfSet = false
                end
            else
                mat:SetTexture(self.DetailResult, self.DefaultTexture)
            end
        end

        if self.ScaleResult and ent.CustomCamoScale then
            mat:SetFloat(self.ScaleResult, ent.CustomCamoScale)
            self.ShouldRecomputeIfSet = true
        elseif self.ScaleResult then
            if self.DefaultScale then
                mat:SetFloat(self.ScaleResult, self.DefaultScale)
            else
                mat:SetUndefined(self.ScaleResult)
                if self.ShouldRecomputeIfSet then
                    mat:Recompute()
                    self.ShouldRecomputeIfSet = false
                end
            end
        end

        if self.BlendResult and ent.CustomCamoBlend then
            mat:SetFloat(self.BlendResult, ent.CustomCamoBlend)
            self.ShouldRecomputeIfSet = true
        elseif self.BlendResult then
            if self.DefaultBlend then
                mat:SetFloat(self.BlendResult, self.DefaultBlend)
            else
                mat:SetUndefined(self.DefaultBlend)
                if self.ShouldRecomputeIfSet then
                    mat:Recompute()
                    self.ShouldRecomputeIfSet = false
                end
            end
        end

    end
})

matproxy.Add({
    name = "ARC9_Heat",
    init = function( self, mat, values )
        self.BlendResult = values.blend
    end,

    bind = function( self, mat, ent )
        if IsValid(ent) and IsValid(ent.weapon) then ent = ent.weapon end

        if IsValid(ent) and IsValid(ent:GetOwner()) and IsValid(ent:GetOwner():GetActiveWeapon()) then
            local weapon = ent:GetOwner():GetActiveWeapon()
            if weapon and weapon.ARC9 and weapon:GetProcessedValue("Overheat") then
                mat:SetFloat(self.BlendResult, (math.ease.InExpo(weapon:GetHeatAmount() / weapon:GetProcessedValue("HeatCapacity"))) * 2)
            end
        else
            mat:SetFloat(self.BlendResult, 0)
        end
    end
})

matproxy.Add({
    name = "arc9_scope_alpha",
    init = function(self, mat, values)
        self.ResultTo = values.resultvar
    end,
    bind = function(self, mat, ent)
        local ply = LocalPlayer()

        if IsValid(ply) then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) and weapon.ARC9 then
                local amt = 1 - weapon:GetSightAmount() / 1 
                amt = amt * 0.2
                mat:SetVector(self.ResultTo, Vector(amt*1.1, amt*0.9, amt*1.3))
            end
        end
   end
})