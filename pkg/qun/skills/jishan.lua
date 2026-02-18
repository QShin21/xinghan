-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘备 - 积善技能
-- 每回合限一次，当一名角色受到伤害时，你可以防止此伤害并失去2点体力，
-- 然后其摸一张牌，你摸一张牌。

local jishan = fk.CreateSkill {
  name = "jishan",
}

Fk:loadTranslationTable {
  ["jishan"] = "积善",
  [":jishan"] = "每回合限一次，当一名角色受到伤害时，你可以防止此伤害并失去2点体力，"..
    "然后其摸一张牌，你摸一张牌。",

  ["#jishan-invoke"] = "积善：防止 %dest 受到的伤害，你失去2点体力，双方各摸一张牌",

  ["$jishan1"] = "积善之家，必有余庆！",
  ["$jishan2"] = "行善积德，福泽绵长！",
}

jishan:addEffect(fk.DamageInflicted, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jishan.name) and
      player:usedEffectTimes(jishan.name, Player.HistoryTurn) == 0 and
      data.damage > 0 and player.hp >= 2
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jishan.name,
      prompt = "#jishan-invoke::" .. target.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 防止伤害
    data:preventDamage()

    -- 失去2点体力
    room:loseHp(player, 2, jishan.name)

    -- 其摸一张牌
    if not target.dead then
      target:drawCards(1, jishan.name)
    end

    -- 你摸一张牌
    if not player.dead then
      player:drawCards(1, jishan.name)
    end
  end,
})

return jishan
