-- SPDX-License-Identifier: GPL-3.0-or-later
-- 周瑜 - 英姿技能
-- 锁定技，摸牌阶段，你多摸一张牌。

local yingzi = fk.CreateSkill {
  name = "xh__yingzi",
}

Fk:loadTranslationTable {
  ["xh__yingzi"] = "英姿",
  [":xh__yingzi"] = "锁定技，摸牌阶段，你多摸一张牌。",

  ["$xh__yingzi1"] = "英姿勃发，天下无双！",
  ["$xh__yingzi2"] = "周瑜英姿，江东美周郎！",
}

-- 多摸一张牌
yingzi:addEffect(fk.DrawNCards, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__yingzi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.num = data.num + 1
  end,
})

return yingzi
