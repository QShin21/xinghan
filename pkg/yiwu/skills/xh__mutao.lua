local mutao = fk.CreateSkill {
  name = "xh__mutao",
}

Fk:loadTranslationTable{
  ["xh__mutao"] = "募讨",
  [":xh__mutao"] = "出牌阶段限一次，你可以展示所有手牌并将其中所有的【杀】交给一名其他角色，然后对其造成1点伤害。",

  ["#xh__mutao"] = "募讨：展示所有手牌，将其中所有【杀】交给一名其他角色，然后对其造成1点伤害",

  ["$xh__mutao1"] = "募兵讨贼，刻不容缓！",
  ["$xh__mutao2"] = "聚众讨逆，就在今日！",
}

mutao:addEffect("active", {
  anim_type = "offensive",
  prompt = "#xh__mutao",
  card_num = 0,
  target_num = 1,
  max_phase_use_time = 1,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  can_use = function(self, player)
    return player.phase == Player.Play and
      player:usedSkillTimes(mutao.name, Player.HistoryPhase) == 0 and
      not player:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if player.dead or not target or target.dead then return end

    local hand = player:getCardIds("h")
    if #hand > 0 then
      player:showCards(hand)
    end

    local slash_ids = {}
    for _, id in ipairs(hand) do
      local c = Fk:getCardById(id)
      if c and c.trueName == "slash" then
        table.insert(slash_ids, id)
      end
    end

    if #slash_ids > 0 and not player.dead and not target.dead then
      room:moveCardTo(slash_ids, Card.PlayerHand, target, fk.ReasonGive, mutao.name, nil, false, player)
    end

    if player.dead or target.dead then return end
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = mutao.name,
    }
  end,
})

return mutao