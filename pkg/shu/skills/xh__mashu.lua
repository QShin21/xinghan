-- SPDX-License-Identifier: GPL-3.0-or-later
-- 马超 - 马术技能
-- 锁定技，你计算与其他角色的距离-1。

local mashu = fk.CreateSkill {
  name = "xh__mashu",
}

Fk:loadTranslationTable {
  ["xh__mashu"] = "马术",
  [":xh__mashu"] = "锁定技，你计算与其他角色的距离-1。",

  ["$xh__mashu1"] = "马术精湛，来去如风！",
  ["$xh__mashu2"] = "西凉铁骑，马术无双！",
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
