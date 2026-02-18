-- SPDX-License-Identifier: GPL-3.0-or-later
-- 武安国 - 历勇技能
-- 转换技，出牌阶段每项限一次，
-- 阳：你可以将一张本回合你未使用过的花色的牌当【决斗】使用；
-- 阴：你可以从弃牌堆中获得一张你本回合使用过的花色的牌，令一名角色视为对你使用一张【决斗】。

local liyong = fk.CreateSkill {
  name = "liyong",
}

Fk:loadTranslationTable {
  ["liyong"] = "历勇",
  [":liyong"] = "转换技，出牌阶段每项限一次，阳：你可以将一张本回合你未使用过的花色的牌当【决斗】使用；"..
    "阴：你可以从弃牌堆中获得一张你本回合使用过的花色的牌，令一名角色视为对你使用一张【决斗】。",

  ["@@liyong-state"] = "历勇状态",
  ["@@liyong_used_suits"] = "历勇花色",
  ["#liyong-yang"] = "历勇（阳）：将一张未使用花色的牌当【决斗】使用",
  ["#liyong-yin"] = "历勇（阴）：从弃牌堆获得一张已使用花色的牌，令角色对你使用【决斗】",

  ["$liyong1"] = "历勇无双，勇冠三军！",
  ["$liyong2"] = "勇猛精进，无坚不摧！",
}

-- 初始化状态
liyong:addEffect(fk.GameStart, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(liyong.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@liyong-state", "yang")
  end,
})

-- 记录使用过的花色
liyong:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(liyong.name) and
      player.phase == Player.Play and data.card
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.card
    local suits = player:getMark("@@liyong_used_suits") or {}

    if card.suit and not table.contains(suits, card.suit) then
      table.insert(suits, card.suit)
      room:setPlayerMark(player, "@@liyong_used_suits", suits)
    end
  end,
})

-- 阳状态：将未使用花色的牌当决斗使用
liyong:addEffect("viewas", {
  mute = true,
  pattern = "duel",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local state = player:getMark("@@liyong-state")
    if state ~= "yang" then return false end
    if player:usedEffectTimes(liyong.name .. "_yang", Player.HistoryPhase) > 0 then return false end

    local card = Fk:getCardById(to_select)
    local suits = player:getMark("@@liyong_used_suits") or {}

    return card.suit and not table.contains(suits, card.suit)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("duel")
    card.skillName = liyong.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    local state = player:getMark("@@liyong-state")
    return state == "yang" and
      player:usedEffectTimes(liyong.name .. "_yang", Player.HistoryPhase) == 0 and
      player:canUse(Fk:cloneCard("duel"))
  end,
})

-- 使用后切换状态
liyong:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.skillName == liyong.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local state = player:getMark("@@liyong-state")

    if state == "yang" then
      room:setPlayerMark(player, "@@liyong-state", "yin")
    else
      room:setPlayerMark(player, "@@liyong-state", "yang")
    end
  end,
})

return liyong
