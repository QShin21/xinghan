-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘备(群) - 积善技能
-- 每回合限一次，当一名角色受到伤害时，你可以防止此伤害并失去2点体力，然后其摸一张牌，你摸一张牌。

local jishan = fk.CreateSkill {
  name = "xh__jishan",
}

Fk:loadTranslationTable {
  ["xh__jishan"] = "积善",
  [":xh__jishan"] = "每回合限一次，当一名角色受到伤害时，你可以防止此伤害并失去2点体力，然后其摸一张牌，你摸一张牌。",

  ["#xh__jishan-invoke"] = "积善：是否防止伤害并失去2点体力？",

  ["$xh__jishan1"] = "积善之家，必有余庆！",
  ["$xh__jishan2"] = "仁德布施，积善成德！",
}

jishan:addEffect(fk.DamageInflicted, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(jishan.name) then return false end
    if player:usedSkillTimes(jishan.name, Player.HistoryTurn) > 0 then return false end
    if player.hp < 2 then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jishan.name,
      prompt = "#xh__jishan-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 防止伤害
    data:preventDamage()
    
    -- 失去2点体力
    room:loseHp(player, 2, jishan.name)
    
    -- 摸牌
    target:drawCards(1, jishan.name)
    player:drawCards(1, jishan.name)
  end,
})

return jishan
