-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘辟 - 易城技能
-- 出牌阶段限一次，你可以展示牌堆顶X张牌（X为你的体力上限），
-- 然后可以用任意张手牌交换其中等量张牌，若展示牌点数之和因此增加，你可以用所有手牌交换展示牌。

local yicheng = fk.CreateSkill {
  name = "xh__yicheng",
}

Fk:loadTranslationTable {
  ["xh__yicheng"] = "易城",
  [":xh__yicheng"] = "出牌阶段限一次，你可以展示牌堆顶X张牌（X为你的体力上限），"..
    "然后可以用任意张手牌交换其中等量张牌，若展示牌点数之和因此增加，你可以用所有手牌交换展示牌。",

  ["#xh__yicheng-use"] = "易城：展示牌堆顶的牌",
  ["#xh__yicheng-exchange"] = "易城：选择要交换的牌",

  ["$xh__yicheng1"] = "易城之计，攻守兼备！",
  ["$xh__yicheng2"] = "黄巾刘辟，易城天下！",
}

yicheng:addEffect("active", {
  mute = true,
  prompt = "#yicheng-use",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(xh__yicheng.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, xh__yicheng.name, "draw")
    player:broadcastSkillInvoke(xh__yicheng.name)

    local x = player.maxHp
    
    -- 展示牌堆顶X张牌
    local cards = {}
    for i = 1, x do
      if #room.draw_pile > 0 then
        table.insert(cards, room.draw_pile[1])
        room:showCards(player, {room.draw_pile[1]}, xh__yicheng.name)
        table.remove(room.draw_pile, 1)
      end
    end
    
    if #cards == 0 then return end
    
    -- 计算原始点数和
    local original_sum = 0
    for _, id in ipairs(cards) do
      original_sum = original_sum + Fk:getCardById(id).number
    end
    
    -- 询问是否交换
    local handcards = player:getCardIds("h")
    
    if #handcards > 0 then
      local to_exchange = room:askToCards(player, {
        min_num = 1,
        max_num = math.min(#handcards, #cards),
        include_equip = false,
        skill_name = xh__yicheng.name,
        pattern = ".",
        prompt = "#yicheng-exchange",
        cancelable = true,
      })
      
      if #to_exchange > 0 then
        -- 计算交换后点数和
        local new_sum = 0
        for _, id in ipairs(to_exchange) do
          new_sum = new_sum + Fk:getCardById(id).number
        end
        
        -- 如果点数和增加，可以用所有手牌交换
        if new_sum > original_sum then
          local all_exchange = room:askToSkillInvoke(player, {
            skill_name = xh__yicheng.name,
            prompt = "是否用所有手牌交换展示牌？",
          })
          
          if all_exchange then
            to_exchange = handcards
          end
        end
        
        -- 执行交换
        local exchange_cards = {}
        for i = 1, #to_exchange do
          table.insert(exchange_cards, cards[i])
        end
        
        room:moveCardTo(to_exchange, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xh__yicheng.name)
        room:moveCardTo(exchange_cards, Player.Hand, player, fk.ReasonPrey, xh__yicheng.name)
        
        -- 剩余的牌放入弃牌堆
        for i = #to_exchange + 1, #cards do
          room:moveCardTo(cards[i], Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xh__yicheng.name)
        end
      else
        -- 不交换，所有牌放入弃牌堆
        for _, id in ipairs(cards) do
          room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xh__yicheng.name)
        end
      end
    else
      -- 没有手牌，所有牌放入弃牌堆
      for _, id in ipairs(cards) do
        room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xh__yicheng.name)
      end
    end
  end,
})

return yicheng
