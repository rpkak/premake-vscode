local p = premake

local vscode = p.modules.vscode
vscode.ccppproperties = {}
local ccppproperties = vscode.ccppproperties
ccppproperties.elements = {}


ccppproperties.elements.configurations = function(cfg)
    return {
        ccppproperties.name,
        ccppproperties.compilerPath,
        ccppproperties.flags,
        ccppproperties.intelliSenseMode,
        ccppproperties.includePath,
        ccppproperties.defines,
        ccppproperties.cStandard,
        ccppproperties.cppStandard,
        ccppproperties.windowsSdkVersion,
        ccppproperties.forcedInclude
    }
end

function ccppproperties.generateCCPPProperties(prjs)
    p.push("{")
    p.push("\"configurations\": [")
    vscode.outputSection(prjs, ccppproperties.elements.configurations)
    p.pop("],")
    p.w("\"version\": 4")
    p.pop("}")
end

function ccppproperties.name(cfg, toolset)
    local name
    if cfg.platform then
        name = cfg.project.name .. "-" .. cfg.platform .. "-" .. cfg.buildcfg
    else
        name = cfg.project.name .. "-" .. cfg.buildcfg
    end
    p.x("\"name\": \"%s\",", name)
end

function ccppproperties.compilerPath(cfg, toolset)
    local tool = toolset.gettoolname(cfg, iif(p.languages.isc(cfg.language), "cc", "cxx"))
    if tool then
        local toolpath = os.pathsearch(tool, os.getenv("PATH"))
        if toolpath then
            p.x("\"compilerPath\": \"%s\",", toolpath .. '/' .. tool)
        end
    end
end

function ccppproperties.flags(cfg, toolset)
    p.push("\"compilerArgs\": [")
    local flags = table.join(toolset.getcflags(cfg), toolset.getcppflags(cfg))
    for i = 1, #flags do
        if i == #flags then
            p.x("\"%s\"", flags[i])
        else
            p.x("\"%s\",", flags[i])
        end
    end
    p.pop("],")
end

function ccppproperties.intelliSenseMode(cfg, toolset)
    local intelliSenseMode = ""
    
    local toolSetName = vscode.getToolSetName(cfg)
    if toolSetName == "msc" then
        intelliSenseMode = "msvc"
    elseif toolSetName == "clang" then
        intelliSenseMode = "clang"
    else -- GCC/MinGW
        intelliSenseMode = "gcc"
    end

    if cfg.architecture == p.X86 then
        intelliSenseMode = intelliSenseMode .. '-x86'
    elseif cfg.architecture == p.ARM then
        intelliSenseMode = intelliSenseMode .. '-arm'
    elseif cfg.architecture == p.ARM64 then
        intelliSenseMode = intelliSenseMode .. '-arm64'
    else
        intelliSenseMode = intelliSenseMode .. '-x64'
    end

    local systemTags = os.getSystemTags(cfg.system)
    if table.contains(systemTags, "darwin") then
        intelliSenseMode = "macos-" .. intelliSenseMode
    elseif table.contains(systemTags, "windows") then
        intelliSenseMode = "windows-" .. intelliSenseMode
    elseif table.contains(systemTags, "linux") then
        intelliSenseMode = "linux-" .. intelliSenseMode
    end

    p.x("\"intelliSenseMode\": \"%s\",", intelliSenseMode)
end

function ccppproperties.includePath(cfg, toolset)
    p.push("\"includePath\": [")
    local includedirs = table.join((cfg.includedirs or {}), (cfg.externalincludedirs or {}))
    for i = 1, #includedirs do
        if i == #includedirs then
            p.x("\"%s\"", includedirs[i])
        else
            p.x("\"%s\",", includedirs[i])
        end
    end
    p.pop("],")
end

function ccppproperties.defines(cfg, toolset)
    p.push("\"defines\": [")
    for i = 1, #cfg.defines do
        if i == #cfg.defines then
            p.x("\"%s\"", cfg.defines[i])
        else
            p.x("\"%s\",", cfg.defines[i])
        end
    end
    p.pop("],")
end

function ccppproperties.cStandard(cfg, toolset)
    if cfg.cdialect == "C89" or cfg.cdialect == "C90" then
        p.w("\"cStandard\": \"c89\",")
    elseif cfg.cdialect == "C99" then
        p.w("\"cStandard\": \"c99\",")
    elseif cfg.cdialect == "C11" then
        p.w("\"cStandard\": \"c11\",")
    elseif cfg.cdialect == "C17" then
        p.w("\"cStandard\": \"c17\",")
    elseif cfg.cdialect == "gnu89" or cfg.cdialect == "gnu90" then
        p.w("\"cStandard\": \"gnu89\",")
    elseif cfg.cdialect == "gnu99" then
        p.w("\"cStandard\": \"gnu99\",")
    elseif cfg.cdialect == "gnu11" then
        p.w("\"cStandard\": \"gnu11\",")
    elseif cfg.cdialect == "gnu17" then
        p.w("\"cStandard\": \"gnu17\",")
    end
end

function ccppproperties.cppStandard(cfg, toolset)
    if cfg.cppdialect == "C++98" then
        p.w("\"cppStandard\": \"c++98\",")
    elseif cfg.cppdialect == "C++0x" or cfg.cppdialect == "C++11" then
        p.w("\"cppStandard\": \"c++11\",")
    elseif cfg.cppdialect == "C++1y" or cfg.cppdialect == "C++14" then
        p.w("\"cppStandard\": \"c++14\",")
    elseif cfg.cppdialect == "C++1z" or cfg.cppdialect == "C++17" then
        p.w("\"cppStandard\": \"c++17\",")
    elseif cfg.cppdialect == "C++2a" or cfg.cppdialect == "C++20" then
        p.w("\"cppStandard\": \"c++20\",")
    elseif cfg.cppdialect == "C++latest" then
        p.w("\"cppStandard\": \"c++23\",")
    elseif cfg.cppdialect == "gnu++98" then
        p.w("\"cppStandard\": \"gnu++98\",")
    elseif cfg.cppdialect == "gnu++0x" or cfg.cppdialect == "gnu++11" then
        p.w("\"cppStandard\": \"gnu++11\",")
    elseif cfg.cppdialect == "gnu++1y" or cfg.cppdialect == "gnu++14" then
        p.w("\"cppStandard\": \"gnu++14\",")
    elseif cfg.cppdialect == "gnu++1z" or cfg.cppdialect == "gnu++17" then
        p.w("\"cppStandard\": \"gnu++17\",")
    elseif cfg.cppdialect == "gnu++2a" or cfg.cppdialect == "gnu++20" then
        p.w("\"cppStandard\": \"gnu++20\",")
    end
end

function ccppproperties.windowsSdkVersion(cfg, toolset)
    if table.contains(os.getSystemTags(cfg.system), "windows") and cfg.project.systemversion then
        if cfg.project.systemversion == "8.1" then
            p.w("\"windowsSdkVersion\": \"8.1\",")
        elseif string.find(cfg.project.systemversion, "^%d%d%.%d%.%d%d%d%d%d%.%d$") then
            p.x("\"windowsSdkVersion\": \"%s\",", cfg.project.systemversion)
        end
    end
end

function ccppproperties.forcedInclude(cfg, toolset)
    p.push("\"forcedInclude\": [")
    for i = 1, #cfg.forceincludes do
        if i == #cfg.forceincludes then
            p.x("\"%s\"", cfg.forceincludes[i])
        else
            p.x("\"%s\",", cfg.forceincludes[i])
        end
    end
    p.pop("]")
end
