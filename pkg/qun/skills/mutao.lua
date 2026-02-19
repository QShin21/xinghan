-- SPDX-License-Identifier: GPL-3.0-or-later
-- 鲍信 - 募讨技能
-- 出牌阶段限一次，你可以展示所有手牌并将其中所有的【杀】交给一名其他角色，然后对其造成1点伤害。

local mutao = fk.CreateSkill {
  name = "xh__mutao",
}

Fk:loadTranslationTable {
  ["xh__mutao"] = "募讨",
  [":xh__mutao"] = "出牌阶段限一次，你可以展示所有手牌并将其中所有的【杀】交给一名其他角色，然后对其造成1点伤害。",

  ["#xh__mutao-target"] = "募讨：选择一名其他角色",

  ["$xh__mutao1"] = "募讨义兵，讨伐奸贼！",
  ["$xh__mutao2"] = "义兵既募，讨贼安民！",
}

mutao:addEffect("active", {
  mute = true,
  prompt = "#mutao-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xh__mutao.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, xh__mutao.name, "offensive", {target})
    player:broadcastSkillInvoke(xh__mutao.name)

    -- 展示所有手牌
    local handcards = player:getCardIds("h")
    room:showCards(player, handcards, xh__mutao.name)
    
    -- 找出所有杀
    local slash_cards = table.filter(handcards, function(id)
      return Fk:getCardById(id).trueName == "slash"
    end)
    
    -- 交给目标
    if #slash_cards > 0 then
      room:moveCardTo(slash_cards, Player.Hand, target, fk.ReasonGive, xh__mutao.name, nil, false, player.id)
    end
    
    -- 造成1点伤害
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = xh__mutao.name,
    }
  end,
})

return mutao
