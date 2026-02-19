-- SPDX-License-Identifier: GPL-3.0-or-later
-- 乐进 - 骁果技能
-- 其他角色的结束阶段，你可以弃置一张手牌，然后该角色选择一项：
-- 1. 弃置一张装备牌，你摸一张牌；
-- 2. 受到你造成的1点伤害。

local xiaoguo = fk.CreateSkill {
  name = "xh__xiaoguo",
}

Fk:loadTranslationTable {
  ["xh__xiaoguo"] = "骁果",
  [":xh__xiaoguo"] = "其他角色的结束阶段，你可以弃置一张手牌，然后该角色选择一项："..
    "1. 弃置一张装备牌，你摸一张牌；2. 受到你造成的1点伤害。",

  ["#xh__xiaoguo-invoke"] = "骁果：你可以弃置一张手牌",
  ["#xh__xiaoguo-choice"] = "骁果：请选择一项",
  ["xiaoguo_choice1"] = "弃置一张装备牌，对方摸一张牌",
  ["xiaoguo_choice2"] = "受到1点伤害",

  ["$xh__xiaoguo1"] = "骁勇善战，果敢无畏！",
  ["$xh__xiaoguo2"] = "冲锋陷阵，所向披靡！",
}

xiaoguo:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(xh__xiaoguo.name) and
      target.phase == Player.Finish and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = xh__xiaoguo.name,
      pattern = ".",
      prompt = "#xiaoguo-invoke",
      cancelable = true,
    })

    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = event:getCostData(self).cards[1]

    -- 弃置手牌
    room:throwCard(card, xh__xiaoguo.name, player, player)

    if target.dead then return end

    -- 目标选择
    local has_equip = table.find(target:getCardIds("e"), function(id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)

    local choices = {"xiaoguo_choice2"}  -- 默认可以受到伤害
    if has_equip then
      table.insert(choices, 1, "xiaoguo_choice1")
    end

    local choice = room:askToChoice(target, {
      choices = choices,
      skill_name = xh__xiaoguo.name,
      prompt = "#xiaoguo-choice",
      detailed = false,
    })

    if choice == "xiaoguo_choice1" then
      -- 弃置一张装备牌，你摸一张牌
      local equip_cards = table.filter(target:getCardIds("e"), function(id)
        return Fk:getCardById(id).type == Card.TypeEquip
      end)

      if #equip_cards > 0 then
        local id = room:askToChooseCard(player, {
          target = target,
          flag = "e",
          skill_name = xh__xiaoguo.name,
        })
        room:throwCard(id, xh__xiaoguo.name, target, player)
        player:drawCards(1, xh__xiaoguo.name)
      end
    else
      -- 受到1点伤害
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = xh__xiaoguo.name,
      }
    end
  end,
})

return xiaoguo
