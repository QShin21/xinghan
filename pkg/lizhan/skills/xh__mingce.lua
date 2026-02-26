local mingce = fk.CreateSkill{
  name = "xh__mingce",
}

Fk:loadTranslationTable{
  ["xh__mingce"] = "明策",
  [":xh__mingce"] = "出牌阶段限一次，你可以交给一名其他角色一张牌，令其选择一项：1.摸一张牌，然后你摸两张牌；2.失去1点体力。",

  ["#xh__mingce"] = "明策：交给一名其他角色一张牌，令其选择失去体力或摸牌",
  ["xh__mingce_losehp"] = "失去1点体力，令%src摸两张牌",
  ["@@xh__yinpan_count"] = "引叛计数",

  ["$xh__mingce1"] = "行吾此计，可使将军化险为夷。",
  ["$xh__mingce2"] = "分兵驻扎，可互为掎角之势。",
}

mingce:addEffect("active", {
  anim_type = "support",
  prompt = "#xh__mingce",
  card_num = 1,
  target_num = 1,

  can_use = function(self, player)
    return player.phase == Player.Play and player:usedSkillTimes(mingce.name, Player.HistoryPhase) == 0
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
    local cardId = effect.cards[1]
    if not player or player.dead or not target or target.dead or not cardId then return end

    room:obtainCard(target, cardId, false, fk.ReasonGive, player, mingce.name)
    if target.dead then return end

    local choice = room:askToChoice(target, {
      choices = { "draw1", "xh__mingce_losehp:" .. player.id },
      skill_name = mingce.name,
    })

    if choice == "draw1" then
      target:drawCards(1, mingce.name)
      room:addTableMark(target, "@@xh__yinpan_count", 1)
      if not player.dead then
        player:drawCards(2, mingce.name)
      end
    else
      room:loseHp(target, 1, mingce.name)
    end
  end,
})

return mingce
