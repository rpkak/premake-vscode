local p = premake

local vscode = p.modules.vscode

newaction {
    trigger = "vscode",
    shortname = "Visual Studio Code",
    description = "Generate Visual Studio Code workspace and C/C++ configuration files",

    valid_kinds = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "None" },

    valid_languages = { "C", "C++" },

    onWorkspace = function(wks)
        p.escaper(vscode.jsonEsc)
        p.generate(wks, ".code-workspace", vscode.generateWorkspace)
    end,

    execute = function()
        p.escaper(vscode.jsonEsc)

        _, ltp = vscode.locationsToProject(wks)

        for location, prjs in pairs(ltp) do
            vscode.generateLocation(location, prjs, ".vscode/c_cpp_properties.json", vscode.ccppproperties.generateCCPPProperties)
        end
    end
}

return function(cfg)
    return (_ACTION == "vscode")
end

