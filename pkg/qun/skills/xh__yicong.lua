-- SPDX-License-Identifier: GPL-3.0-or-later
-- 公孙瓒 - 义从技能
-- 锁定技，你计算与其他角色的距离-1；若你的体力值不大于2，其他角色计算与你的距离+1。

local yicong = fk.CreateSkill {
  name = "xh__yicong",
}

Fk:loadTranslationTable {
  ["xh__yicong"] = "义从",
  [":xh__yicong"] = "锁定技，你计算与其他角色的距离-1；若你的体力值不大于2，其他角色计算与你的距离+1。",

  ["$xh__yicong1"] = "义从白马，天下无双！",
  ["$xh__yicong2"] = "白马义从，所向披靡！",
}

-- 距离-1
yicong:addEffect("distance", {
  correct_func = function(self, from, to)
    if from:hasSkill(yicong.name) then
      return -1
    end
    return 0
  end,
})

-- 其他角色计算与你的距离+1（体力值不大于2时）
yicong:addEffect("distance", {
  correct_func = function(self, from, to)
    if to:hasSkill(yicong.name) and to.hp <= 2 then
      return 1
    end
    return 0
  end,
})

return yicong
