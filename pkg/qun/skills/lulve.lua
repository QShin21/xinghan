-- SPDX-License-Identifier: GPL-3.0-or-later
-- 梁兴 - 掳掠技能
-- 出牌阶段开始时，你可以选择一名有手牌且手牌数小于你的角色，然后其选择一项：
-- 1. 交给你所有手牌，然后你结束此阶段；
-- 2. 你视为对其使用一张造成伤害+1的【杀】。

local lulve = fk.CreateSkill {
  name = "lulve",
}

Fk:loadTranslationTable {
  ["lulve"] = "掳掠",
  [":lulve"] = "出牌阶段开始时，你可以选择一名有手牌且手牌数小于你的角色，然后其选择一项："..
    "1. 交给你所有手牌，然后你结束此阶段；2. 你视为对其使用一张造成伤害+1的【杀】。",

  ["#lulve-choose"] = "掳掠：选择一名手牌数小于你的角色",
  ["#lulve-choice"] = "掳掠：请选择一项",
  ["lulve_choice1"] = "交给你所有手牌，然后其结束此阶段",
  ["lulve_choice2"] = "你视为对其使用一张造成伤害+1的【杀】",

  ["$lulve1"] = "掳掠财物，充实军资！",
  ["$lulve2"] = "交出财物，饶你不死！",
}

lulve:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lulve.name) and
      player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return not p:isKongcheng() and p:getHandcardNum() < player:getHandcardNum()
    end)

    if #targets == 0 then return false end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = lulve.name,
      prompt = "#lulve-choose",
      cancelable = true,
    })

    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]

    local choices = {"lulve_choice1", "lulve_choice2"}

    local choice = room:askToChoice(to, {
      choices = choices,
      skill_name = lulve.name,
      prompt = "#lulve-choice",
      detailed = false,
    })

    if choice == "lulve_choice1" then
      -- 交给你所有手牌
      local cards = to:getCardIds("h")
      room:moveCardTo(cards, Player.Hand, player, fk.ReasonGive, lulve.name, nil, false, to.id)

      -- 结束此阶段
      player.phase = Player.Finish
    else
      -- 视为对其使用一张造成伤害+1的杀
      local slash = Fk:cloneCard("slash")
      slash.skillName = lulve.name

      room:useCard{
        from = player.id,
        tos = {to.id},
        card = slash,
        extra_data = {lulve_damage = true},
      }
    end
  end,
})

-- 伤害+1
lulve:addEffect(fk.DamageCaused, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card or data.card.skillName ~= lulve.name then return false end

    local extra_data = data.extra_data or {}
    return extra_data.lulve_damage
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

return lulve
