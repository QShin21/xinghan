-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张角 - 雷击技能
-- 当你使用或打出【闪】时，你可以令一名其他角色判定，若结果为：
-- ♤，你对其造成2点雷电伤害；♧，你回复1点体力，然后对其造成1点雷电伤害。

local leiji = fk.CreateSkill {
  name = "xh__leiji",
}

Fk:loadTranslationTable {
  ["xh__leiji"] = "雷击",
  [":xh__leiji"] = "当你使用或打出【闪】时，你可以令一名其他角色判定，若结果为："..
    "♤，你对其造成2点雷电伤害；♧，你回复1点体力，然后对其造成1点雷电伤害。",

  ["#xh__leiji-target"] = "雷击：选择一名角色进行判定",

  ["$xh__leiji1"] = "雷击！天罚降临！",
  ["$xh__leiji2"] = "苍天已死，黄天当立！",
}

leiji:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__leiji.name) and
      data.card and data.card.trueName == "jink"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player, false)
    
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = xh__leiji.name,
      prompt = "#leiji-target",
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
      who = to,
      reason = xh__leiji.name,
    }
    
    local suit = judge.card.suit
    
    if suit == Card.Spade then
      room:damage{
        from = player,
        to = to,
        damage = 2,
        damageType = fk.ThunderDamage,
        skillName = xh__leiji.name,
      }
    elseif suit == Card.Club then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = xh__leiji.name,
      }
      room:damage{
        from = player,
        to = to,
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = xh__leiji.name,
      }
    end
  end,
})

leiji:addEffect(fk.CardResponding, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__leiji.name) and
      data.card and data.card.trueName == "jink"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player, false)
    
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = xh__leiji.name,
      prompt = "#leiji-target",
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
      who = to,
      reason = xh__leiji.name,
    }
    
    local suit = judge.card.suit
    
    if suit == Card.Spade then
      room:damage{
        from = player,
        to = to,
        damage = 2,
        damageType = fk.ThunderDamage,
        skillName = xh__leiji.name,
      }
    elseif suit == Card.Club then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = xh__leiji.name,
      }
      room:damage{
        from = player,
        to = to,
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = xh__leiji.name,
      }
    end
  end,
})

return leiji
