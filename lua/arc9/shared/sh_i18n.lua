ARC9.PhraseTable = ARC9.PhraseTable or {}
ARC9.STPTable = ARC9.STPTable or {}

local lang_cvar = (game.SinglePlayer() or CLIENT) and GetConVar("arc9_language")

function ARC9:GetLanguage()
    local l = lang_cvar and lang_cvar:GetString()
    if !l or l == "" then l = GetConVar("gmod_language"):GetString() end
    return string.lower(l)
end

function ARC9:AddPhrase(phrase, str, lang)
    if phrase == nil or phrase == "" or str == nil or str == "" then return nil end
    lang = lang and string.lower(lang) or "en"
    ARC9.PhraseTable[lang] = ARC9.PhraseTable[lang] or {}
    ARC9.PhraseTable[lang][string.lower(phrase)] = str
end

--[[
    Add a "String to Phrase", converting a string to a phrase (i.e. "Assault Rifle" to "class.assaultrifle").
]]
function ARC9:AddSTP(phrase, str, lang)
    if phrase == nil or phrase == "" or str == nil or str == "" then return nil end
    ARC9.STPTable[string.lower(str)] = phrase
end

function ARC9:GetPhrase(phrase, format)
    if phrase == nil or phrase == "" then return nil end
    phrase = string.lower(phrase)
    local lang = ARC9:GetLanguage()
    if !lang or !ARC9.PhraseTable[lang] or !ARC9.PhraseTable[lang][phrase] then
        lang = "en"
    end
    if ARC9.PhraseTable[lang] and ARC9.PhraseTable[lang][phrase] then
        local str = ARC9.PhraseTable[lang][phrase]
        for i, v in pairs(format or {}) do
            str = string.Replace(str, "{" .. i .. "}", v)
        end
        return str
    end
    return nil
end

--[[
    Return the localized string of a phrase for an attachment. Will return a truename if set and exists.
    Language table entries take precedence over the hardcoded name.
]]
function ARC9:GetPhraseForAtt(att, phrase, format)
    local atttbl = ARC9.Attachments[att]
    if !atttbl then return "" end

    local attphrase = att .. "." .. phrase

    local tn = ARC9:UseTrueNames()
    if tn then
        local p = ARC9:GetPhrase(attphrase .. ".true")
        if p then return p end
        if atttbl[phrase .. "_TrueName"] then return atttbl[phrase .. "_TrueName"] end
    end

    local p = ARC9:GetPhrase(attphrase)
    if p then return p end

    return atttbl[phrase]
end

-- client languages aren't loaded through lua anymore. use gmod's stock localization system instead

function ARC9:LoadLanguage(lang)
    ARC9.PhraseTable = {}

    local cur_lang = lang or ARC9:GetLanguage()

    for _, v in pairs(file.Find("arc9/common/localization/*_" .. cur_lang .. ".lua", "LUA")) do

        L = {}
        STL = {}
        include("arc9/common/localization/" .. v)
        AddCSLuaFile("arc9/common/localization/" .. v)

        local exp = string.Explode("_", string.lower(string.Replace(v, ".lua", "")))

        if !exp[#exp] then
            print("Failed to load ARC9 language file " .. v .. ", did not get language name (naming convention incorrect?)")
            continue
        elseif !L then
            print("Failed to load ARC9 language file " .. v .. ", did not get language table")
            continue
        end

        for phrase, str in pairs(L) do
            ARC9:AddPhrase(phrase, str, lang)
        end

        for str, phrase in pairs(STL) do
            ARC9:AddSTP(str, phrase)
        end

        print("Loaded ARC9 language file " .. v .. " with " .. table.Count(L) .. " strings.")
        L = nil
        STL = nil
    end
end

ARC9:LoadLanguage()
ARC9:LoadLanguage("en")


if CLIENT then

    concommand.Add("arc9_reloadlangs", function()
        if !LocalPlayer():IsSuperAdmin() then return end

        net.Start("arc9_reloadlangs")
        net.SendToServer()
    end)

    net.Receive("arc9_reloadlangs", function(len, ply)
        ARC9:LoadLanguage()
        ARC9:LoadLanguage("en")
        ARC9.Regen()
    end)

elseif SERVER then

    net.Receive("arc9_reloadlangs", function(len, ply)
        if !ply:IsSuperAdmin() then return end

        ARC9:LoadLanguage()
        ARC9:LoadLanguage("en")

        net.Start("arc9_reloadlangs")
        net.Broadcast()
    end)

end