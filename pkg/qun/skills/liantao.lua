-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孙策 - 连讨技能
-- 出牌阶段开始时，你可以令一名其他角色声明一种颜色，然后你展示所有手牌
-- 并将与声明的颜色相同的手牌依次当【决斗】对其使用，直到你或其进入濒死状态，
-- 然后你摸等同于你以此法造成伤害数量的牌。若该角色未以此法受到过伤害，
-- 你摸一张牌，直到本回合结束，你的手牌上限+1且不能使用【杀】。

local liantao = fk.CreateSkill {
  name = "liantao",
}

Fk:loadTranslationTable {
  ["liantao"] = "连讨",
  [":liantao"] = "出牌阶段开始时，你可以令一名其他角色声明一种颜色，然后你展示所有手牌"..
    "并将与声明的颜色相同的手牌依次当【决斗】对其使用，直到你或其进入濒死状态，"..
    "然后你摸等同于你以此法造成伤害数量的牌。若该角色未以此法受到过伤害，"..
    "你摸一张牌，直到本回合结束，你的手牌上限+1且不能使用【杀】。",

  ["#liantao-choose"] = "连讨：选择一名角色声明颜色",
  ["#liantao-declare"] = "连讨：请声明一种颜色",
  ["@@liantao_no_slash"] = "连讨",
  ["@@liantao_hand_limit"] = "连讨",

  ["$liantao1"] = "连讨逆贼，誓不罢休！",
  ["$liantao2"] = "讨伐奸佞，匡扶汉室！",
}

liantao:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(liantao.name) and
      player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = liantao.name,
      prompt = "#liantao-choose",
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

    -- 目标声明颜色
    local color = room:askToChoice(to, {
      choices = {"红色", "黑色"},
      skill_name = liantao.name,
      prompt = "#liantao-declare",
      detailed = false,
    })

    local is_red = (color == "红色")

    -- 展示所有手牌
    local handcards = player:getCardIds("h")
    room:showCards(player, handcards, liantao.name)

    -- 筛选符合颜色的牌
    local duel_cards = table.filter(handcards, function(id)
      local card = Fk:getCardById(id)
      if is_red then
        return card.color == Card.Red
      else
        return card.color == Card.Black
      end
    end)

    -- 记录造成的伤害
    local damage_count = 0
    local target_damaged = false

    -- 依次当决斗使用
    for _, id in ipairs(duel_cards) do
      if player.dead or to.dead then break end

      -- 检查是否进入濒死状态
      if player.hp <= 0 or to.hp <= 0 then break end

      local duel = Fk:cloneCard("duel")
      duel.skillName = liantao.name
      duel:addSubcard(id)

      local use = {
        from = player.id,
        tos = {to.id},
        card = duel,
      }

      -- 记录使用前的体力
      local hp_before = to.hp

      room:useCard(use)

      -- 检查是否造成伤害
      if to.hp < hp_before then
        damage_count = damage_count + (hp_before - to.hp)
        target_damaged = true
      end
    end

    -- 摸等同于造成伤害数量的牌
    if damage_count > 0 and not player.dead then
      player:drawCards(damage_count, liantao.name)
    end

    -- 若未造成伤害
    if not target_damaged and not player.dead then
      player:drawCards(1, liantao.name)
      room:setPlayerMark(player, "@@liantao_no_slash", 1)
      room:setPlayerMark(player, "@@liantao_hand_limit", 1)
    end
  end,
})

-- 不能使用杀
liantao:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    return player:getMark("@@liantao_no_slash") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.cancel = true
  end,
})

-- 手牌上限+1
liantao:addEffect(fk.MaxCardsCalc, {
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@liantao_hand_limit") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.num = data.num + 1
  end,
})

-- 回合结束清除标记
liantao:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@liantao_no_slash") > 0 or player:getMark("@@liantao_hand_limit") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@liantao_no_slash", 0)
    room:setPlayerMark(player, "@@liantao_hand_limit", 0)
  end,
})

return liantao
