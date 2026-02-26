Fk:loadTranslationTable {
  ["xh__jizhi"] = "集智",
  [":xh__jizhi"] = "当你使用普通锦囊牌时，你可以摸一张牌。若此牌为基本牌且此时是你的回合内，则你可以弃置之，然后令本回合手牌上限+1。",

  ["@xh__jizhi-turn"] = "集智",
  ["#xh__jizhi-invoke"] = "集智：是否弃置%arg，令你本回合的手牌上限+1？",

  ["$xh__jizhi1"] = "得上通，智集心。",
  ["$xh__jizhi2"] = "集万千才智，致巧趣鲜用。",
}

local jizhi = fk.CreateSkill {
  name = "xh__jizhi",
}

jizhi:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(jizhi.name) then return false end
    if data.card.type ~= Card.TypeTrick then return false end
    if data.card:isConverted() then return false end

    -- 仅普通锦囊触发，过滤延时锦囊（乐不思蜀、兵粮寸断、闪电等）
    local is_delayed = false
    if Card.SubtypeDelayedTrick and data.card.sub_type then
      is_delayed = (data.card.sub_type == Card.SubtypeDelayedTrick)
    elseif data.card.isDelayedTrick then
      is_delayed = data.card:isDelayedTrick()
    elseif data.card.isKindOf then
      is_delayed = data.card:isKindOf("DelayedTrick")
    end

    return not is_delayed
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:drawCards(1)
    if #cards == 0 then return false end
    local card = Fk:getCardById(cards[1])
    if card.type == Card.TypeBasic and not player.dead and room.current == player and
        table.contains(player:getCardIds("h"), card.id) and not player:prohibitDiscard(card) and
        room:askToSkillInvoke(player, {
          skill_name = jizhi.name,
          prompt = "#xh__jizhi-invoke:::" .. card:toLogString(),
        }) then
      room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, 1)
      room:throwCard(card, jizhi.name, player, player)
    end
  end,
})

jizhi:addTest(function(room, me)
  local comp2 = room.players[2]
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, "xh__jizhi")
  end)

  local ex_nihilo = room:printCard("xh_nihilo")

  -- test1 一般的集智判定
  FkTest.setNextReplies(me, {
    json.encode { card = ex_nihilo.id },
    "1",
    "__cancel"
  })
  FkTest.runInRoom(function()
    room:moveCardTo({ 2, 3, 4, 5 }, Card.DrawPile) -- 都是杀……吧？
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
    -- room:useCard{
    --   from = me,
    --   tos = { comp2 },
    --   card = god_salvation,
    -- }
  end)
  lu.assertEquals(#me:getCardIds("h"), 3)

  FkTest.setNextReplies(me, {
    json.encode { card = ex_nihilo.id },
    "1",
    "1"
  })

  -- test2 弃置一张基本牌并令手牌上限+1
  FkTest.setRoomBreakpoint(me, "PlayCard", FkTest.CreateClosure(2))
  FkTest.runInRoom(function()
    me:throwAllCards("h")
    room:moveCardTo({ 2, 3, 4, 5 }, Card.DrawPile) -- 都是杀……吧？
    GameEvent.Phase:create(PhaseData:new { who = me, reason = "game_rule", phase = Player.Play }):exec()
    -- room:useCard{
    --   from = me,
    --   tos = { comp2 },
    --   card = god_salvation,
    -- }
  end)
  lu.assertEquals(#me:getCardIds("h"), 2)
  lu.assertEquals(me:getMaxCards(), me.hp + 1)
end)

return jizhi
