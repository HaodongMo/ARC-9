// the 0 is for load order!!!

local conVars = {
    {
        name = "truenames",
        default = "2",
        client = true,
        min = 0,
        max = 2,
    },
    {
        name = "truenames_default",
        default = "0",
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "truenames_enforced",
        default = "0",
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "language",
        default = "",
        client = true,
    },
    {
        name = "font",
        default = "",
        client = true,
    },
    {
        name = "maxatts",
        default = "100",
    },
    {
        name = "autosave",
        default = "1",
        client = true
    },
    {
        name = "fov",
        default = "0",
        client = true
    },
    {
        name = "bodydamagecancel",
        default = "1",
        replicated = true
    },
    {
        name = "free_atts",
        default = "0",
        replicated = true
    },
    {
        name = "lock_atts",
        default = "0",
        replicated = true
    },
    {
        name = "loseattsondie",
        default = "1",
    },
    {
        name = "generateattentities",
        default = "1",
        replicated = true
    },
    {
        name = "npc_equality",
        default = "0",
    },
    {
        name = "npc_atts",
        default = "1",
    },
    {
        name = "penetration",
        default = "1",
        replicated = true
    },
    {
        name = "freeaim",
        default = "1",
        replicated = true
    },
    {
        name = "sway",
        default = "1",
        replicated = true
    },
    {
        name = "benchgun",
        default = "0",
    },
    {
        name = "ricochet",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_physics",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_gravity",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_drag",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_imaginary",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_lifetime",
        default = "10",
        replicated = true
    },
    {
        name = "cheapscopes",
        default = "0"
    },
    {
        name = "truenames",
        default = "1",
        replicated = true
    },
    {
        name = "compensate_sens",
        default = "1"
    },
    {
        name = "freeaim",
        default = "1"
    }
}

local prefix = "arc9_"

for _, var in pairs(conVars) do
    local convar_name = prefix .. var.name

    if var.client and CLIENT then
        CreateClientConVar(convar_name, var.default, true)
    else
        local flags = FCVAR_ARCHIVE
        if var.replicated then
            flags = flags + FCVAR_REPLICATED
        end
        CreateConVar(convar_name, var.default, flags, var.helptext, var.min, var.max)
    end
end

if CLIENT then

local function menu_client_ti(panel)
    panel:AddControl("checkbox", {
        label = "Reload Automatically",
        command = "arc9_autoreload"
    })
    panel:AddControl("checkbox", {
        label = "Auto-Save Weapon",
        command = "arc9_autosave"
    })
    panel:AddControl("checkbox", {
        label = "Compensate Sensitivity",
        command = "arc9_compensate_sens"
    })
end

local function menu_server_ti(panel)
    panel:AddControl("checkbox", {
        label = "Free Attachments",
        command = "ARC9_free_atts"
    })
    panel:AddControl("checkbox", {
        label = "Attachment Locking",
        command = "ARC9_lock_atts"
    })
    panel:AddControl("checkbox", {
        label = "Lose Attachments On Death",
        command = "ARC9_loseattsondie"
    })
    panel:AddControl("checkbox", {
        label = "Generate Attachment Entities",
        command = "arc9_generateattentities"
    })
    panel:AddControl("checkbox", {
        label = "Enable Penetration",
        command = "ARC9_penetration"
    })
    panel:AddControl("checkbox", {
        label = "NPCs Deal Equal Damage",
        command = "ARC9_npc_equality"
    })
    panel:AddControl("checkbox", {
        label = "NPCs Get Random Attachments",
        command = "ARC9_npc_atts"
    })
    panel:AddControl("label", {
        text = "Disable body damage cancel only if you have another addon that will override the hl2 limb damage multipliers."
    })
    panel:AddControl("checkbox", {
        label = "Default Body Damage Cancel",
        command = "ARC9_bodydamagecancel"
    })
end

local clientmenus_ti = {
    {
        text = "Client", func = menu_client_ti
    },
    {
        text = "Server", func = menu_server_ti
    },
}

hook.Add("PopulateToolMenu", "ARC9_MenuOptions", function()
    for smenu, data in pairs(clientmenus_ti) do
        spawnmenu.AddToolMenuOption("Options", "ARC-9", "ARC9_" .. tostring(smenu), data.text, "", "", data.func)
    end
end)

end