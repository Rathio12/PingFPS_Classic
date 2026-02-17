-- 1. Initialize Frame with Backdrop Template (Required for Modern Classic/Cata)
local frame = CreateFrame("Frame", "PingFPSClassicFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")

-- 2. Configuration & Defaults
local function GetDefaults()
    return {
        point = "CENTER",
        x = 0,
        y = 0,
        locked = false,
    }
end

-- 3. Setup Visuals
frame:SetSize(130, 26)
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
frame:SetBackdropColor(0, 0, 0, 0.6)
frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
text:SetPoint("CENTER", 0, 1)

-- 4. Movement Logic
frame:SetScript("OnDragStart", function(self)
    if not PingFPSClassicDB.locked then
        self:StartMoving()
    end
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, xOfs, yOfs = self:GetPoint()
    PingFPSClassicDB.point = point
    PingFPSClassicDB.x = xOfs
    PingFPSClassicDB.y = yOfs
end)

-- 5. Data Update Logic (Optimized to 1 second intervals)
local timer = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer < 1 then return end
    timer = 0

    local fps = floor(GetFramerate())
    local _, _, _, latencyWorld = GetNetStats()
    
    -- Color text red if ping is high (>200)
    local pingColor = (latencyWorld > 200) and "|cffff0000" or "|cffffffff"
    text:SetFormattedText("FPS: |cffffffff%d|r  Ping: %s%d|rms", fps, pingColor, latencyWorld)
end)

-- 6. Variables Loading & Positioning
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == "PingFPS_Classic" then
        -- Handle SavedVariables
        if not PingFPSClassicDB then
            PingFPSClassicDB = GetDefaults()
        else
            -- Ensure any missing keys from updates are filled
            local defaults = GetDefaults()
            for k, v in pairs(defaults) do
                if PingFPSClassicDB[k] == nil then
                    PingFPSClassicDB[k] = v
                end
            end
        end
    elseif event == "PLAYER_LOGIN" then
        -- Set Position after UI is fully ready
        self:ClearAllPoints()
        self:SetPoint(
            PingFPSClassicDB.point, 
            UIParent, 
            PingFPSClassicDB.point, 
            PingFPSClassicDB.x, 
            PingFPSClassicDB.y
        )
        
        local lockStatus = PingFPSClassicDB.locked and "Locked" or "Unlocked"
        print("|cff00ff00PingFPS Classic|r loaded. Current status: " .. lockStatus)
    end
end)

-- 7. Slash Commands
SLASH_PINGFPS1 = "/pingfps"
SlashCmdList["PINGFPS"] = function()
    PingFPSClassicDB.locked = not PingFPSClassicDB.locked
    if PingFPSClassicDB.locked then
        print("|cff00ff00PingFPS Classic:|r Frame Locked.")
    else
        print("|cffff0000PingFPS Classic:|r Frame Unlocked (Drag to move).")
    end
end