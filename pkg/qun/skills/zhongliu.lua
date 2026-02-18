-- SPDX-License-Identifier: GPL-3.0-or-later
-- 王允 - 中流技能
-- 锁定技，当你使用牌时，若不为你的手牌，此阶段你可以多发动一次技能"解悬"。

local zhongliu = fk.CreateSkill {
  name = "zhongliu",
}

Fk:loadTranslationTable {
  ["zhongliu"] = "中流",
  [":zhongliu"] = "锁定技，当你使用牌时，若不为你的手牌，此阶段你可以多发动一次技能\"解悬\"。",

  ["@@zhongliu_extra"] = "中流",

  ["$zhongliu1"] = "中流砥柱，力挽狂澜！",
  ["$zhongliu2"] = "逆流而上，不惧艰险！",
}

zhongliu:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhongliu.name) and
      data.card and not data.card:isVirtual()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.card

    -- 检查是否为手牌
    local handcards = player:getCardIds("h")
    if not table.contains(handcards, card.id) then
      -- 不是手牌，增加解悬使用次数
      room:addPlayerMark(player, "@@zhongliu_extra", 1)
    end
  end,
})

-- 修改解悬使用次数
zhongliu:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if skill.name == "jiexuan" then
      return player:getMark("@@zhongliu_extra")
    end
  end,
})

-- 回合结束清除标记
zhongliu:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@zhongliu_extra") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@zhongliu_extra", 0)
  end,
})

return zhongliu
