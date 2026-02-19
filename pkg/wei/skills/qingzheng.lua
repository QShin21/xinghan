-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹操 - 清正技能
-- 出牌阶段开始时，你可以展示所有手牌并弃置其中一种花色的所有牌，
-- 然后展示一名其他角色的所有手牌并弃置其中一种花色的所有牌，
-- 若你以此法被弃置的牌数大于其以此法被弃置的牌数，你对其造成1点伤害。

local qingzheng = fk.CreateSkill {
  name = "qingzheng",
}

Fk:loadTranslationTable {
  ["qingzheng"] = "清正",
  [":qingzheng"] = "出牌阶段开始时，你可以展示所有手牌并弃置其中一种花色的所有牌，"..
    "然后展示一名其他角色的所有手牌并弃置其中一种花色的所有牌，"..
    "若你以此法被弃置的牌数大于其以此法被弃置的牌数，你对其造成1点伤害。",

  ["#qingzheng-invoke"] = "清正：展示手牌，弃置一种花色的牌，令其他角色弃置同花色牌",
  ["#qingzheng-suit"] = "清正：选择要弃置的花色",
  ["#qingzheng-target"] = "清正：选择一名其他角色",

  ["$qingzheng1"] = "清正廉明，公正无私！",
  ["$qingzheng2"] = "正大光明，何惧之有！",
}

qingzheng:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qingzheng.name) and
      player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = qingzheng.name,
      prompt = "#qingzheng-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 展示所有手牌
    local handcards = player:getCardIds("h")
    room:showCards(player, handcards, qingzheng.name)

    -- 统计各花色数量
    local suit_counts = {}
    for _, id in ipairs(handcards) do
      local card = Fk:getCardById(id)
      if card.suit then
        suit_counts[card.suit] = (suit_counts[card.suit] or 0) + 1
      end
    end

    -- 选择要弃置的花色
    local suits = {}
    for suit, _ in pairs(suit_counts) do
      table.insert(suits, suit)
    end

    if #suits == 0 then return end

    local suit_names = {"spade", "heart", "club", "diamond"}
    local suit_choices = {}
    for _, suit in ipairs(suits) do
      table.insert(suit_choices, suit_names[suit] or tostring(suit))
    end

    local choice = room:askToChoice(player, {
      choices = suit_choices,
      skill_name = qingzheng.name,
      prompt = "#qingzheng-suit",
      detailed = false,
    })

    -- 找到对应的花色
    local chosen_suit
    for i, name in ipairs(suit_names) do
      if name == choice then
        chosen_suit = i
        break
      end
    end

    -- 弃置该花色的所有牌
    local my_discard = table.filter(handcards, function(id)
      return Fk:getCardById(id).suit == chosen_suit
    end)

    room:throwCard(my_discard, qingzheng.name, player, player)

    -- 选择一名其他角色
    local targets = room:getOtherPlayers(player, false)
    if #targets == 0 then return end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = qingzheng.name,
      prompt = "#qingzheng-target",
      cancelable = false,
    })[1]

    if to.dead or to:isKongcheng() then return end

    -- 展示其所有手牌
    local to_handcards = to:getCardIds("h")
    room:showCards(to, to_handcards, qingzheng.name)

    -- 弃置其中一种花色的所有牌
    local to_suit_counts = {}
    for _, id in ipairs(to_handcards) do
      local card = Fk:getCardById(id)
      if card.suit then
        to_suit_counts[card.suit] = (to_suit_counts[card.suit] or 0) + 1
      end
    end

    local to_suits = {}
    for suit, _ in pairs(to_suit_counts) do
      table.insert(to_suits, suit)
    end

    if #to_suits > 0 then
      local to_suit_choices = {}
      for _, suit in ipairs(to_suits) do
        table.insert(to_suit_choices, suit_names[suit] or tostring(suit))
      end

      local to_choice = room:askToChoice(player, {
        choices = to_suit_choices,
        skill_name = qingzheng.name,
        prompt = "#qingzheng-suit",
        detailed = false,
      })

      -- 找到对应的花色
      local to_chosen_suit
      for i, name in ipairs(suit_names) do
        if name == to_choice then
          to_chosen_suit = i
          break
        end
      end

      local to_discard = table.filter(to_handcards, function(id)
        return Fk:getCardById(id).suit == to_chosen_suit
      end)

      room:throwCard(to_discard, qingzheng.name, to, player)

      -- 比较弃置数量
      if #my_discard > #to_discard and not to.dead then
        room:damage{
          from = player,
          to = to,
          damage = 1,
          skillName = qingzheng.name,
        }
      end
    end
  end,
})

return qingzheng
