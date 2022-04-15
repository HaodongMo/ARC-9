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
        elseif self.DetailResult then
            mat:SetTexture(self.DetailResult, self.DefaultTexture)
        end

        if self.ScaleResult and ent.CustomCamoScale then
            mat:SetFloat(self.ScaleResult, ent.CustomCamoScale)
        elseif self.ScaleResult then
            mat:SetFloat(self.ScaleResult, self.DefaultScale)
        end

        if self.BlendResult and ent.CustomCamoBlend then
            mat:SetFloat(self.BlendResult, ent.CustomCamoBlend)
        elseif self.BlendResult then
            mat:SetFloat(self.BlendResult, self.DefaultBlend)
        end

    end
})

matproxy.Add({
    name = "ARC9_Heat",
    init = function( self, mat, values )
        self.BlendResult = values.blend
    end,

    bind = function( self, mat, ent )
        local weapon = ent and ent:GetOwner() and ent:GetOwner():GetActiveWeapon()

        if weapon and weapon.ARC9 and weapon:GetProcessedValue("Overheat") then
            mat:SetFloat(self.BlendResult, (math.ease.InExpo(weapon:GetHeatAmount() / weapon:GetProcessedValue("HeatCapacity"))) * 2)
        end
    end
})