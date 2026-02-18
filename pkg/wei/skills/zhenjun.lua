-- SPDX-License-Identifier: GPL-3.0-or-later
-- 于禁 - 镇军技能
-- 准备阶段或结束阶段，你可以弃置一名角色的X张牌（X为其手牌数减体力值且至少为1），
-- 若其以此法被弃置的牌中没有装备牌，你选择一项：1. 弃置一张牌；2. 令其摸等量的牌。

local zhenjun = fk.CreateSkill {
  name = "zhenjun",
}

Fk:loadTranslationTable {
  ["zhenjun"] = "镇军",
  [":zhenjun"] = "准备阶段或结束阶段，你可以弃置一名角色的X张牌（X为其手牌数减体力值且至少为1），"..
    "若其以此法被弃置的牌中没有装备牌，你选择一项：1. 弃置一张牌；2. 令其摸等量的牌。",

  ["#zhenjun-choose"] = "镇军：选择一名角色弃置其X张牌",
  ["#zhenjun-discard"] = "镇军：选择要弃置的牌",
  ["#zhenjun-choice"] = "镇军：被弃置的牌中没有装备牌，请选择一项",
  ["zhenjun_choice1"] = "弃置一张牌",
  ["zhenjun_choice2"] = "令其摸等量的牌",

  ["$zhenjun1"] = "镇守边疆，保境安民！",
  ["$zhenjun2"] = "军令如山，违者必究！",
}

zhenjun:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(zhenjun.name) then return false end
    if player.phase ~= Player.Start and player.phase ~= Player.Finish then return false end

    local room = player.room
    return table.find(room:getOtherPlayers(player), function(p)
      local x = p:getHandcardNum() - p.hp
      return x >= 1 and not p:isNude()
    end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    -- 筛选可用的目标
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      local x = p:getHandcardNum() - p.hp
      return x >= 1 and not p:isNude()
    end)

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = zhenjun.name,
      prompt = "#zhenjun-choose",
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

    -- 计算X
    local x = to:getHandcardNum() - to.hp
    if x < 1 then x = 1 end

    -- 选择要弃置的牌
    local cards = room:askToCards(player, {
      min_num = x,
      max_num = x,
      include_equip = true,
      skill_name = zhenjun.name,
      pattern = tostring(Exppattern{ id = to:getCardIds("he") }),
      prompt = "#zhenjun-discard",
      cancelable = false,
      expand_pile = to:getCardIds("j"),
    })

    -- 检查是否有装备牌
    local has_equip = table.find(cards, function(id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)

    -- 弃置牌
    room:throwCard(cards, zhenjun.name, to, player)

    -- 若没有装备牌，选择一项
    if not has_equip and not player.dead then
      local choices = {"zhenjun_choice1", "zhenjun_choice2"}

      if player:isNude() then
        table.removeOne(choices, "zhenjun_choice1")
      end

      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = zhenjun.name,
        prompt = "#zhenjun-choice",
        detailed = false,
      })

      if choice == "zhenjun_choice1" then
        -- 弃置一张牌
        local card = room:askToCards(player, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = zhenjun.name,
          pattern = ".",
          cancelable = false,
        })
        room:throwCard(card, zhenjun.name, player, player)
      else
        -- 令其摸等量的牌
        if not to.dead then
          to:drawCards(#cards, zhenjun.name)
        end
      end
    end
  end,
})

return zhenjun
