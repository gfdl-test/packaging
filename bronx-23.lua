-- -*- lua -*-
-- Bronx-23 FRE Environment Module (Lmod version)

-- Get module info
local fullName = myModuleName()
local pkgName, pkgVersion = fullName:match("([^/]+)/([^/]+)")
pkgName, pkgVersion = pkgName or "fre", pkgVersion or "bronx-23"

-- Helper functions
local function getModuleDir()
    if myFileName then
        local path = myFileName()
        if path then
            local realPath = io.popen("readlink -f '" .. path .. "' 2>/dev/null"):read("*a"):gsub("\n$", "")
            return (realPath ~= "" and realPath or path):match("(.*)/") or "."
        end
    end
    return "."
end

local function safeLoad(mod)
    if not isloaded(mod) then
        pcall(load, mod)
    end
end

-- Module metadata
help("Load the FRE environment version " .. pkgVersion)
whatis("The Flexible Runtime Environment version " .. pkgVersion)
conflict("fre", "bronx-23")

-- Site detection
local handle = io.popen("perl -T -e 'use Net::Domain(hostdomain); print hostdomain'")
local domain = handle:read("*a"):gsub("%.?$", "")
handle:close()

local site, sysDir = "gfdl-ws", "/home/fms/local/opt"  -- default
if domain:match("princeton%.rdhpcs%.noaa%.gov") then
    site, sysDir = "gfdl", "/home/fms/local/opt"
elseif domain:match(".*[ct]5%.ncrc%.gov") then
    site, sysDir = "ncrc5", "/ncrc/home2/fms/local/opt"
elseif domain:match(".*c6%.ncrc%.gov") then
    site, sysDir = "ncrc6", "/ncrc/home2/fms/local/opt"
elseif domain:match("HPC%.MsState%.Edu") then
    site, sysDir = "orion", "/apps/contrib/gfdl"
end

-- Set environment
setenv("FRE_SYSTEM_MODULEFILES_DIR", pathJoin(os.getenv("HOME"), "modulefiles"))
setenv("FRE_SYSTEM_SITE", site)
setenv("FRE_SYSTEM_SITES", "gfdl-ws:gfdl:ncrc:orion:ncrc3:ncrc4:ncrc5:ncrc6")

if mode() == "load" then
    -- Load site configuration
    local siteFile = getModuleDir() .. "/." .. site .. ".lua"
    local file = io.open(siteFile, "r")
    if file then
        file:close()
        local config = loadfile(siteFile)()
        config.loadSiteModules(pkgVersion, {}, safeLoad)
        config.setSiteEnvironment()
    end
    
    -- Load core modules
    safeLoad("fre-nctools/2024.05")
    safeLoad(pkgVersion:match("test") and "gcp/test" or "gcp")
    safeLoad("fms-yaml-tools/2026.01")
    safeLoad("hsm/" .. (pkgVersion:match("test") and "test" or "1.3.0"))
    safeLoad("perlbrew")
    
    -- FRE Commands setup
    local isTest = pkgVersion:match("test")
    local pkgHome = isTest and (os.getenv("FRE_COMMANDS_TEST") or pathJoin(sysDir, "fre-commands/test"))
                             or pathJoin(sysDir, "fre-commands/bronx-23")
    
    setenv("FRE_COMMANDS_HOME", pkgHome)
    setenv("FRE_COMMANDS_VERSION", pkgVersion)
    prepend_path("PATH", pathJoin(pkgHome, "bin") .. ":" .. pathJoin(pkgHome, "sbin") .. ":" .. pathJoin(pkgHome, "site", site, "bin"))
    prepend_path("PERL5LIB", pathJoin(pkgHome, "lib"))
    prepend_path("MANPATH", pathJoin(pkgHome, "man"))
    
    LmodMessage("Loading FRE environment version " .. pkgVersion .. " for site " .. site)

elseif mode() == "unload" then
    -- Unload core modules first
    local modules = {"hsm", "gcp", "fms-yaml-tools", "fre-nctools", "perlbrew"}
    for _, mod in ipairs(modules) do
        if isloaded(mod) then unload(mod) end
    end
    
    -- Site-specific unload
    local siteFile = getModuleDir() .. "/." .. site .. ".lua"
    local file = io.open(siteFile, "r")
    if file then
        file:close()
        local config = loadfile(siteFile)()
        if config.unloadSiteModules then config.unloadSiteModules() end
    end
    
    -- Unload dependency modules
    local deps = {"nccmp", "nco", "udunits", "gsl", "netcdf-c", "hdf5", "zlib-ng", "mpich"}
    for _, mod in ipairs(deps) do
        if isloaded(mod) then unload(mod) end
    end
    
    LmodMessage("Unloading FRE environment version " .. pkgVersion)
end
