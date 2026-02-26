local tianming = fk.CreateSkill {
  name = "xh__tianming",
}

Fk:loadTranslationTable{
  ["xh__tianming"] = "天命",
  [":xh__tianming"] = "当你成为【杀】的目标后，你可以弃置两张牌（不足则全弃），然后摸两张牌。",
  
  ["#xh__tianming-invoke"] = "天命：你可以弃置两张牌（不足则全弃），然后摸两张牌",
}

tianming:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tianming.name) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = tianming.name,
      prompt = "#xh__tianming-invoke"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 弃置最多两张牌（不足两张则全弃）
    local cards_to_discard = player:getCards("he")
    local num_to_discard = math.min(2, #cards_to_discard)
    local discarded_cards = room:askToDiscard(player, {
      min_num = num_to_discard,
      max_num = num_to_discard,
      cards = cards_to_discard,
      skill_name = tianming.name,
      prompt = "#xh__tianming-invoke",
      cancelable = false,
    })
    -- 摸两张牌
    if not player.dead then
      player:drawCards(2, tianming.name)
    end

    -- 让体力唯一最大的其他角色执行相同的动作
    local max_hp_players = table.filter(room.alive_players, function(p)
      return p.hp == math.max(table.map(room.alive_players, function(p) return p.hp end))
    end)
    if #max_hp_players == 1 and max_hp_players[1] ~= player then
      local to = max_hp_players[1]
      if room:askToSkillInvoke(to, {
        skill_name = tianming.name,
        prompt = "#xh__tianming-invoke"
      }) then
        -- 弃置所有手牌
        to:throwAllCards("he", tianming.name)
        -- 摸两张牌
        if not to.dead then
          to:drawCards(2, tianming.name)
        end
      end
    end
  end,
})

return tianming