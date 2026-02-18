-- SPDX-License-Identifier: GPL-3.0-or-later
-- 王允 - 解悬技能
-- 转换技，出牌阶段限一次，
-- 阳：你可以将一张红色牌当【顺手牵羊】使用；
-- 阴：你可以将一张黑色牌当【过河拆桥】使用。

local jiexuan = fk.CreateSkill {
  name = "jiexuan",
}

Fk:loadTranslationTable {
  ["jiexuan"] = "解悬",
  [":jiexuan"] = "转换技，出牌阶段限一次，阳：你可以将一张红色牌当【顺手牵羊】使用；阴：你可以将一张黑色牌当【过河拆桥】使用。",

  ["@@jiexuan-state"] = "解悬状态",
  ["#jiexuan-yang"] = "解悬（阳）：将一张红色牌当【顺手牵羊】使用",
  ["#jiexuan-yin"] = "解悬（阴）：将一张黑色牌当【过河拆桥】使用",

  ["$jiexuan1"] = "解民倒悬，济世安民！",
  ["$jiexuan2"] = "悬而未决，当断则断！",
}

-- 初始化状态
jiexuan:addEffect(fk.GameStart, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(jiexuan.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@jiexuan-state", "yang")
  end,
})

jiexuan:addEffect("viewas", {
  mute = true,
  pattern = "snatch,duel",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local card = Fk:getCardById(to_select)
    local state = player:getMark("@@jiexuan-state")

    if state == "yang" then
      return card.color == Card.Red
    else
      return card.color == Card.Black
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end

    local state = player:getMark("@@jiexuan-state")
    local card

    if state == "yang" then
      card = Fk:cloneCard("snatch")
    else
      card = Fk:cloneCard("duel")
    end

    card.skillName = jiexuan.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(jiexuan.name, Player.HistoryPhase) > 0 then
      return false
    end

    local state = player:getMark("@@jiexuan-state")
    local handcards = player:getCardIds("h")

    if state == "yang" then
      return table.find(handcards, function(id)
        return Fk:getCardById(id).color == Card.Red
      end) and player:canUse(Fk:cloneCard("snatch"))
    else
      return table.find(handcards, function(id)
        return Fk:getCardById(id).color == Card.Black
      end) and player:canUse(Fk:cloneCard("duel"))
    end
  end,
})

-- 使用后切换状态
jiexuan:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.skillName == jiexuan.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local state = player:getMark("@@jiexuan-state")

    if state == "yang" then
      room:setPlayerMark(player, "@@jiexuan-state", "yin")
    else
      room:setPlayerMark(player, "@@jiexuan-state", "yang")
    end
  end,
})

return jiexuan
