-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孙策 - 魂姿技能
-- 觉醒技，准备阶段，若你当前体力值小于等于2，则你减1点体力上限，然后获得技能"英姿"和"英魂"。

local hunzi = fk.CreateSkill {
  name = "xh__hunzi",
  frequency = Skill.Wake,
}

Fk:loadTranslationTable {
  ["xh__hunzi"] = "魂姿",
  [":xh__hunzi"] = "觉醒技，准备阶段，若你当前体力值小于等于2，则你减1点体力上限，然后获得技能\"英姿\"和\"英魂\"。",

  ["#xh__hunzi-wake"] = "魂姿：体力值小于等于2，觉醒获得【英姿】和【英魂】",

  ["$xh__hunzi1"] = "魂姿觉醒，霸业将成！",
  ["$xh__hunzi2"] = "江东基业，始于此！",
}

hunzi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hunzi.name) and
      player.phase == Player.Start and
      player.hp <= 2
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room

    room:notifySkillInvoked(player, hunzi.name, "support")

    -- 减少1点体力上限
    room:changeMaxHp(player, -1)

    -- 获得英姿和英魂
    room:handleAddLoseSkills(player, "yingzi|yinghun", nil, false, true)
  end,
})

return hunzi
