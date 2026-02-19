-- SPDX-License-Identifier: GPL-3.0-or-later
-- 陈宫 - 明策技能
-- 出牌阶段限一次，你可以交给对手一张牌，令其选择一项：
-- 1.摸一张牌，并令你摸两张牌；2.失去1点体力。

local mingce = fk.CreateSkill {
  name = "mingce",
}

Fk:loadTranslationTable {
  ["mingce"] = "明策",
  [":mingce"] = "出牌阶段限一次，你可以交给对手一张牌，令其选择一项："..
    "1.摸一张牌，并令你摸两张牌；2.失去1点体力。",

  ["#mingce-target"] = "明策：选择一名对手",
  ["mingce_draw"] = "摸一张牌，并令其摸两张牌",
  ["mingce_losehp"] = "失去1点体力",

  ["$mingce1"] = "明策之计，智取天下！",
  ["$mingce2"] = "陈宫明策，天下无双！",
}

mingce:addEffect("active", {
  mute = true,
  prompt = "#mingce-target",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(mingce.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return table.contains(player:getCardIds("he"), to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card_id = effect.cards[1]

    room:notifySkillInvoked(player, mingce.name, "control", {target})
    player:broadcastSkillInvoke(mingce.name)

    -- 交给对手一张牌
    room:moveCardTo(card_id, Player.Hand, target, fk.ReasonGive, mingce.name, nil, false, player.id)
    
    -- 对手选择
    local choice = room:askToChoice(target, {
      choices = {"mingce_draw", "mingce_losehp"},
      skill_name = mingce.name,
      prompt = "选择一项",
      detailed = false,
    })
    
    if choice == "mingce_draw" then
      target:drawCards(1, mingce.name)
      player:drawCards(2, mingce.name)
    else
      room:loseHp(target, 1, mingce.name)
    end
  end,
})

return mingce
