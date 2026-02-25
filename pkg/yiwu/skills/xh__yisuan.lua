local yisuan = fk.CreateSkill{
  name = "xh_yisuan",
}

Fk:loadTranslationTable{
  ["xh_yisuan"] = "亦算",
  [":xh_yisuan"] = "出牌阶段限一次，当你使用的普通锦囊牌结算结束后，你可以失去1点体力或减1点体力上限，然后获得此牌。",

  ["#xh_yisuan-invoke"] = "亦算：是否付出代价获得%arg？",
  ["#xh_yisuan-choice"] = "亦算：选择代价",

  ["$xh_yisuan1"] = "吾亦能善算谋划。",
  ["$xh_yisuan2"] = "算计人心，我也可略施一二。",
}

yisuan:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(yisuan.name) then return false end
    if player.phase ~= Player.Play then return false end
    if player.room.current ~= player then return false end
    if player:usedSkillTimes(yisuan.name, Player.HistoryPhase) > 0 then return false end
    if not data.card or not data.card:isCommonTrick() then return false end
    if data.card:isConverted() then return false end
    if not data.card.id or data.card.id < 0 then return false end
    return true
  end,

  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = yisuan.name,
      prompt = "#xh_yisuan-invoke:::" .. data.card:toLogString(),
    }) then
      local choice = room:askToChoice(player, {
        choices = { "loseHp", "loseMaxHp" },
        skill_name = yisuan.name,
        prompt = "#xh_yisuan-choice",
      })
      event:setCostData(self, { choice = choice, card_id = data.card.id })
      return true
    end
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost = event:getCostData(self) or {}
    local choice = cost.choice
    local cid = cost.card_id
    if not cid then return end

    if choice == "loseMaxHp" then
      room:changeMaxHp(player, -1)
    else
      room:loseHp(player, 1, yisuan.name)
    end
    if player.dead then return end

    room:obtainCard(player, cid, true, fk.ReasonJustMove, player, yisuan.name)
  end,
})

return yisuan