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

  ["$xh__hunzi1"] = "魂姿觉醒，天下无双！",
  ["$xh__hunzi2"] = "江东小霸王，魂姿觉醒！",
}

hunzi:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(xh__hunzi.name) then return false end
    if player.phase ~= Player.Start then return false end
    if player:usedSkillTimes(xh__hunzi.name, Player.HistoryGame) > 0 then return false end
    
    return player.hp <= 2
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    room:changeMaxHp(player, -1)
    
    room:handleAddLoseSkills(player, "yingzi|yinghun")
  end,
})

return hunzi
