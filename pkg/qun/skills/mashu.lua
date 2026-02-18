-- SPDX-License-Identifier: GPL-3.0-or-later
-- 马腾 - 马术技能
-- 锁定技，你计算与其他角色的距离-1。

local mashu = fk.CreateSkill {
  name = "mashu",
}

Fk:loadTranslationTable {
  ["mashu"] = "马术",
  [":mashu"] = "锁定技，你计算与其他角色的距离-1。",

  ["$mashu1"] = "马术精湛，来去如风！",
  ["$mashu2"] = "西凉铁骑，天下无双！",
}

mashu:addEffect("distance", {
  correct_func = function(self, from, to)
    if from:hasSkill(mashu.name) then
      return -1
    end
    return 0
  end,
})

return mashu
