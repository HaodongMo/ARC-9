function SWEP:GetPresetBase()
    return self.SaveBase or self:GetClass()
end

function SWEP:GetPresets()
    local path = ARC9.PresetPath .. self:GetPresetBase() .. "/*.txt"

    local files = file.Find(path, "DATA")

    return files
end

function SWEP:WriteAttachmentTree(tree)
    if tree and tree.Installed then
        local tbl = {
            Installed = tree.Installed,
            ToggleNum = tree.ToggleNum or 1
        }

        local atttbl = ARC9.GetAttTable(tree.Installed)

        if atttbl.Attachments then
            tbl.SubAttachments = {}

            for i, k in pairs(atttbl.Attachments) do
                tbl.SubAttachments[i] = self:WriteAttachmentTree(tree.SubAttachments[i])
            end
        end

        return tbl
    else
        return {}
    end
end

function SWEP:LoadPreset(filename)
    if LocalPlayer() != self:GetOwner() then return end

    filename = filename or "autosave"
    filename = ARC9.PresetPath .. self:GetPresetBase() .. "/" .. filename .. ".txt"

    if !file.Exists(filename, "DATA") then return end

    local f = file.Open(filename, "r", "DATA")
    if !f then return end

    local tbl = util.JSONToTable(f:Read())

    for i, k in pairs(self.Attachments) do
        local slottbl = tbl[i]
        if !slottbl.Installed then continue end
        self.Attachments[i].Installed = slottbl.Installed
        self.Attachments[i].ToggleNum = slottbl.ToggleNum
        self.Attachments[i].SubAttachments = slottbl.SubAttachments
    end

    f:Close()

    self:SendWeapon()
    self:PostModify()
end

local ratio = ScrW() / ScrH()
local pr_h = 256
local pr_w = 256 * ratio
local cammat = GetRenderTarget("arc9_presetcam", pr_w, pr_h, false)

SWEP.PresetCapture = nil

function SWEP:SavePreset(presetname)
    presetname = presetname or "autosave"

    local tbl = {}

    for i, k in pairs(self.Attachments or {}) do
        tbl[i] = {
            Installed = k.Installed,
            ToggleNum = k.ToggleNum,
            SubAttachments = k.SubAttachments
        }
        -- self:WriteAttachmentTree(self.Attachments[i])
    end

    local str = util.TableToJSON(tbl, false)

    local filename =  ARC9.PresetPath .. self:GetPresetBase() .. "/" .. presetname

    file.CreateDir(ARC9.PresetPath .. self:GetPresetBase())
    file.Write(filename .. ".txt", str)

    self.PresetCapture = filename

    -- if presetname != "autosave" then
    -- end

    self:DoPresetCapture()
end

function SWEP:DoPresetCapture()
    if !self.PresetCapture then return end

    local filename = self.PresetCapture

    self.PresetCapture = nil

    render.PushRenderTarget(cammat)

    render.Clear(0, 0, 0, 255, true, true)

    local ref = 64

    render.UpdateScreenEffectTexture()
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)

    render.SetStencilReferenceValue(ref)

    render.SetWriteDepthToDestAlpha(false)

    cam.Start3D(nil, nil, 120)
    self:GetVM():DrawModel()
    cam.End3D()

    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
    render.SetStencilReferenceValue(0)

    render.SetColorMaterial()
    render.DrawScreenQuad()

    render.SetStencilEnable(false)

    -- render.RenderView({
    --     x = 0,
    --     y = 0,
    --     w = preset_res,
    --     h = preset_res,
    --     origin = EyePos(),
    --     angles = EyeAngles(),
    --     fov = 90,
    --     dopostprocess = false,
    --     drawhud = false,
    --     drawmonitors = false,
    --     drawviewmodel = true
    -- })

    local x = (pr_w - 256) / 2

    local data = render.Capture( {
        format = "png",
        x = x,
        y = 0,
        w = 256,
        h = 256
    } )

    file.CreateDir(ARC9.PresetPath .. self:GetPresetBase())
    file.Write(filename .. ".png", data)

    render.PopRenderTarget()
end