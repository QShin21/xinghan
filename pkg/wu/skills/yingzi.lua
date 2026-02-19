-- SPDX-License-Identifier: GPL-3.0-or-later
-- 周瑜 - 英姿技能
-- 锁定技，摸牌阶段，你多摸一张牌；你的手牌上限等于X（X为你的体力上限）。

local yingzi = fk.CreateSkill {
  name = "yingzi",
}

Fk:loadTranslationTable {
  ["yingzi"] = "英姿",
  [":yingzi"] = "锁定技，摸牌阶段，你多摸一张牌；你的手牌上限等于X（X为你的体力上限）。",

  ["$yingzi1"] = "英姿勃发，天下无双！",
  ["$yingzi2"] = "周瑜英姿，江东美周郎！",
}

-- 多摸一张牌
yingzi:addEffect(fk.DrawNCards, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yingzi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.num = data.num + 1
  end,
})

-- 手牌上限等于体力上限
yingzi:addEffect(fk.MaxCards, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yingzi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.value = player.maxHp
  end,
})

return yingzi
