--[[
AdiBags_Lowlevel - Adds Lowlevel filters to AdiBags.
Copyright 2016 seirl
All rights reserved.
--]]

local _, ns = ...

local addon = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
local L = setmetatable({}, {__index = addon.L})

local tooltip
local function create()
  local tip, leftside = CreateFrame("GameTooltip"), {}
  for i = 1,6 do
    local L,R = tip:CreateFontString(), tip:CreateFontString()
    L:SetFontObject(GameFontNormal)
    R:SetFontObject(GameFontNormal)
    tip:AddFontStrings(L,R)
    leftside[i] = L
  end
  tip.leftside = leftside
  return tip
end

-- The filter itself

local setFilter = addon:RegisterFilter("Lowlevel_BoE", 62, 'ABEvent-1.0')
setFilter.uiName = L['Lowlevel_BoE']
setFilter.uiDesc = L['Put low level BoE items in their own sections.']

-- local setFilter2 = addon:RegisterFilter("Lowlevel_BoP", 62, 'ABEvent-1.0')
-- setFilter.uiName = L['Lowlevel_BoP']
-- setFilter.uiDesc = L['Put low level BoP items in their own sections.']

function setFilter:OnInitialize()
  self.db = addon.db:RegisterNamespace('Lowlevel', {
    profile = { enable = true, level = 400 },
    char = {  },
  })
end

function setFilter:Update()
  self:SendMessage('AdiBags_FiltersChanged')
end

function setFilter:OnEnable()
  addon:UpdateFilters()
end

function setFilter:OnDisable()
  addon:UpdateFilters()
end

local setNames = {}

function setFilter:Filter(slotData)
  GlobalSlotData = slotData;

  local lowlevel = false
  local boe = false
  local ilvl, isPreview, baselvl = GetDetailedItemLevelInfo(slotData.link)
  if (ilvl == nil) then
	return
  end

  boe = C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(slotData.bag, slotData.slot))
  boe = not boe

  if ilvl < self.db.profile.level then
	lowlevel = true
  end
  if slotData.class ~= "Armor" and slotData.class ~= "Weapon" then
    return
  end

  if lowlevel and boe then
    return "Low Level BoE"
  end
  if lowlevel then
    return "Low Level BoP"
  end
end

function setFilter:GetOptions()
  return {
    enable = {
      name = L['Enable Lowlevel BoE'],
      desc = L['Check this if you want a section for lowlevel items.'],
      type = 'toggle',
      order = 10,
    },
    level = {
      name = L['Item level'],
      desc = L['Minimum item level matched'],
      type = 'range',
      min = 0,
      max = 1000,
      step = 1,
      order = 20,
    },
  }, addon:GetOptionHandler(self, false, function() return self:Update() end)
end
