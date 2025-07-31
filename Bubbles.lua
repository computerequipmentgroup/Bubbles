local x, m, r, b 
local f = CreateFrame("Button", "Bubbles", UIParent)

f:ClearAllPoints()
f:SetWidth(100)
f:SetHeight(50)
f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
f:SetFrameStrata("HIGH")

f.text = f:CreateFontString("Status", "LOW", "GameFontNormal")
f.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
f.text:ClearAllPoints()
f.text:SetAllPoints(f)
f.text:SetPoint("LEFT", 0, 0)
f.text:SetJustifyH("LEFT")
f.text:SetFontObject(GameFontWhite)

local lastUpdate = GetTime()
local lastXP = GetXPExhaustion() or 0
local lastTents = 0
local elapsed = 0
local tents = 0

f:SetScript("OnUpdate", function()
  local now = GetTime()
  local delta = now - lastUpdate
  local threshold = 3.0

  lastUpdate = now
  elapsed = elapsed + delta

  if elapsed >= threshold then
    elapsed = 0

    local currentXP = GetXPExhaustion() or 0
    local gained = currentXP - lastXP
    lastXP = currentXP

    local totalXP = UnitXPMax("player")
    local rate = (gained / totalXP) * 100
    -- ty to https://github.com/Pizzahawaiii/PizzaWorldBuffs/blob/dbfef375451131c62d26db4c15cee5bae5b41133/src/tents.lua#L69
    tents = math.floor(rate / (0.13 * threshold))

    if tents ~= lastTents then
      this = f
      f:GetScript("OnEvent")()
      lastTents = tents
    end
  end
end)

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_XP_UPDATE")
f:RegisterEvent("PLAYER_UPDATE_RESTING")
f:SetScript("OnEvent", function()
  x = UnitXP("player")
  m = UnitXPMax("player")
  r = GetXPExhaustion() or 0

  if -1 == (r or -1) then
    b = 0
  else
    -- ty to https://forum.turtle-wow.org/viewtopic.php?p=65081#p65081
    b = math.floor(20 * r / m + 0.5)
  end

  local text
  if tents > 0 and tents < 10 then
    text = "|cfff58cba" .. b .. "|cffffffff Bubbles |cfff58cba• " .. tents
  else 
    text = "|cfff58cba" .. b .. "|cffffffff Bubbles"
  end

  f.text:SetText(text)
  f:SetWidth(f.text:GetStringWidth() + 10)
end)

f:SetMovable(true)
f:EnableMouse(true)
f:SetScript("OnMouseDown", function()
  this:StartMoving()
end)

f:SetScript("OnMouseUp", function()
  this:StopMovingOrSizing()
  this:SetUserPlaced(true)
end)

f:SetScript("OnEnter", function()
  GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
  GameTooltip_SetDefaultAnchor(GameTooltip, this)

  if -1 == (r or -1) then
    b = 0
  else
    b = math.floor(20 * r / m + 0.5)
  end
  
  GameTooltip:AddLine("|cfff58cbaBubbles (|cffffffff" .. b .. "|cfff58cba)")
  GameTooltip:AddLine("|cffaaaaaaMaximum amount of rested bubbles is 30. To fully rest with one tent takes around 13 minutes. Multiple tents can stack and speed up resting.", 0, 0, 0, true)
  GameTooltip:AddLine(" ")
  GameTooltip:AddDoubleLine("|cffffffffRested", "|cffaaaaaa" .. r .. " XP")
  if r + x > m then
    GameTooltip:AddDoubleLine("|cffffffffRested+", "|cffaaaaaa" .. r + x - m .. " XP")
  end
  GameTooltip:AddDoubleLine("|cffffffffStill", "|cffaaaaaa" .. m - x .. " XP")
  GameTooltip:AddDoubleLine("|cffffffffPercent", "|cffaaaaaa" .. math.floor(x / m * 100) .. "%")
  if isRestingFr then
    GameTooltip:AddDoubleLine("|cffffffffStatus", "|cffaaaaaaGaining from " .. f.tents .. " tent(s)")
  end

  GameTooltip:Show()
end)

f:SetScript("OnLeave", function()
  GameTooltip:Hide()
end)

DEFAULT_CHAT_FRAME:AddMessage("|cfff58cbaBubbles |cffffffff1.0 loaded")
