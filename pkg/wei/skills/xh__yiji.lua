-- SPDX-License-Identifier: GPL-3.0-or-later
-- 郭嘉 - 遗计技能
-- 当你受到伤害后，你可以摸两张牌，然后可以将至多两张手牌交给其他角色。
-- 当你每轮首次进入濒死状态时，你可以摸一张牌，然后可以将一张手牌交给其他角色。

local yiji = fk.CreateSkill {
  name = "xh__yiji",
}

Fk:loadTranslationTable {
  ["xh__yiji"] = "遗计",
  [":xh__yiji"] = "当你受到伤害后，你可以摸两张牌，然后可以将至多两张手牌交给其他角色。"..
    "当你每轮首次进入濒死状态时，你可以摸一张牌，然后可以将一张手牌交给其他角色。",

  ["#xh__yiji-invoke"] = "遗计：你可以摸两张牌，然后将至多两张手牌交给其他角色",
  ["#xh__yiji-give"] = "遗计：选择要交给 %dest 的牌",
  ["#xh__yiji-dying"] = "遗计：濒死时，你可以摸一张牌，然后将一张手牌交给其他角色",

  ["$xh__yiji1"] = "就这样吧。",
  ["$xh__yiji2"] = "也好。",
}

-- 受伤后摸牌给牌
yiji:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yiji.name) and data.damage > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yiji.name,
      prompt = "#xh__yiji-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 摸两张牌
    player:drawCards(2, yiji.name)

    -- 将至多两张手牌交给其他角色
    if player:isKongcheng() then return end

    local cards = room:askToCards(player, {
      min_num = 0,
      max_num = 2,
      include_equip = false,
      skill_name = yiji.name,
      pattern = ".",
      prompt = "选择至多两张手牌交给其他角色",
      cancelable = true,
    })

    if #cards > 0 then
      local targets = room:getOtherPlayers(player, false)
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = yiji.name,
        prompt = "#xh__yiji-give",
        cancelable = false,
      })[1]

      room:moveCardTo(cards, Player.Hand, to, fk.ReasonGive, yiji.name, nil, false, player.id)
    end
  end,
})

-- 濒死时摸牌给牌
yiji:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yiji.name) and
      player:usedEffectTimes(yiji.name .. "_dying", Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yiji.name,
      prompt = "#xh__yiji-dying",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 摸一张牌
    player:drawCards(1, yiji.name)

    -- 将一张手牌交给其他角色
    if player:isKongcheng() then return end

    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = yiji.name,
      pattern = ".",
      prompt = "选择一张手牌交给其他角色",
      cancelable = true,
    })

    if #card > 0 then
      local targets = room:getOtherPlayers(player, false)
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = yiji.name,
        prompt = "#xh__yiji-give",
        cancelable = false,
      })[1]

      room:moveCardTo(card, Player.Hand, to, fk.ReasonGive, yiji.name, nil, false, player.id)
    end
  end,
})

return yiji
