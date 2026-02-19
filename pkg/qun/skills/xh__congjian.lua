-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张绣 - 从谏技能
-- 锁定技，你于回合外造成的伤害+1；你于回合内受到的伤害+1。

local congjian = fk.CreateSkill {
  name = "xh__congjian",
}

Fk:loadTranslationTable {
  ["xh__congjian"] = "从谏",
  [":xh__congjian"] = "锁定技，你于回合外造成的伤害+1；你于回合内受到的伤害+1。",

  ["$xh__congjian1"] = "从谏如流，善纳忠言！",
  ["$xh__congjian2"] = "宛城张绣，从谏如流！",
}

-- 回合外伤害+1
congjian:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(congjian.name) then return false end
    if player.phase ~= Player.NotActive then return false end
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

-- 回合内受到伤害+1
congjian:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(congjian.name) then return false end
    if player.phase == Player.NotActive then return false end
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

return congjian
