-- SPDX-License-Identifier: GPL-3.0-or-later
-- 华雄 - 耀武技能
-- 锁定技，当你受到【杀】造成的伤害时，若此【杀】：
-- 为红色，伤害来源选择回复1点体力或摸一张牌；
-- 不为红色，则你摸一张牌。

local yaowu = fk.CreateSkill {
  name = "yaowu",
}

Fk:loadTranslationTable {
  ["yaowu"] = "耀武",
  [":yaowu"] = "锁定技，当你受到【杀】造成的伤害时，若此【杀】："..
    "为红色，伤害来源选择回复1点体力或摸一张牌；不为红色，则你摸一张牌。",

  ["#yaowu-choice"] = "耀武：选择回复1点体力或摸一张牌",

  ["$yaowu1"] = "耀武扬威，何惧之有！",
  ["$yaowu2"] = "看我取你首级！",
}

yaowu:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yaowu.name) and
      data.card and data.card.trueName == "slash" and
      data.from and data.damage > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    local card = data.card

    if card.color == Card.Red then
      -- 红色：伤害来源选择回复体力或摸牌
      local choices = {}
      if from:isWounded() then
        table.insert(choices, "回复1点体力")
      end
      table.insert(choices, "摸一张牌")

      local choice = room:askToChoice(from, {
        choices = choices,
        skill_name = yaowu.name,
        prompt = "#yaowu-choice",
        detailed = false,
      })

      if choice == "回复1点体力" then
        room:recover{
          who = from,
          num = 1,
          recoverBy = from,
          skillName = yaowu.name,
        }
      else
        from:drawCards(1, yaowu.name)
      end
    else
      -- 不为红色：你摸一张牌
      player:drawCards(1, yaowu.name)
    end
  end,
})

return yaowu
