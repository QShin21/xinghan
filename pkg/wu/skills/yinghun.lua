-- SPDX-License-Identifier: GPL-3.0-or-later
-- 英魂技能
-- 准备阶段，若你已受伤，你可以选择一名其他角色并选择一项：
-- 1.令其摸X张牌，然后其弃置一张牌；2.令其摸一张牌，然后其弃置X张牌（X为你已损失的体力值）。

local yinghun = fk.CreateSkill {
  name = "yinghun",
}

Fk:loadTranslationTable {
  ["yinghun"] = "英魂",
  [":yinghun"] = "准备阶段，若你已受伤，你可以选择一名其他角色并选择一项："..
    "1.令其摸X张牌，然后其弃置一张牌；2.令其摸一张牌，然后其弃置X张牌（X为你已损失的体力值）。",

  ["#yinghun-choose"] = "英魂：选择一名其他角色",
  ["#yinghun-choice"] = "英魂：选择一项",
  ["yinghun_draw"] = "令其摸%arg张牌，然后其弃置一张牌",
  ["yinghun_discard"] = "令其摸一张牌，然后其弃置%arg张牌",

  ["$yinghun1"] = "英魂不灭，浩气长存！",
  ["$yinghun2"] = "魂兮归来，佑我江东！",
}

yinghun:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yinghun.name) and
      player.phase == Player.Start and player:isWounded()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local targets = room:getOtherPlayers(player, false)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = yinghun.name,
      prompt = "#yinghun-choose",
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
    local x = player:getLostHp()
    
    local choices = {
      "yinghun_draw:::" .. x,
      "yinghun_discard:::" .. x,
    }
    
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = yinghun.name,
      prompt = "#yinghun-choice",
      detailed = true,
    })
    
    if choice:startsWith("yinghun_draw") then
      to:drawCards(x, yinghun.name)
      if not to.dead and not to:isNude() then
        local id = room:askToChooseCard(player, {
          target = to,
          flag = "he",
          skill_name = yinghun.name,
        })
        room:throwCard(id, yinghun.name, to, player)
      end
    else
      to:drawCards(1, yinghun.name)
      if not to.dead and to:getCardIds("he"):length() >= x then
        local cards = room:askToCards(player, {
          min_num = x,
          max_num = x,
          include_equip = true,
          skill_name = yinghun.name,
          pattern = ".",
          prompt = "弃置" .. x .. "张牌",
          cancelable = false,
        })
        room:throwCard(cards, yinghun.name, to, player)
      end
    end
  end,
})

return yinghun
