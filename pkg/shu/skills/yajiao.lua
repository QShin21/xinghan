-- SPDX-License-Identifier: GPL-3.0-or-later
-- 赵云 - 涯角技能
-- 当你于回合外使用或打出手牌时，你可以展示牌堆顶的一张牌，
-- 若此牌与你使用或打出的牌的类别：相同，你可以将此牌交给一名角色；
-- 不同，你可以弃置一名攻击范围内含有你的角色区域里的一张牌。

local yajiao = fk.CreateSkill {
  name = "yajiao",
}

Fk:loadTranslationTable {
  ["yajiao"] = "涯角",
  [":yajiao"] = "当你于回合外使用或打出手牌时，你可以展示牌堆顶的一张牌，"..
    "若此牌与你使用或打出的牌的类别：相同，你可以将此牌交给一名角色；"..
    "不同，你可以弃置一名攻击范围内含有你的角色区域里的一张牌。",

  ["#yajiao-invoke"] = "涯角：是否展示牌堆顶的一张牌？",
  ["#yajiao-give"] = "涯角：类别相同，你可以将此牌交给一名角色",
  ["#yajiao-discard"] = "涯角：类别不同，你可以弃置一名攻击范围内含有你的角色的一张牌",

  ["$yajiao1"] = "涯角枪法，攻守兼备！",
  ["$yajiao2"] = "枪出如龙，势不可挡！",
}

yajiao:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yajiao.name) and
      player.phase == Player.NotActive and
      data.card and not data.card:isVirtual() and
      player.room:getDrawPileNum() > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yajiao.name,
      prompt = "#yajiao-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local used_card = data.card

    -- 展示牌堆顶的一张牌
    local top_card = room:getNCards(1)[1]
    local shown = Fk:getCardById(top_card)
    room:showCards(player, {top_card}, yajiao.name)

    -- 比较类别
    if shown.type == used_card.type then
      -- 类别相同：将此牌交给一名角色
      local targets = room.alive_players
      if #targets > 0 then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = yajiao.name,
          prompt = "#yajiao-give",
          cancelable = true,
        })

        if #to > 0 then
          room:moveCardTo(top_card, Player.Hand, to[1], fk.ReasonGive, yajiao.name, nil, false, player.id)
        else
          -- 不交给任何人，牌置入弃牌堆
          room:moveCardTo(top_card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile)
        end
      end
    else
      -- 类别不同：弃置攻击范围内含有你的角色的一张牌
      local targets = table.filter(room.alive_players, function(p)
        return p:inMyAttackRange(player) and not p:isAllNude()
      end)

      if #targets > 0 then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = yajiao.name,
          prompt = "#yajiao-discard",
          cancelable = true,
        })

        if #to > 0 then
          local id = room:askToChooseCard(player, {
            target = to[1],
            flag = "hej",
            skill_name = yajiao.name,
          })
          room:throwCard(id, yajiao.name, to[1], player)
        end
      end

      -- 牌置入弃牌堆
      room:moveCardTo(top_card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile)
    end
  end,
})

-- 打出牌时也触发
yajiao:addEffect(fk.CardResponding, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yajiao.name) and
      player.phase == Player.NotActive and
      data.card and not data.card:isVirtual() and
      player.room:getDrawPileNum() > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yajiao.name,
      prompt = "#yajiao-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local used_card = data.card

    -- 展示牌堆顶的一张牌
    local top_card = room:getNCards(1)[1]
    local shown = Fk:getCardById(top_card)
    room:showCards(player, {top_card}, yajiao.name)

    -- 比较类别
    if shown.type == used_card.type then
      -- 类别相同：将此牌交给一名角色
      local targets = room.alive_players
      if #targets > 0 then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = yajiao.name,
          prompt = "#yajiao-give",
          cancelable = true,
        })

        if #to > 0 then
          room:moveCardTo(top_card, Player.Hand, to[1], fk.ReasonGive, yajiao.name, nil, false, player.id)
        else
          room:moveCardTo(top_card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile)
        end
      end
    else
      -- 类别不同：弃置攻击范围内含有你的角色的一张牌
      local targets = table.filter(room.alive_players, function(p)
        return p:inMyAttackRange(player) and not p:isAllNude()
      end)

      if #targets > 0 then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = yajiao.name,
          prompt = "#yajiao-discard",
          cancelable = true,
        })

        if #to > 0 then
          local id = room:askToChooseCard(player, {
            target = to[1],
            flag = "hej",
            skill_name = yajiao.name,
          })
          room:throwCard(id, yajiao.name, to[1], player)
        end
      end

      room:moveCardTo(top_card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile)
    end
  end,
})

return yajiao
