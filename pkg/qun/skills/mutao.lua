-- SPDX-License-Identifier: GPL-3.0-or-later
-- 鲍信 - 募讨技能
-- 出牌阶段限一次，你可以展示所有手牌并将其中所有的【杀】交给一名其他角色，然后对其造成1点伤害。

local mutao = fk.CreateSkill {
  name = "mutao",
}

Fk:loadTranslationTable {
  ["mutao"] = "募讨",
  [":mutao"] = "出牌阶段限一次，你可以展示所有手牌并将其中所有的【杀】交给一名其他角色，然后对其造成1点伤害。",

  ["#mutao-choose"] = "募讨：展示所有手牌，将其中所有的【杀】交给一名角色，然后对其造成1点伤害",

  ["$mutao1"] = "募兵讨贼，匡扶汉室！",
  ["$mutao2"] = "讨伐逆贼，义不容辞！",
}

mutao:addEffect("active", {
  mute = true,
  prompt = "#mutao-choose",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(mutao.name, Player.HistoryPhase) == 0 and
      not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, mutao.name, "offensive", {target})
    player:broadcastSkillInvoke(mutao.name)

    -- 展示所有手牌
    local handcards = player:getCardIds("h")
    room:showCards(player, handcards, mutao.name)

    -- 筛选所有的杀
    local slashes = table.filter(handcards, function(id)
      return Fk:getCardById(id).trueName == "slash"
    end)

    -- 将杀交给目标
    if #slashes > 0 then
      room:moveCardTo(slashes, Player.Hand, target, fk.ReasonGive, mutao.name, nil, false, player.id)
    end

    -- 对其造成1点伤害
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = mutao.name,
    }
  end,
})

return mutao
