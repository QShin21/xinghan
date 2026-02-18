-- SPDX-License-Identifier: GPL-3.0-or-later
-- 李傕 - 亦算技能
-- 出牌阶段限一次，当你使用的普通锦囊牌结算结束后，你可以失去1点体力或减1点体力上限，然后获得此牌。

local yisuan = fk.CreateSkill {
  name = "yisuan",
}

Fk:loadTranslationTable {
  ["yisuan"] = "亦算",
  [":yisuan"] = "出牌阶段限一次，当你使用的普通锦囊牌结算结束后，你可以失去1点体力或减1点体力上限，然后获得此牌。",

  ["#yisuan-invoke"] = "亦算：失去1点体力或减1点体力上限，获得此牌",
  ["#yisuan-choice"] = "亦算：请选择一项",
  ["yisuan_choice1"] = "失去1点体力",
  ["yisuan_choice2"] = "减1点体力上限",

  ["$yisuan1"] = "算无遗策，尽在掌握！",
  ["$yisuan2"] = "此计已成，再来一计！",
}

yisuan:addEffect(fk.CardUseFinished, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yisuan.name) and
      player.phase == Player.Play and
      player:usedSkillTimes(yisuan.name, Player.HistoryPhase) == 0 and
      data.card and data.card.type == Card.TypeTrick and not data.card:isVirtual() and
      data.card.place == Card.DiscardPile
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yisuan.name,
      prompt = "#yisuan-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    local choices = {"yisuan_choice1", "yisuan_choice2"}
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = yisuan.name,
      prompt = "#yisuan-choice",
      detailed = false,
    })

    if choice == "yisuan_choice1" then
      room:loseHp(player, 1, yisuan.name)
    else
      room:changeMaxHp(player, -1)
    end

    -- 获得此牌
    if not player.dead and data.card.place == Card.DiscardPile then
      room:moveCardTo(data.card.id, Player.Hand, player, fk.ReasonPrey, yisuan.name)
    end
  end,
})

return yisuan
