local xingluan = fk.CreateSkill {
  name = "xh__xingluan",
}

Fk:loadTranslationTable{
  ["xh__xingluan"] = "兴乱",
  [":xh__xingluan"] = "出牌阶段限一次，当你使用仅指定一个目标的牌结算完毕后，你可以将牌堆顶六张牌置入弃牌堆，然后从弃牌堆中选择一张点数为6且上个回合未选择的牌名的牌获得。",
  
  ["$xh__xingluan1"] = "大兴兵争，长安当乱。",
  ["$xh__xingluan2"] = "勇猛兴军，乱世当立。",
}

-- 存储上个回合已选择的牌名
local last_round_selected = {}

xingluan:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xingluan.name) and player.phase == Player.Play and
      #data.tos == 1 and player:usedSkillTimes(xingluan.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 将牌堆顶六张牌置入弃牌堆
    local cards = room:getNCards(6, "top")
    room:moveCardsTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xingluan.name, nil, true, player)
    
    -- 从弃牌堆中选择点数为6且上个回合未选择的牌名的牌
    local available_cards = table.filter(cards, function(card_id)
      local card = Fk:getCardById(card_id)
      return card.number == 6 and not table.contains(last_round_selected, card.name)
    end)
    
    -- 如果有符合条件的牌，可以让玩家选择
    if #available_cards > 0 then
      local selected_card = room:askToChooseCard(player, {
        min_num = 1,
        max_num = 1,
        skill_name = xingluan.name,
        prompt = "请选择一张点数为6且上个回合未选择的牌",
        cards = available_cards,
      })
      if selected_card then
        -- 玩家选择的牌移至手牌
        room:moveCardTo(selected_card, Card.PlayerHand, player, fk.ReasonGetFromDiscard, xingluan.name, nil, false, player)
        
        -- 记录本次选择的牌名，用于下回合的过滤
        table.insert(last_round_selected, Fk:getCardById(selected_card).name)
      end
    else
      -- 如果没有符合条件的牌，摸6张牌
      player:drawCards(6, xingluan.name)
    end
  end,
})

return xingluan