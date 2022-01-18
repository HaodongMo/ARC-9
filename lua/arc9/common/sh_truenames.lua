local truenames_enforced = GetConVar("arc9_truenames_enforced")
local truenames_default = GetConVar("arc9_truenames_default")
local truenames_preference = CLIENT and GetConVar("arc9_truenames")

--[[
    If called from the server or sv is true, returns the server truenames mode.
    If called from the client, returns the client preference if exists and is not enforced.
]]
function ARC9:UseTrueNames(sv)
    if SERVER or sv or truenames_enforced:GetBool() or truenames_preference:GetInt() == 2 then
        return truenames_default:GetBool()
    end
    return truenames_preference:GetBool()
end