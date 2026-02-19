-- SPDX-License-Identifier: GPL-3.0-or-later
-- 李儒 - 绝策技能
-- 结束阶段，你可以对一名没有手牌的其他角色造成1点伤害。

local juece = fk.CreateSkill {
  name = "xh__juece",
}

Fk:loadTranslationTable {
  ["xh__juece"] = "绝策",
  [":xh__juece"] = "结束阶段，你可以对一名没有手牌的其他角色造成1点伤害。",

  ["#xh__juece-choose"] = "绝策：选择一名没有手牌的角色造成1点伤害",

  ["$xh__juece1"] = "绝策断粮，必取敌命！",
  ["$xh__juece2"] = "无粮之军，必败无疑！",
}

juece:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(juece.name) and
      player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return p:isKongcheng()
    end)

    if #targets == 0 then return false end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = juece.name,
      prompt = "#xh__juece-choose",
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

    room:damage{
      from = player,
      to = to,
      damage = 1,
      skillName = juece.name,
    }
  end,
})

return juece
