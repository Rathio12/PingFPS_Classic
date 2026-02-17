-- 1. Create the Frame with Backdrop Compatibility
-- This check ensures it works on both the old TBC engine and the modern Anniversary engine
local frame = CreateFrame("Frame", "PingFPSClassicFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")

-- 2. Configuration & Defaults
local function ApplyDefaults()
    if not PingFPSClassicDB then
        PingFPSClassicDB = {
            point = "CENTER",
            x = 0,
            y = 0,
            locked = false,
        }
    end
end

-- 3. Visual Setup
frame:SetSize(130, 26)
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

-- Backdrop settings (The classic look)
frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
frame:SetBackdropColor(0, 0, 0, 0.6)

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
    local point, _, _, x, y = self:GetPoint()
    PingFPSClassicDB.point = point
    PingFPSClassicDB.x = x
    PingFPSClassicDB.y = y
end)

-- 5. Data Refresh (TBC/Classic safe)
local lastUpdate = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate < 1 then return end -- Refresh once per second
    lastUpdate = 0

    local fps = floor(GetFramerate())
    -- GetNetStats returns 4 values in TBC/Classic Era (Down, Up, Home Ping, World Ping)
    local _, _, _, latencyWorld = GetNetStats()
    
    text:SetFormattedText("FPS: |cffffffff%d|r  Ping: |cffffffff%d|rms", fps, latencyWorld or 0)
end)

-- 6. Initialization
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addon ~= "PingFPS_Classic" then return end
    
    ApplyDefaults()

    -- Apply saved position
    self:ClearAllPoints()
    self:SetPoint(
        PingFPSClassicDB.point, 
        UIParent, 
        PingFPSClassicDB.point, 
        PingFPSClassicDB.x, 
        PingFPSClassicDB.y
    )
end)

-- 7. Slash Command to Lock/Unlock
SLASH_PINGFPS1 = "/pingfps"
SlashCmdList["PINGFPS"] = function()
    PingFPSClassicDB.locked = not PingFPSClassicDB.locked
    local status = PingFPSClassicDB.locked and "|cff00ff00Locked|r" or "|cffff0000Unlocked|r"
    print("|cff00ff00PingFPS:|r Frame is now " .. status)
end