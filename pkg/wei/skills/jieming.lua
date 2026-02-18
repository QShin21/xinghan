-- SPDX-License-Identifier: GPL-3.0-or-later
-- 荀彧 - 节命技能
-- 当你受到1点伤害后，你可以令一名角色摸两张牌，然后若其手牌数小于其体力上限，你摸一张牌。

local jieming = fk.CreateSkill {
  name = "jieming",
}

Fk:loadTranslationTable {
  ["jieming"] = "节命",
  [":jieming"] = "当你受到1点伤害后，你可以令一名角色摸两张牌，然后若其手牌数小于其体力上限，你摸一张牌。",

  ["#jieming-choose"] = "节命：选择一名角色令其摸两张牌",

  ["$jieming1"] = "秉忠贞之志，守谦退之节。",
  ["$jieming2"] = "我命由天，不在此列！",
}

jieming:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jieming.name) and data.damage > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = room.alive_players

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = jieming.name,
      prompt = "#jieming-choose",
      cancelable = true,
    })

    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]

    -- 目标摸两张牌
    to:drawCards(2, jieming.name)

    -- 若其手牌数小于其体力上限，你摸一张牌
    if not player.dead and not to.dead then
      if to:getHandcardNum() < to.maxHp then
        player:drawCards(1, jieming.name)
      end
    end
  end,
})

return jieming
