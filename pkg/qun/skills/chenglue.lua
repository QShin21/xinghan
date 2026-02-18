-- SPDX-License-Identifier: GPL-3.0-or-later
-- 许攸 - 成略技能
-- 转换技，出牌阶段限一次，①你可以摸一张牌，然后弃置两张手牌。
-- ②你可以摸两张牌，然后弃置一张手牌。
-- 若如此做，直到本回合结束，你使用与弃置牌相同花色的牌无距离和次数限制。

local chenglue = fk.CreateSkill {
  name = "chenglue",
}

Fk:loadTranslationTable {
  ["chenglue"] = "成略",
  [":chenglue"] = "转换技，出牌阶段限一次，①你可以摸一张牌，然后弃置两张手牌。"..
    "②你可以摸两张牌，然后弃置一张手牌。"..
    "若如此做，直到本回合结束，你使用与弃置牌相同花色的牌无距离和次数限制。",

  ["#chenglue-use"] = "成略：选择弃置的牌",
  ["@@chenglue_suits"] = "成略",

  ["$chenglue1"] = "成略之计，智取天下！",
  ["$chenglue2"] = "许攸成略，天下无双！",
}

chenglue:addEffect("active", {
  mute = true,
  prompt = "#chenglue-use",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(chenglue.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, chenglue.name, "draw")
    player:broadcastSkillInvoke(chenglue.name)

    local state = player:getMark("@@chenglue_state") or 0
    
    local draw_num, discard_num
    if state == 0 then
      draw_num = 1
      discard_num = 2
    else
      draw_num = 2
      discard_num = 1
    end
    
    -- 摸牌
    player:drawCards(draw_num, chenglue.name)
    
    -- 弃牌
    local cards = room:askToCards(player, {
      min_num = discard_num,
      max_num = discard_num,
      include_equip = false,
      skill_name = chenglue.name,
      pattern = ".",
      prompt = "选择" .. discard_num .. "张手牌弃置",
      cancelable = false,
    })
    
    -- 记录弃置牌的花色
    local suits = {}
    for _, id in ipairs(cards) do
      local suit = Fk:getCardById(id).suit
      if not table.contains(suits, suit) then
        table.insert(suits, suit)
      end
    end
    
    room:throwCard(cards, chenglue.name, player, player)
    
    -- 设置花色标记
    room:setPlayerMark(player, "@@chenglue_suits", suits)
    
    -- 切换状态
    room:setPlayerMark(player, "@@chenglue_state", state == 0 and 1 or 0)
  end,
})

-- 无距离和次数限制
chenglue:addEffect("targetmod", {
  distance_limit_func = function(self, player, skill, card, to)
    local suits = player:getMark("@@chenglue_suits")
    if suits and type(suits) == "table" and table.contains(suits, card.suit) then
      return true
    end
    return false
  end,
  residue_func = function(self, player, skill, scope, card)
    if skill.trueName == "slash_skill" then
      local suits = player:getMark("@@chenglue_suits")
      if suits and type(suits) == "table" and table.contains(suits, card.suit) then
        return 999
      end
    end
    return 0
  end,
})

-- 回合结束清除标记
chenglue:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@chenglue_suits") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@chenglue_suits", 0)
  end,
})

return chenglue
