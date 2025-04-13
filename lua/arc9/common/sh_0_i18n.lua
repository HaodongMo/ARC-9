ARC9.PhraseTable = ARC9.PhraseTable or {}
ARC9.STPTable = ARC9.STPTable or {}

local lang_cvar = GetConVar("arc9_language")
local gmod_language = GetConVar("gmod_language")

function ARC9:GetLanguage()
    -- local date = os.date("*t")

    -- local day = date.day
    -- local month = date.month

    -- if day == 1 and month == 4 then
        -- return "uwu"
    -- end -- REMOVE THIS AFTER 1 APRIL  (NOT OPTIMIZED!1)

    if lang_cvar:GetString() ~= "" then
        return string.lower(lang_cvar:GetString())
    end
    local l = gmod_language:GetString()
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

function ARC9:LoadLanguage(lang, printshit)
    local cur_lang = lang or ARC9:GetLanguage()
    local luacount, stringcount = 0, 0

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
            ARC9:AddPhrase(phrase, str, cur_lang)
        end

        for str, phrase in pairs(STL) do
            ARC9:AddSTP(str, phrase)
        end

        if table.Count(L) > 0 then
            hasany = true
        end

        -- print("Loaded ARC9 language file " .. v .. " with " .. table.Count(L) .. " strings.")
        luacount = luacount + 1
        stringcount = stringcount + table.Count(L)
        L = nil
        STL = nil
    end

    if CLIENT and printshit then print("ARC9: Loaded " .. luacount .. " [" .. cur_lang .. "] localization files with " .. stringcount .. " strings in total.") end
end

function ARC9:LoadLanguages()
    ARC9.PhraseTable = {}

    ARC9:LoadLanguage(_, true)
    ARC9:LoadLanguage(gmod_language:GetString())
    ARC9:LoadLanguage("en")
    ARC9:LoadLanguage("de")
    ARC9:LoadLanguage("es-es")
    ARC9:LoadLanguage("ru")
    ARC9:LoadLanguage("sv-se")
    ARC9:LoadLanguage("uwu")
    ARC9:LoadLanguage("zh-cn")
end

ARC9:LoadLanguages()

if CLIENT then

    concommand.Add("arc9_reloadlangs", function()
        if !LocalPlayer():IsSuperAdmin() then return end

        net.Start("arc9_reloadlangs")
        net.SendToServer()
    end)

    net.Receive("arc9_reloadlangs", function(len, ply)
        ARC9:LoadLanguages()
        ARC9.Regen()
    end)

    local ARC9OldLanguageChanged = LanguageChanged
    function LanguageChanged(lang) -- MIGHT BE VERY BAD
        -- print("New language: " .. lang)
        ARC9:LoadLanguages()
        ARC9.Regen()
        if isfunction(ARC9OldLanguageChanged) then ARC9OldLanguageChanged(lang) end
    end

elseif SERVER then

    net.Receive("arc9_reloadlangs", function(len, ply)
        if !ply:IsSuperAdmin() then return end

        ARC9:LoadLanguages()

        net.Start("arc9_reloadlangs")
        net.Broadcast()
    end)

end

function ARC9:UperCyrillic(str) -- Darsu asked for this.
	local map = {
		["а"]="А", ["б"]="Б", ["в"]="В", ["г"]="Г",
		["д"]="Д", ["е"]="Е", ["ё"]="Ё", ["ж"]="Ж",
		["з"]="З", ["и"]="И", ["й"]="Й", ["к"]="К",
		["л"]="Л", ["м"]="М", ["н"]="Н", ["о"]="О",
		["п"]="П", ["р"]="Р", ["с"]="С", ["т"]="Т",
		["у"]="У", ["ф"]="Ф", ["х"]="Х", ["ц"]="Ц",
		["ч"]="Ч", ["ш"]="Ш", ["щ"]="Щ", ["ъ"]="Ъ",
		["ы"]="Ы", ["ь"]="Ь", ["э"]="Э", ["ю"]="Ю",
		["я"]="Я"
	}
	return (str:gsub("[%z\1-\127\194-\244][\128-\191]*", function(c)
		return map[c] or c
	end))
end
