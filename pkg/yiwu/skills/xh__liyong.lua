local liyong = fk.CreateSkill{ 
  name = "xh__liyong",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["xh__liyong"] = "历勇",
  [":xh__liyong"] = "转换技，出牌阶段每项限一次，阳：你可以将一张本回合你未使用过的花色的牌当【决斗】使用；阴：你可以从弃牌堆中获得一张你本回合使用过的花色的牌，令一名角色视为对你使用一张【决斗】。",
  
  ["#xh__liyong-yang"] = "历勇：将一张本回合未使用花色的牌当【决斗】使用",
  ["#xh__liyong-yin"] = "历勇：获得牌堆中一张本回合已使用花色的牌，选择一名角色视为对你使用【决斗】",
  ["@xh__liyong-turn"] = "历勇",
  
  ["$xh__liyong1"] = "今日，我虽死，却未辱武安之名！",
  ["$xh__liyong2"] = "我受文举恩义，今当以死报之！",
}

-- 控制阳阴效果的状态切换
liyong:addEffect("active", {
  anim_type = "switch",
  min_card_num = 0,
  max_card_num = 1,
  min_target_num = 1,
  prompt = function(self, player)
    return "#xh__liyong-"..player:getSwitchSkillState(liyong.name, false, true)
  end,
  can_use = Util.TrueFunc,
  card_filter = function(self, player, to_select, selected)
    if player:getSwitchSkillState(liyong.name, false) == fk.SwitchYang and #selected == 0 then
      local suit = Fk:getCardById(to_select):getSuitString(true)
      if suit == "log_nosuit" then return end
      local card = Fk:cloneCard("duel")
      card.skillName = liyong.name
      card:addSubcard(to_select)
      return player:canUse(card) and not table.contains(player:getTableMark("@xh__liyong-turn"), suit)
    end
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if player:getSwitchSkillState(liyong.name, false) == fk.SwitchYang and #selected_cards == 1 then
      local card = Fk:cloneCard("duel")
      card.skillName = liyong.name
      card:addSubcards(selected_cards)
      return card.skill:targetFilter(player, to_select, selected, {}, card)
    elseif player:getSwitchSkillState(liyong.name, false) == fk.SwitchYin then
      return #selected == 0 and to_select:canUseTo(Fk:cloneCard("duel"), player)
    end
  end,
  feasible = function(self, player, selected, selected_cards)
    if #selected_cards == 1 and player:getSwitchSkillState(liyong.name, false) == fk.SwitchYang then
      local card = Fk:cloneCard("duel")
      card.skillName = liyong.name
      card:addSubcards(selected_cards)
      return card.skill:feasible(player, selected, {}, card)
    elseif #selected_cards == 0 and player:getSwitchSkillState(liyong.name, false) == fk.SwitchYin then
      return #selected == 1
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    -- 阳：使用未使用过花色的牌当【决斗】使用
    if player:getSwitchSkillState(liyong.name, true) == fk.SwitchYang then
      room:sortByAction(effect.tos)
      room:useVirtualCard("duel", effect.cards, player, effect.tos, liyong.name)
    else
      -- 阴：从弃牌堆中获得一张已使用过花色的牌
      local cards = table.filter(room.draw_pile, function(id)
        return table.contains(player:getTableMark("@xh__liyong-turn"), Fk:getCardById(id):getSuitString(true))
      end)
      if #cards > 0 then
        room:moveCardTo(table.random(cards), Card.PlayerHand, player, fk.ReasonJustMove, liyong.name, nil, true, player)
      end
      -- 选择目标并使用【决斗】
      local target = effect.tos[1]
      if not player.dead and not target.dead then
        room:useVirtualCard("duel", nil, target, player, liyong.name)
      end
    end
  end,
})

liyong:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(liyong.name, true) and
      player.room:getCurrent() == player and data.card.suit ~= Card.NoSuit
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "@xh__liyong-turn", data.card:getSuitString(true))
  end,
})

liyong:addAcquireEffect(function (self, player, is_start)
  if player.room.current == player then
    local room = player.room
    local mark = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data
      if use.from == player and use.card.suit ~= Card.NoSuit then
        table.insertIfNeed(mark, use.card:getSuitString(true))
      end
    end, Player.HistoryTurn)
    if #mark > 0 then
      room:setPlayerMark(player, "@xh__liyong-turn", mark)
    end
  end
end)

return liyong