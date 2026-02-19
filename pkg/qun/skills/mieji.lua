-- SPDX-License-Identifier: GPL-3.0-or-later
-- 李儒 - 灭计技能
-- 出牌阶段限一次，你可以展示一张黑色锦囊牌并将此牌置于牌堆顶，
-- 然后你令一名有牌的其他角色选择一项：1.弃置一张锦囊牌；2.依次弃置两张非锦囊牌。

local mieji = fk.CreateSkill {
  name = "mieji",
}

Fk:loadTranslationTable {
  ["mieji"] = "灭计",
  [":mieji"] = "出牌阶段限一次，你可以展示一张黑色锦囊牌并将此牌置于牌堆顶，"..
    "然后你令一名有牌的其他角色选择一项：1.弃置一张锦囊牌；2.依次弃置两张非锦囊牌。",

  ["#mieji-use"] = "灭计：展示一张黑色锦囊牌置于牌堆顶",
  ["#mieji-choice"] = "灭计：请选择一项",
  ["mieji_choice1"] = "弃置一张锦囊牌",
  ["mieji_choice2"] = "依次弃置两张非锦囊牌",

  ["$mieji1"] = "灭计破敌，算无遗策！",
  ["$mieji2"] = "计谋已定，必取敌首！",
}

mieji:addEffect("active", {
  mute = true,
  prompt = "#mieji-use",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(mieji.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local card = Fk:getCardById(to_select)
    return card.color == Card.Black and card.type == Card.TypeTrick
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    if #selected_cards == 0 then return false end
    return to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card = effect.cards[1]

    room:notifySkillInvoked(player, mieji.name, "control", {target})
    player:broadcastSkillInvoke(mieji.name)

    -- 展示牌
    room:showCards(player, {card}, mieji.name)

    -- 将牌置于牌堆顶
    room:moveCardTo(card, Card.DrawPile, nil, fk.ReasonPut, mieji.name, nil, true)

    if target.dead then return end

    -- 检查是否有锦囊牌
    local has_trick = table.find(target:getCardIds("he"), function(id)
      return Fk:getCardById(id).type == Card.TypeTrick
    end)

    -- 检查是否有两张非锦囊牌
    local non_trick_count = 0
    for _, id in ipairs(target:getCardIds("he")) do
      if Fk:getCardById(id).type ~= Card.TypeTrick then
        non_trick_count = non_trick_count + 1
      end
    end

    local choices = {}
    if has_trick then
      table.insert(choices, "mieji_choice1")
    end
    if non_trick_count >= 2 then
      table.insert(choices, "mieji_choice2")
    end

    if #choices == 0 then return end

    local choice = room:askToChoice(target, {
      choices = choices,
      skill_name = mieji.name,
      prompt = "#mieji-choice",
      detailed = false,
    })

    if choice == "mieji_choice1" then
      -- 弃置一张锦囊牌
      local trick_cards = table.filter(target:getCardIds("he"), function(id)
        return Fk:getCardById(id).type == Card.TypeTrick
      end)

      local id = room:askToChooseCard(player, {
        target = target,
        flag = "he",
        skill_name = mieji.name,
      })
      room:throwCard(id, mieji.name, target, player)
    else
      -- 依次弃置两张非锦囊牌
      for i = 1, 2 do
        if target.dead or target:isNude() then break end

        local non_trick = table.filter(target:getCardIds("he"), function(id)
          return Fk:getCardById(id).type ~= Card.TypeTrick
        end)

        if #non_trick == 0 then break end

        local id = room:askToChooseCard(player, {
          target = target,
          flag = "he",
          skill_name = mieji.name,
        })
        room:throwCard(id, mieji.name, target, player)
      end
    end
  end,
})

return mieji
