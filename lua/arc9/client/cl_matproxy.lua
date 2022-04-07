matproxy.Add({
    name = "CustomCamo",
    init = function( self, mat, values )
        -- Store the name of the variable we want to set
        self.DetailResult = values.camotexture
        self.ScaleResult = values.camoscale

        if self.DetailResult then
            self.DefaultTexture = mat:GetTexture(self.DetailResult)
        end

        if self.ScaleResult then
            self.DefaultScale = mat:GetFloat(self.ScaleResult)
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

    end
})