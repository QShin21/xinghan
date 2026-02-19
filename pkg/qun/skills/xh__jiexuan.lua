-- SPDX-License-Identifier: GPL-3.0-or-later
-- 王允 - 解悬技能
-- 转换技，出牌阶段限一次，阳：你可以将一张红色牌当【顺手牵羊】使用；
-- 阴：你可以将一张黑色牌当【过河拆桥】使用。

local jiexuan = fk.CreateSkill {
  name = "xh__jiexuan",
}

Fk:loadTranslationTable {
  ["xh__jiexuan"] = "解悬",
  [":xh__jiexuan"] = "转换技，出牌阶段限一次，阳：你可以将一张红色牌当【顺手牵羊】使用；"..
    "阴：你可以将一张黑色牌当【过河拆桥】使用。",

  ["#xh__jiexuan-use"] = "解悬：选择一张牌",

  ["$xh__jiexuan1"] = "解悬之计，化险为夷！",
  ["$xh__jiexuan2"] = "连环之计，解悬为安！",
}

jiexuan:addEffect("viewas", {
  mute = true,
  pattern = "dismantlement,snatch",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    
    local state = player:getMark("@@jiexuan_state") or 0
    if state == 0 then
      -- 阳：红色牌当顺手牵羊
      return Fk:getCardById(to_select).color == Card.Red
    else
      -- 阴：黑色牌当过河拆桥
      return Fk:getCardById(to_select).color == Card.Black
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    
    local state = player:getMark("@@jiexuan_state") or 0
    local card_name = state == 0 and "snatch" or "dismantlement"
    
    local card = Fk:cloneCard(card_name)
    card.skillName = jiexuan.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(jiexuan.name, Player.HistoryPhase) == 0
  end,
})

-- 使用后切换状态
jiexuan:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card and data.card.skillName == jiexuan.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local state = player:getMark("@@jiexuan_state") or 0
    room:setPlayerMark(player, "@@jiexuan_state", state == 0 and 1 or 0)
  end,
})

return jiexuan
