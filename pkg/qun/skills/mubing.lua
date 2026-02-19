-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张辽(群) - 募兵技能
-- 出牌阶段开始时，你可以亮出牌堆顶的三张牌，然后你可以弃置任意张手牌，
-- 获得任意亮出的牌（你弃置的牌点数和不得小于你获得的牌的点数和）。

local mubing = fk.CreateSkill {
  name = "xh__mubing",
}

Fk:loadTranslationTable {
  ["xh__mubing"] = "募兵",
  [":xh__mubing"] = "出牌阶段开始时，你可以亮出牌堆顶的三张牌，然后你可以弃置任意张手牌，"..
    "获得任意亮出的牌（你弃置的牌点数和不得小于你获得的牌的点数和）。",

  ["#xh__mubing-invoke"] = "募兵：是否亮出牌堆顶三张牌？",

  ["$xh__mubing1"] = "募兵之计，广纳贤才！",
  ["$xh__mubing2"] = "张辽募兵，天下无双！",
}

mubing:addEffect(fk.EventPhaseStart, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(xh__mubing.name) then return false end
    if player.phase ~= Player.Play then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xh__mubing.name,
      prompt = "#mubing-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 亮出牌堆顶三张牌
    local cards = {}
    for i = 1, 3 do
      if #room.draw_pile > 0 then
        table.insert(cards, room.draw_pile[1])
        room:showCards(player, {room.draw_pile[1]}, xh__mubing.name)
        table.remove(room.draw_pile, 1)
      end
    end
    
    if #cards == 0 then return end
    
    -- 询问是否弃置手牌获得亮出的牌
    if player:isKongcheng() then
      -- 没有手牌，不能获得
      for _, id in ipairs(cards) do
        room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xh__mubing.name)
      end
      return
    end
    
    -- 选择要弃置的手牌
    local discard_cards = room:askToCards(player, {
      min_num = 0,
      max_num = player:getHandcardNum(),
      include_equip = false,
      skill_name = xh__mubing.name,
      pattern = ".",
      prompt = "选择要弃置的手牌（点数和需大于等于要获得的牌点数和）",
      cancelable = true,
    })
    
    if #discard_cards == 0 then
      -- 不弃置，所有牌放入弃牌堆
      for _, id in ipairs(cards) do
        room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xh__mubing.name)
      end
      return
    end
    
    -- 计算弃置牌点数和
    local discard_sum = 0
    for _, id in ipairs(discard_cards) do
      discard_sum = discard_sum + Fk:getCardById(id).number
    end
    
    -- 选择要获得的牌
    local get_cards = room:askToCards(player, {
      min_num = 0,
      max_num = #cards,
      include_equip = false,
      skill_name = xh__mubing.name,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "选择要获得的牌（点数和需小于等于弃置牌点数和）",
      cancelable = true,
    })
    
    if #get_cards == 0 then
      -- 不获得，弃置手牌，所有亮出的牌放入弃牌堆
      room:throwCard(discard_cards, xh__mubing.name, player, player)
      for _, id in ipairs(cards) do
        room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xh__mubing.name)
      end
      return
    end
    
    -- 计算获得牌点数和
    local get_sum = 0
    for _, id in ipairs(get_cards) do
      get_sum = get_sum + Fk:getCardById(id).number
    end
    
    -- 检查点数和
    if discard_sum >= get_sum then
      -- 弃置手牌
      room:throwCard(discard_cards, xh__mubing.name, player, player)
      
      -- 获得牌
      room:moveCardTo(get_cards, Player.Hand, player, fk.ReasonPrey, xh__mubing.name)
      
      -- 剩余的牌放入弃牌堆
      for _, id in ipairs(cards) do
        if not table.contains(get_cards, id) then
          room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xh__mubing.name)
        end
      end
    else
      -- 点数和不够，弃置手牌，所有亮出的牌放入弃牌堆
      room:throwCard(discard_cards, xh__mubing.name, player, player)
      for _, id in ipairs(cards) do
        room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xh__mubing.name)
      end
    end
  end,
})

return mubing
