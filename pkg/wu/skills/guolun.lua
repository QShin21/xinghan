-- SPDX-License-Identifier: GPL-3.0-or-later
-- 庞统 - 过论技能
-- 出牌阶段限一次，你可以展示对手的一张手牌，然后你可以用你的一张牌交换此牌。
-- 若如此做，交换前点数小的一方摸一张牌。

local guolun = fk.CreateSkill {
  name = "guolun",
}

Fk:loadTranslationTable {
  ["guolun"] = "过论",
  [":guolun"] = "出牌阶段限一次，你可以展示对手的一张手牌，然后你可以用你的一张牌交换此牌。"..
    "若如此做，交换前点数小的一方摸一张牌。",

  ["#guolun-use"] = "过论：选择一名对手进行过论",
  ["#guolun-exchange"] = "过论：是否用一张牌交换？",

  ["$guolun1"] = "过论天下，谁与争锋！",
  ["$guolun2"] = "论天下大势，分久必合！",
}

guolun:addEffect("active", {
  mute = true,
  prompt = "#guolun-use",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(guolun.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, guolun.name, "control", {target})
    player:broadcastSkillInvoke(guolun.name)

    -- 展示对手一张手牌
    local handcards = target:getCardIds("h")
    local shown_id = room:askToChooseCard(player, {
      target = target,
      flag = "h",
      skill_name = guolun.name,
    })
    
    room:showCards(player, {shown_id}, guolun.name)
    
    -- 询问是否交换
    if player:isNude() then return end
    
    local exchange = room:askToSkillInvoke(player, {
      skill_name = guolun.name,
      prompt = "#guolun-exchange",
    })
    
    if not exchange then return end
    
    -- 选择一张牌交换
    local my_card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = guolun.name,
      pattern = ".",
      prompt = "选择一张牌交换",
      cancelable = false,
    })
    
    local my_id = my_card[1]
    local shown_card = Fk:getCardById(shown_id)
    local my_shown_card = Fk:getCardById(my_id)
    
    -- 交换
    room:moveCardTo(my_id, Player.Hand, target, fk.ReasonGive, guolun.name, nil, false, player.id)
    room:moveCardTo(shown_id, Player.Hand, player, fk.ReasonGive, guolun.name, nil, false, target.id)
    
    -- 点数小的一方摸牌
    if shown_card.number < my_shown_card.number then
      target:drawCards(1, guolun.name)
    elseif my_shown_card.number < shown_card.number then
      player:drawCards(1, guolun.name)
    end
  end,
})

return guolun
