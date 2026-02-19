-- SPDX-License-Identifier: GPL-3.0-or-later
-- 王允 - 中流技能
-- 锁定技，当你使用牌时，若不为你的手牌，此阶段你可以多发动一次技能"解悬"。

local zhongliu = fk.CreateSkill {
  name = "xh__zhongliu",
}

Fk:loadTranslationTable {
  ["xh__zhongliu"] = "中流",
  [":xh__zhongliu"] = "锁定技，当你使用牌时，若不为你的手牌，此阶段你可以多发动一次技能\"解悬\"。",

  ["@@xh__zhongliu_extra"] = "中流",

  ["$xh__zhongliu1"] = "中流砥柱，力挽狂澜！",
  ["$xh__zhongliu2"] = "中流击水，浪遏飞舟！",
}

zhongliu:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhongliu.name) and
      data.card and not table.contains(player:getCardIds("h"), data.card.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@@zhongliu_extra", 1)
  end,
})

-- 增加解悬使用次数
zhongliu:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if skill.name == "jiexuan" and player:getMark("@@zhongliu_extra") > 0 then
      return player:getMark("@@zhongliu_extra")
    end
    return 0
  end,
})

-- 回合结束清除标记
zhongliu:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@zhongliu_extra") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@zhongliu_extra", 0)
  end,
})

return zhongliu
