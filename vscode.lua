local p = premake
local project = p.project

p.modules.vscode = {}
local vscode = p.modules.vscode

-- Modified version of p.generate

function vscode.generateLocation(location, prjs, ext, callback)
    local output = p.capture(function ()
        _indentLevel = 0
        callback(prjs)
        _indentLevel = 0
    end)

    local fn = path.join(location, ext)

    -- make sure output folder exists.
    local dir = path.getdirectory(fn)
    local ok, err = os.mkdir(dir)
    if not ok then
        error(err, 0)
    end

    local f, err = os.writefile_ifnotequal(output, fn);

    if (f == 0) then
        return false -- file not modified
    elseif (f < 0) then
        error(err, 0)
    elseif (f > 0) then
        printf("Generated %s...", path.getrelative(os.getcwd(), fn))
        return true -- file modified
    end
end

function vscode.locationsToProject(wks)
    local iter
    if wks then
        local returned = false
        iter = function()
            if not returned then
                returned = true
                return wks
            end
        end
    else
        iter = p.global.eachWorkspace()
    end

    local ltp = {}
    local n = 0
    for wks in iter do
        for prj in p.workspace.eachproject(wks) do
            if not ltp[prj.location] then
                ltp[prj.location] = {}
                n = n + 1
            end
            table.insert(ltp[prj.location], prj)
        end
    end

    return n, ltp
end

function vscode.generateWorkspace(wks)
    p.push("{")
    p.push("\"folders\": [")

    n, ltp = vscode.locationsToProject(wks)

    local i = 1

    for location, prjs in pairs(ltp) do
        p.push("{")

        local prjnames = ''

        for i = 1, #prjs do
            if i == #prjs then
                prjnames = prjnames .. prjs[i].name
            else
                prjnames = prjnames .. prjs[i].name .. ', '
            end
        end

        p.x("\"path\": \"%s\",", location)
        p.x("\"name\": \"%s\"", prjnames)

        if i == n then
            p.pop("}")
        else
            p.pop("},")
        end
        i = i + 1
    end

    p.pop("]")
    p.pop("}")
end

function vscode.getToolSetName(cfg)
    if _OPTIONS.cc then
        return _OPTIONS.cc
    elseif cfg.toolset then
        return cfg.toolset
    else
        local systemTags = os.getSystemTags(cfg.system)
        if table.contains(systemTags, "darwin") then
            return "clang"
        elseif table.contains(systemTags, "windows") then
            return "msc"
        else
            return "gcc"
        end
    end
end

-- Copy of gmake2.getToolSet

function vscode.getToolSet(cfg)
    local toolset = p.tools[vscode.getToolSetName(cfg)]
    if not toolset then
        error("Invalid toolset '" .. cfg.toolset .. "'")
    end
    return toolset
end

function vscode.outputSection(prjs, callback)
    for i = 1, #prjs do
        local cfgs = {}

        for cfg in project.eachconfig(prjs[i]) do
            table.insert(cfgs, cfg)
        end

        for j = 1, #cfgs do
            p.push("{")
            toolset = vscode.getToolSet(cfgs[j])

            local funcs = callback(cfgs[j])
            for k = 1, #funcs do
                funcs[k](cfgs[j], toolset)
            end

            if i == #prjs and j == #cfgs then
                p.pop("}")
            else
                p.pop("},")
            end
        end
    end
end

function vscode.jsonEsc(value)
    value = value:gsub("\\","\\\\")
    value = value:gsub("\"","\\\"")
    return value
end

include("_preload.lua")

include("vscode_c_cpp_properties.lua")

return vscode
