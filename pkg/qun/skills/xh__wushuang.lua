-- SPDX-License-Identifier: GPL-3.0-or-later
-- 吕布 - 无双技能
-- 锁定技，你使用的【杀】需两张【闪】才能抵消；
-- 与你进行【决斗】的角色每次需打出两张【杀】。

local wushuang = fk.CreateSkill {
  name = "xh__wushuang",
}

Fk:loadTranslationTable {
  ["xh__wushuang"] = "无双",
  [":xh__wushuang"] = "锁定技，你使用的【杀】需两张【闪】才能抵消；与你进行【决斗】的角色每次需打出两张【杀】。",

  ["$xh__wushuang1"] = "谁能挡我！",
  ["$xh__wushuang2"] = "神戟在手，天下我有！",
}

-- 杀需要两张闪
wushuang:addEffect(fk.TargetConfirming, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(xh__wushuang.name) then return false end

    local card = data.card
    if not card then return false end

    return card.trueName == "slash"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.wushuang_jink = 2
  end,
})

-- 决斗需要两张杀
wushuang:addEffect(fk.CardEffectCancelledOut, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(xh__wushuang.name) then return false end

    local card = data.card
    if not card then return false end

    return card.trueName == "duel"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.wushuang_slash = 2
  end,
})

return wushuang
