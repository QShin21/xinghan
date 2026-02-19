-- SPDX-License-Identifier: GPL-3.0-or-later
-- 徐庶 - 潜心技能
-- 觉醒技，当你造成伤害后，若你已受伤，你减1点体力上限，并获得"荐言"。

local qianxin = fk.CreateSkill {
  name = "qianxin",
  frequency = Skill.Wake,
}

Fk:loadTranslationTable {
  ["qianxin"] = "潜心",
  [":qianxin"] = "觉醒技，当你造成伤害后，若你已受伤，你减1点体力上限，并获得\"荐言\"。",

  ["#qianxin-wake"] = "潜心：已受伤，觉醒获得【荐言】",

  ["$qianxin1"] = "潜心修行，终有所悟！",
  ["$qianxin2"] = "身在曹营心在汉！",
}

qianxin:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qianxin.name) and
      player:isWounded()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room

    room:notifySkillInvoked(player, qianxin.name, "support")

    -- 减少1点体力上限
    room:changeMaxHp(player, -1)

    -- 获得荐言
    room:handleAddLoseSkills(player, "jianyan", nil, false, true)
  end,
})

return qianxin
