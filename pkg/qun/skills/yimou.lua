-- SPDX-License-Identifier: GPL-3.0-or-later
-- 鲍信 - 毅谋技能
-- 当与你距离1以内的角色受到伤害后，你可以选择一项：
-- 1. 令其摸一张牌；2. 令其将一张手牌交给另一名角色，然后其摸一张牌。

local yimou = fk.CreateSkill {
  name = "yimou",
}

Fk:loadTranslationTable {
  ["yimou"] = "毅谋",
  [":yimou"] = "当与你距离1以内的角色受到伤害后，你可以选择一项："..
    "1. 令其摸一张牌；2. 令其将一张手牌交给另一名角色，然后其摸一张牌。",

  ["#yimou-invoke"] = "毅谋：你可以令 %dest 摸一张牌或交出一张牌后摸牌",
  ["#yimou-choice"] = "毅谋：请选择一项",
  ["yimou_choice1"] = "令其摸一张牌",
  ["yimou_choice2"] = "令其将一张手牌交给另一名角色，然后其摸一张牌",
  ["#yimou-give"] = "毅谋：选择要交出的手牌",
  ["#yimou-target"] = "毅谋：选择一名角色接收牌",

  ["$yimou1"] = "坚毅果敢，谋定后动！",
  ["$yimou2"] = "智勇双全，方能成事！",
}

yimou:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yimou.name) and target ~= player and
      player:distanceTo(target) <= 1 and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yimou.name,
      prompt = "#yimou-invoke::" .. target.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    local choices = {"yimou_choice1"}
    if not target:isKongcheng() then
      table.insert(choices, "yimou_choice2")
    end

    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = yimou.name,
      prompt = "#yimou-choice",
      detailed = false,
    })

    if choice == "yimou_choice1" then
      -- 令其摸一张牌
      target:drawCards(1, yimou.name)
    else
      -- 令其将一张手牌交给另一名角色，然后其摸一张牌
      local card = room:askToCards(target, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = yimou.name,
        pattern = ".",
        prompt = "#yimou-give",
        cancelable = false,
      })

      local others = room:getOtherPlayers(target, false)
      local to = room:askToChoosePlayers(target, {
        min_num = 1,
        max_num = 1,
        targets = others,
        skill_name = yimou.name,
        prompt = "#yimou-target",
        cancelable = false,
      })[1]

      room:moveCardTo(card, Player.Hand, to, fk.ReasonGive, yimou.name, nil, false, target.id)

      -- 其摸一张牌
      if not target.dead then
        target:drawCards(1, yimou.name)
      end
    end
  end,
})

return yimou
