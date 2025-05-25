local lodcvar = GetConVar("arc9_lod_distance")
function SWEP:ShouldLOD()
    if (self.NextLODCheck or 0) > CurTime() then return self.LastLOD or 0 end
    self.NextLODCheck = CurTime() + 0.5

    local owner, lp = self:GetOwner(), LocalPlayer()
    if lp == owner then return 0 end

    local result = 0

    local screenSize = render.ComputePixelDiameterOfSphere(self:GetPos(), 0.5) -- same thing as in source:tm:
    screenSize = screenSize * math.Clamp(lodcvar:GetFloat(), 0.3, 3)
    local metric = screenSize > 0 and 100 / screenSize or 0
    if !IsValid(owner) then metric = metric * 1.5 end

    if metric > 128 then result = 2
    elseif metric > 96 then result = 1.5
    elseif metric > 64 then result = 1 end -- middle value for tpik lod

    self.LastLOD = result
    return result
end

function SWEP:DrawCustomModel(wm, custompos, customang)
    local owner = self:GetOwner()

    if !wm and !IsValid(owner) then return end
    local lod = self:ShouldLOD()
    local isnpc = owner:IsNPC() or lod > 0
    if !wm and isnpc then return end
    if wm and ARC9.RTScopeRender then return end
    if custompos then wm = true end

    local mdl = self.VModel

    if wm then
        if custompos then
            mdl = self.CModel
        else
            mdl = self.WModel

            if lod == 0 and mdl and mdl[1]:IsValid() then
                mdl[1]:SetMaterial(self:GetProcessedValue("Material", true))

                for ind = 0, 31 do
                    local val = self:GetProcessedValue("SubMaterial" .. ind, true)
                    if val then
                        mdl[1]:SetSubMaterial(ind, val)
                    end
                end
            end
        end

        if lod >= 2 then
            self:DrawModel()
            return
        end
    end

    if !mdl then
        self:KillModel()
        self:SetupModel(wm, lod, !!custompos)

        mdl = self.VModel

        if wm then
            mdl = self.WModel
            if custompos then
                mdl = self.CModel
            end
        end
    end

    if lod < 2 then
        local onground = wm and !IsValid(owner)
    
        local hidebones = isnpc and {} or self:GetHiddenBones(wm)

        for _, model in ipairs(mdl or {}) do
            if model.IsAnimationProxy then continue end
            local slottbl = model.slottbl
            local atttbl = self:GetFinalAttTable(slottbl)

            if !IsValid(model) then self:KillModel() return end

            if !onground or model.OptimizPrevWMPos != self:GetPos() then -- mega optimiz
                model.OptimizPrevWMPos = onground and self:GetPos() or nil

                if ARC9.RTScopeRender and atttbl.RTScope then continue end -- dont draw scope model while drawing vm from scope position
                
                model.hidden = false

                if model.charmparent then
                    continue
                else
                    if hidebones[slottbl.Bone or -1] then
                        model.hidden = true
                        continue
                    end

                    if model.Duplicate then
                        local duplitbl = (slottbl.DuplicateModels or {})[model.Duplicate]

                        if hidebones[(duplitbl or {}).Bone or -1] then
                            model.hidden = true
                            continue
                        end
                    end

                    local apos, aang = self:GetAttachmentPos(slottbl, wm, false, false, custompos, customang or angle_zero, model.Duplicate)
                    model:SetPos(apos)
                    model:SetAngles(aang)
                    model:SetRenderOrigin(apos)
                    model:SetRenderAngles(aang)
                    model:SetupBones()

                    if model.charmmdl then
                        local bpos, bang

                        local bonename = atttbl.CharmBone
                        if bonename then
                            local boneindex = model:LookupBone(bonename)

                            local bonemat = model:GetBoneMatrix(boneindex)
                            if bonemat then
                                bpos = bonemat:GetTranslation()
                                bang = bonemat:GetAngles()
                            end

                            if bpos and bang then
                                local coffset = atttbl.CharmOffset or Vector(0, 0, 0)
                                local cangle = atttbl.CharmAngle or Angle(0, 0, 0)

                                bpos = bpos + bang:Forward() * coffset.y
                                bpos = bpos + bang:Up() * coffset.z
                                bpos = bpos + bang:Right() * coffset.x

                                local up, right, forward = bang:Up(), bang:Right(), bang:Forward()

                                bang:RotateAroundAxis(up, cangle.p)
                                bang:RotateAroundAxis(right, cangle.y)
                                bang:RotateAroundAxis(forward, cangle.r)

                                model.charmmdl:SetPos(bpos)
                                model.charmmdl:SetAngles(bang)
                                model.charmmdl:SetupBones()
                                model.charmmdl:DrawModel()
                            end
                        end
                    end
                end

                -- if !wm and atttbl.HoloSight then
                --     self:DoHolosight(model, atttbl)
                -- end

                if !ARC9.PresetCam and !ARC9.RTScopeRender then
                    if !wm and atttbl.RTScope then
                        local active = slottbl.Address == self:GetActiveSightSlotTable().Address
                        self:DoRTScope(model, atttbl, active)
                    elseif wm and atttbl.RTScope then
                        self:DoRTScope(model, atttbl, false)
                    end
                end
            end

            model.CustomCamoTexture = self:GetProcessedValue("CustomCamoTexture", true)
            model.CustomCamoScale = self:GetProcessedValue("CustomCamoScale", true)
            model.CustomBlendFactor = self:GetProcessedValue("CustomBlendFactor", true)


            if !model.NoDraw and !(model.istranslucent and !ARC9.PresetCam and !onground and !isnpc) then
                model:DrawModel()
            end

            if atttbl.DrawFunc then
                atttbl.DrawFunc(self, model, wm)
            end

        --     -- if model.Flare and !self:GetCustomize() then
        --     --     if model.Flare.Attachment then
        --     --         local attpos = model:GetAttachment(model.Flare.Attachment)

        --     --         if attpos then
        --     --             self:DrawLightFlare(attpos.Pos, -attpos.Ang:Right(), model.Flare.Color, model.Flare.Size, model.Flare.Focus)
        --     --         else
        --     --             self:DrawLightFlare(apos, aang:Forward(), model.Flare.Color, model.Flare.Size, model.Flare.Focus)
        --     --         end
        --     --     else
        --     --         self:DrawLightFlare(apos, aang:Forward(), model.Flare.Color, model.Flare.Size, model.Flare.Focus)
        --     --     end
        --     -- end
        end
    end
