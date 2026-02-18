-- SPDX-License-Identifier: GPL-3.0-or-later
-- 郭汜 - 伺盗技能
-- 出牌阶段限一次，当你对一名其他角色连续使用两张牌后，你可以将一张手牌当【顺手牵羊】对其使用。

local sidao = fk.CreateSkill {
  name = "sidao",
}

Fk:loadTranslationTable {
  ["sidao"] = "伺盗",
  [":sidao"] = "出牌阶段限一次，当你对一名其他角色连续使用两张牌后，你可以将一张手牌当【顺手牵羊】对其使用。",

  ["#sidao-invoke"] = "伺盗：将一张手牌当【顺手牵羊】对 %dest 使用",
  ["#sidao-use"] = "伺盗：选择一张手牌当【顺手牵羊】使用",

  ["$sidao1"] = "伺机而动，盗亦有道！",
  ["$sidao2"] = "顺手牵羊，不费吹灰之力！",
}

-- 记录连续使用的牌
sidao:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(sidao.name) then return false end
    if player.phase ~= Player.Play then return false end

    local tos = data.tos
    if not tos or #tos ~= 1 then return false end

    local last_target = player:getMark("@@sidao_last_target")
    local last_card = player:getMark("@@sidao_last_card")

    if last_target == tos[1] and last_card then
      -- 连续对同一目标使用两张牌
      room:setPlayerMark(player, "@@sidao_trigger", tos[1])
    end

    room:setPlayerMark(player, "@@sidao_last_target", tos[1])
    room:setPlayerMark(player, "@@sidao_last_card", data.card.id)

    return false
  end,
})

sidao:addEffect("viewas", {
  mute = true,
  pattern = "snatch",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local trigger_target = player:getMark("@@sidao_trigger")
    if trigger_target == 0 then return false end
    return player:getCardIds("h")[1] == to_select
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("snatch")
    card.skillName = sidao.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@@sidao_trigger") ~= 0 and
      player:usedSkillTimes(sidao.name, Player.HistoryPhase) == 0 and
      not player:isKongcheng()
  end,
})

-- 使用后清除标记
sidao:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.skillName == sidao.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@sidao_trigger", 0)
  end,
})

-- 回合结束清除标记
sidao:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@sidao_last_target") ~= 0 or
           player:getMark("@@sidao_last_card") ~= 0 or
           player:getMark("@@sidao_trigger") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@sidao_last_target", 0)
    room:setPlayerMark(player, "@@sidao_last_card", 0)
    room:setPlayerMark(player, "@@sidao_trigger", 0)
  end,
})

return sidao
