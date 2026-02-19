-- SPDX-License-Identifier: GPL-3.0-or-later
-- 士燮 - 避乱技能
-- 锁定技，对手计算与你的距离+X（X为你装备区里的牌数）。

local biluan = fk.CreateSkill {
  name = "biluan",
}

Fk:loadTranslationTable {
  ["biluan"] = "避乱",
  [":biluan"] = "锁定技，对手计算与你的距离+X（X为你装备区里的牌数）。",

  ["$biluan1"] = "避乱交州，远离纷争！",
  ["$biluan2"] = "士燮避乱，保境安民！",
}

biluan:addEffect("distance", {
  correct_func = function(self, from, to)
    if to:hasSkill(biluan.name) and from ~= to then
      return #to:getCardIds("e")
    end
    return 0
  end,
})

return biluan
