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

  ["#langxi-choose"] = "狼袭：选择一名体力值不大于你的角色",
  ["#langxi-judge"] = "狼袭判定",

  ["$langxi1"] = "狼子野心，昭然若揭！",
  ["$langxi2"] = "袭敌不备，一击必中！",
}

langxi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(langxi.name) and
      player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return p.hp <= player.hp
    end)

    if #targets == 0 then return false end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = langxi.name,
      prompt = "#langxi-choose",
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

    -- 进行判定
    local judge = {
      who = player,
      reason = langxi.name,
      pattern = ".",
    }
    room:judge(judge)

    local card = Fk:getCardById(judge.card.id)

    -- 若结果为黑色，造成伤害
    if card.color == Card.Black then
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
