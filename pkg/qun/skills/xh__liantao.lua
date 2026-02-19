-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孙策(群) - 连讨技能
-- 出牌阶段开始时，你可以选择一名其他角色，然后其选择一项：
-- 1.交给你一张牌，然后你本回合对其使用【杀】无次数限制；
-- 2.令你本回合对其使用【杀】无距离和次数限制。

local liantao = fk.CreateSkill {
  name = "xh__liantao",
}

Fk:loadTranslationTable {
  ["xh__liantao"] = "连讨",
  [":xh__liantao"] = "出牌阶段开始时，你可以选择一名其他角色，然后其选择一项："..
    "1.交给你一张牌，然后你本回合对其使用【杀】无次数限制；"..
    "2.令你本回合对其使用【杀】无距离和次数限制。",

  ["#xh__liantao-choose"] = "连讨：选择一名其他角色",
  ["liantao_choice1"] = "交给对方一张牌，对方本回合对你使用杀无次数限制",
  ["liantao_choice2"] = "令对方本回合对你使用杀无距离和次数限制",
  ["@@xh__liantao_no_slash"] = "连讨禁止杀",
  ["@@xh__liantao_target"] = "连讨目标",

  ["$xh__liantao1"] = "连讨之威，势不可挡！",
  ["$xh__liantao2"] = "孙策连讨，天下无双！",
}

liantao:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(liantao.name) and
      player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player)
    
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = liantao.name,
      prompt = "#xh__liantao-choose",
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
    
    local choice = room:askToChoice(to, {
      choices = {"liantao_choice1", "liantao_choice2"},
      skill_name = liantao.name,
      prompt = "选择一项",
      detailed = false,
    })
    
    if choice == "liantao_choice1" then
      -- 交给你一张牌
      if not to:isNude() then
        local id = room:askToCards(to, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = liantao.name,
          pattern = ".",
          prompt = "选择一张牌交给" .. player.name,
          cancelable = false,
        })
        room:moveCardTo(id, Player.Hand, player, fk.ReasonGive, liantao.name, nil, false, to.id)
      end
    end
    
    room:setPlayerMark(player, "@@liantao_target", to.id)
  end,
})

-- 无距离限制
liantao:addEffect("targetmod", {
  distance_limit_func = function(self, player, skill, card, to)
    local target_id = player:getMark("@@liantao_target")
    if target_id and target_id ~= 0 and skill.trueName == "slash_skill" then
      return true
    end
    return false
  end,
  residue_func = function(self, player, skill, scope, card)
    local target_id = player:getMark("@@liantao_target")
    if target_id and target_id ~= 0 and skill.trueName == "slash_skill" then
      return 999
    end
    return 0
  end,
})

-- 回合结束清除标记
liantao:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@liantao_target") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@liantao_target", 0)
  end,
})

return liantao
