-- SPDX-License-Identifier: GPL-3.0-or-later
-- 李傕 - 狼袭技能
-- 准备阶段，你可以选择一名体力值不大于你的角色，然后你进行判定，
-- 若结果为黑色，你对其造成1点伤害。

local langxi = fk.CreateSkill {
  name = "langxi",
}

Fk:loadTranslationTable {
  ["langxi"] = "狼袭",
  [":langxi"] = "准备阶段，你可以选择一名体力值不大于你的角色，然后你进行判定，若结果为黑色，你对其造成1点伤害。",

  ["#langxi-target"] = "狼袭：选择一名体力值不大于你的角色",

  ["$langxi1"] = "狼袭之威，势不可挡！",
  ["$langxi2"] = "西凉狼骑，天下无双！",
}

langxi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(langxi.name) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p.hp <= player.hp
    end)
    
    if #targets == 0 then return false end
    
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = langxi.name,
      prompt = "#langxi-target",
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
    
    local judge = room:judge{
      who = player,
      reason = langxi.name,
    }
    
    if judge.card.color == Card.Black then
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = langxi.name,
      }
    end
  end,
})

return langxi
