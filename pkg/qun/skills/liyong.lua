-- SPDX-License-Identifier: GPL-3.0-or-later
-- 武安国 - 历勇技能
-- 转换技，出牌阶段每项限一次，阳：你可以将一张本回合你未使用过的花色的牌当【决斗】使用；
-- 阴：你可以从弃牌堆中获得一张你本回合使用过的花色的牌，令一名角色视为对你使用一张【决斗】。

local liyong = fk.CreateSkill {
  name = "liyong",
}

Fk:loadTranslationTable {
  ["liyong"] = "历勇",
  [":liyong"] = "转换技，出牌阶段每项限一次，阳：你可以将一张本回合你未使用过的花色的牌当【决斗】使用；"..
    "阴：你可以从弃牌堆中获得一张你本回合使用过的花色的牌，令一名角色视为对你使用一张【决斗】。",

  ["#liyong-use"] = "历勇：选择一张牌",

  ["$liyong1"] = "历勇之威，势不可挡！",
  ["$liyong2"] = "勇冠三军，所向披靡！",
}

liyong:addEffect("viewas", {
  mute = true,
  pattern = "duel",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    
    local state = player:getMark("@@liyong_state") or 0
    local used_suits = player:getMark("@@liyong_used_suits") or {}
    
    if state == 0 then
      -- 阳：未使用过的花色
      local suit = Fk:getCardById(to_select).suit
      return not table.contains(used_suits, suit)
    else
      -- 阴：使用过的花色
      local suit = Fk:getCardById(to_select).suit
      return table.contains(used_suits, suit)
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    
    local card = Fk:cloneCard("duel")
    card.skillName = liyong.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    local state = player:getMark("@@liyong_state") or 0
    local used = player:getMark("@@liyong_used_" .. state) or 0
    return used == 0
  end,
})

-- 使用后切换状态
liyong:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card and data.card.skillName == liyong.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local state = player:getMark("@@liyong_state") or 0
    
    -- 记录已使用
    room:setPlayerMark(player, "@@liyong_used_" .. state, 1)
    
    -- 切换状态
    room:setPlayerMark(player, "@@liyong_state", state == 0 and 1 or 0)
  end,
})

-- 记录使用过的花色
liyong:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and data.card
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local used_suits = player:getMark("@@liyong_used_suits") or {}
    
    if type(used_suits) ~= "table" then used_suits = {} end
    
    table.insert(used_suits, data.card.suit)
    room:setPlayerMark(player, "@@liyong_used_suits", used_suits)
  end,
})

-- 回合结束清除标记
liyong:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@liyong_state") ~= 0 or player:getMark("@@liyong_used_suits") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@liyong_state", 0)
    room:setPlayerMark(player, "@@liyong_used_suits", 0)
    room:setPlayerMark(player, "@@liyong_used_0", 0)
    room:setPlayerMark(player, "@@liyong_used_1", 0)
  end,
})

return liyong
