local mingce = fk.CreateSkill{
  name = "xh__mingce",
}

Fk:loadTranslationTable{
  ["xh__mingce"] = "明策",
  [":xh__mingce"] = "出牌阶段限一次，你可以交给对手一张牌，令其选择一项：1.摸一张牌，并令你摸两张牌；2.失去1点体力。",
  
  ["#xh__mingce"] = "明策：交给一名角色一张牌，令其选择失去体力或摸牌",
  ["#xh__mingce-choose"] = "明策：选择令 %dest 失去体力或摸牌",
  ["xh__mingce_losehp"] = "你失去1点体力，令%src摸两张牌",
  
  ["$xh__mingce1"] = "行吾此计，可使将军化险为夷。",
  ["$xh__mingce2"] = "分兵驻扎，可互为掎角之势。",
}

mingce:addEffect("active", {
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#xh__mingce",
  can_use = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:obtainCard(target, effect.cards[1], false, fk.ReasonGive)

    if target.dead then return end
    
    local skillName = mingce.name
    -- 询问目标选择摸牌还是失去体力
    if room:askToChoice(target, { choices = {"xh__mingce_losehp:" .. player.id, "draw1"}, skill_name = skillName }) == "draw1" then
      target:drawCards(1, skillName)
      -- 你摸两张牌
      if not player.dead then
        player:drawCards(2, skillName)
      end
    else
      room:loseHp(target, 1, skillName)
    end
  end,
})

return mingce