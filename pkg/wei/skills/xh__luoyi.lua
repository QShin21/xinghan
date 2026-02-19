-- SPDX-License-Identifier: GPL-3.0-or-later
-- 许褚 - 裸衣技能
-- 摸牌阶段开始时，你可以亮出牌堆顶的三张牌，然后你可以获得其中的基本牌、武器牌和【决斗】。
-- 若如此做，你放弃摸牌，且直到你的下回合开始，以你为伤害来源的【杀】或【决斗】造成伤害时，此伤害+1。

local luoyi = fk.CreateSkill {
  name = "xh__luoyi",
}

Fk:loadTranslationTable {
  ["xh__luoyi"] = "裸衣",
  [":xh__luoyi"] = "摸牌阶段开始时，你可以亮出牌堆顶的三张牌，然后你可以获得其中的基本牌、武器牌和【决斗】。"..
    "若如此做，你放弃摸牌，且直到你的下回合开始，以你为伤害来源的【杀】或【决斗】造成伤害时，此伤害+1。",

  ["#xh__luoyi-invoke"] = "裸衣：你可以亮出牌堆顶的三张牌",
  ["#xh__luoyi-choose"] = "裸衣：选择要获得的牌",

  ["$xh__luoyi1"] = "脱！",
  ["$xh__luoyi2"] = "谁来与我大战三百回合！",
}

luoyi:addEffect(fk.DrawNCards, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(luoyi.name) and
      player.room:getDrawPileNum() >= 3
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = luoyi.name,
      prompt = "#xh__luoyi-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 亮出牌堆顶的三张牌
    local cards = room:getNCards(3)
    room:showCards(player, cards, luoyi.name)

    -- 筛选可获得的牌
    local get_cards = {}
    for _, id in ipairs(cards) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeBasic or
         (card.type == Card.TypeEquip and card.sub_type == Card.SubtypeWeapon) or
         card.name == "duel" then
        table.insert(get_cards, id)
      end
    end

    -- 选择要获得的牌
    if #get_cards > 0 then
      local chosen = room:askToCards(player, {
        min_num = 0,
        max_num = #get_cards,
        include_equip = false,
        skill_name = luoyi.name,
        pattern = tostring(Exppattern{ id = get_cards }),
        prompt = "#xh__luoyi-choose",
        cancelable = true,
      })

      if #chosen > 0 then
        -- 放弃摸牌
        data.num = 0

        -- 获得牌
        room:moveCardTo(chosen, Player.Hand, player, fk.ReasonPrey, luoyi.name)

        -- 设置标记，伤害+1
        room:setPlayerMark(player, "@@luoyi_damage", 1)

        -- 将剩余的牌置入弃牌堆
        local remaining = table.filter(cards, function(id)
          return not table.contains(chosen, id)
        end)
        if #remaining > 0 then
          room:moveCardTo(remaining, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile)
        end
      end
    else
      -- 没有可获得的牌，将牌置入弃牌堆
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile)
    end
  end,
})

-- 伤害+1效果
luoyi:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:getMark("@@luoyi_damage") > 0 then
      local card = data.card
      return card and (card.name == "slash" or card.name == "duel")
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

-- 下回合开始时清除标记
luoyi:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@luoyi_damage") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@luoyi_damage", 0)
  end,
})

return luoyi
