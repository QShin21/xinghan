-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孔融 - 名士技能
-- 锁定技，当你受到伤害时，若伤害来源的手牌数大于你，其须选择一项：
-- 1. 弃置一张手牌；2. 令此伤害-1。

local mingshi = fk.CreateSkill {
  name = "mingshi",
}

Fk:loadTranslationTable {
  ["mingshi"] = "名士",
  [":mingshi"] = "锁定技，当你受到伤害时，若伤害来源的手牌数大于你，其须选择一项："..
    "1. 弃置一张手牌；2. 令此伤害-1。",

  ["#mingshi-choice"] = "名士：请选择一项",
  ["mingshi_choice1"] = "弃置一张手牌",
  ["mingshi_choice2"] = "令此伤害-1",

  ["$mingshi1"] = "名士风流，岂容尔等！",
  ["$mingshi2"] = "孔门之后，何惧之有！",
}

mingshi:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mingshi.name) and
      data.from and data.from ~= player and
      data.from:getHandcardNum() > player:getHandcardNum() and
      data.damage > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from

    local choices = {"mingshi_choice2"}  -- 默认可以令伤害-1
    if not from:isKongcheng() then
      table.insert(choices, 1, "mingshi_choice1")
    end

    local choice = room:askToChoice(from, {
      choices = choices,
      skill_name = mingshi.name,
      prompt = "#mingshi-choice",
      detailed = false,
    })

    if choice == "mingshi_choice1" then
      -- 弃置一张手牌
      local id = room:askToChooseCard(from, {
        target = from,
        flag = "h",
        skill_name = mingshi.name,
      })
      room:throwCard(id, mingshi.name, from, from)
    else
      -- 令此伤害-1
      data.damage = data.damage - 1
    end
  end,
})

return mingshi
