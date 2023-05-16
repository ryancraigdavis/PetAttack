--[[
**********************************************************************
Pet Attack - Small addon that will insist you make your pet attack
while you are in combat.
**********************************************************************
This file is part of Pet Attack, a World of Warcraft Addon

Pet Attack is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

Pet Attack is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with Optimus Protestas.  If not, see
<http://www.gnu.org/licenses/>.

**********************************************************************
]]
PetAttackAddon = LibStub("AceAddon-3.0"):NewAddon("PetAttack", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("PetAttack")

local mod = PetAttackAddon
local warningTextFrame


function mod:HasPermaPet()
   local _,class = UnitClass("player")
   if class == "WARLOCK" then
      local id
      for i=1,40 do
         _,_,_,_,_,_,_,_,_,_,id = UnitBuff("player", i, "PLAYER")
         if id == 108503 then return false end
         if id == nil then return true end
      end
      return true
   elseif class == "HUNTER" then
   elseif class == "MAGE" then
      return not not GetSpellBookItemInfo("Summon Water Elemental")
   elseif class == "DEATHKNIGHT" then
      return not not GetSpellBookItemInfo("Scourge Strike")
   end
   return false
end
function mod:OnEnable()
   mod:RegisterEvent("PLAYER_REGEN_ENABLED")
   mod:RegisterEvent("PLAYER_REGEN_DISABLED")
end

function mod:OnInitialize()
   warningTextFrame = CreateFrame("Frame", nil, UIParent)
   warningTextFrame:SetWidth(400)
   warningTextFrame:SetHeight(50)
   warningTextFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
   warningTextFrame:Hide()

   warningTextFrame.label = warningTextFrame:CreateFontString(nil, "OVERLAY", "SystemFont_OutlineThick_WTF")
   warningTextFrame.label:SetAllPoints()
   local font, size, flags = warningTextFrame.label:GetFont()
   warningTextFrame.label:SetFont(font, size*2, flags)
   warningTextFrame.label:SetText(L["PET IS NOT ATTACKING"])

   warningTextFrame.animgroup = warningTextFrame.label:CreateAnimationGroup("bounceZoom")
   warningTextFrame.animgroup:SetLooping("BOUNCE")
   warningTextFrame.animgroup.zoom = warningTextFrame.animgroup:CreateAnimation("ALPHA")
   warningTextFrame.animgroup.zoom:SetChange(-0.7)
   warningTextFrame.animgroup.zoom:SetDuration(0.5)

   
end

function mod:PLAYER_REGEN_ENABLED()
   mod:StopReminding();
   mod:UnregisterEvent("UNIT_TARGET")
end

function mod:PLAYER_REGEN_DISABLED()
   if mod:HasPermaPet() then
      mod:StartReminding();
      mod:RegisterEvent("UNIT_TARGET")
   end
end

function mod:UNIT_TARGET(event, unit)
   if unit == "pet" then
      local target = UnitExists("pettarget")
      if target and mod.isAnnoying then
	 mod:StopReminding()
      elseif not target and not mod.isAnnoying then
	 mod:StartReminding()
      end
   end
end

function mod:StartReminding()
   if not UnitExists("pettarget") then
      mod.isAnnoying = true
      warningTextFrame:Show()
      warningTextFrame.animgroup:Play()
   end
end

function mod:StopReminding()
   mod.isAnnoying = false
   warningTextFrame:Hide()
   warningTextFrame.animgroup:Stop()
end
