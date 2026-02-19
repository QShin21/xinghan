-- SPDX-License-Identifier: GPL-3.0-or-later
-- 华歆 - 望归技能
-- 当你造成伤害后，你可以对与你势力不同的一名角色造成1点伤害（每回合限一次）；
-- 当你受到伤害后，你可以令你势力相同的一名角色摸一张牌，若该角色不是你，你也摸一张牌。

local wanggui = fk.CreateSkill {
  name = "xh__wanggui",
}

Fk:loadTranslationTable {
  ["xh__wanggui"] = "望归",
  [":xh__wanggui"] = "当你造成伤害后，你可以对与你势力不同的一名角色造成1点伤害（每回合限一次）；"..
    "当你受到伤害后，你可以令你势力相同的一名角色摸一张牌，若该角色不是你，你也摸一张牌。",

  ["#xh__wanggui-damage"] = "望归：对一名不同势力角色造成1点伤害",
  ["#xh__wanggui-draw"] = "望归：令一名同势力角色摸一张牌",

  ["$xh__wanggui1"] = "望归故里，心系苍生！",
  ["$xh__wanggui2"] = "归心似箭，何惧路遥！",
}

-- 造成伤害后
wanggui:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__wanggui.name) and
      player:usedEffectTimes(xh__wanggui.name .. "_damage", Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return p.kingdom ~= player.kingdom
    end)

    if #targets == 0 then return false end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = xh__wanggui.name,
      prompt = "#wanggui-damage",
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
      skillName = xh__wanggui.name,
    }
  end,
})

-- 受到伤害后
wanggui:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__wanggui.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local targets = table.filter(room.alive_players, function(p)
      return p.kingdom == player.kingdom
    end)

    if #targets == 0 then return false end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = xh__wanggui.name,
      prompt = "#wanggui-draw",
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

    to:drawCards(1, xh__wanggui.name)

    -- 若该角色不是你，你也摸一张牌
    if to ~= player and not player.dead then
      player:drawCards(1, xh__wanggui.name)
    end
  end,
})

return wanggui