end

function SWEP:DrawTranslucentPass(wm) -- translucent pass, fuck source and gmod
    if !wm then
        if self.VModel then
            for _, model in ipairs(self.VModel) do
                if model.istranslucent and !model.hidden and IsValid(model) then
                    if self.CustomizeDelta > 0 then cam.IgnoreZ(true) end
                    model:DrawModel()
                end
            end
        end
    else
        if self.WModel then
            for _, model in ipairs(self.WModel) do
                if model.istranslucent and !model.hidden and IsValid(model) then
                    model:DrawModel()
                end
            end
        end
    end
end

function SWEP:GetActiveSightSlotTable()
    local sight = self:GetSight() or {}

    return sight.slottbl or {}
end

-- advanced camos

-- SWEP.AdvancedCamoCache = {}

local maxcamos = GetConVar("arc9_atts_maxcamos")

function SWEP:GetAdvancedCamo(att, address)
    if self.AdvancedCamoCache == false then return end -- disable this bitch if no super camo slots
    if !att then att = "" end
    if address then att = address end
    if self.AdvancedCamoCache == nil then self.AdvancedCamoCache = {} end

    if self.AdvancedCamoCache[att] then return self.AdvancedCamoCache[att] end

    local state = 1

    if att != "second" and att != "third" then
        if !address then
            state = (att != "") and self:GetValue(att .. "_camoslot") or 1
        else
            local slott = self:LocateSlotFromAddress(address)
            if istable(slott) and slott.ToggleNum then
                state = slott.ToggleNum
            end
        end
    end

    if att == "second" then state = 2 elseif att == "third" then state = 3 end

    local atts = {}

    local hasadvcamoslots = false
    local camoatt

    for _, i in ipairs(self:GetSubSlotList()) do
        if i["IsAdvancedCamo1"] then hasadvcamoslots = true end
        if i["IsAdvancedCamo" .. state] then
            if i.Installed then camoatt = self:GetFinalAttTable(i) end
        end
    end

    if camoatt then
        self.AdvancedCamoCache[att] = {
            Texture = camoatt.CustomCamoTexture,
            Scale = camoatt.CustomCamoScale,
            Rotate = camoatt.CustomCamoRotate,
            BlendMode = camoatt.CustomCamoBlendMode,
            Factor = camoatt.CustomBlendFactor,
            PhongMult = camoatt.CustomCamoPhongMult,
        }
    end

    if !hasadvcamoslots then self.AdvancedCamoCache = false return end -- disable this bitch if no super camo slots
    
    return self.AdvancedCamoCache[att]
end