-- SPDX-License-Identifier: GPL-3.0-or-later
-- 韩当 - 弓骑技能
-- 出牌阶段限一次，你可以弃置一张牌，然后你本回合的攻击范围为无限，
-- 且你本回合使用与你以此法弃置的牌花色相同的【杀】无次数限制，
-- 若你以此法弃置的牌为装备牌，你可以弃置一名其他角色的一张牌。

local gongqi = fk.CreateSkill {
  name = "gongqi",
}

Fk:loadTranslationTable {
  ["gongqi"] = "弓骑",
  [":gongqi"] = "出牌阶段限一次，你可以弃置一张牌，然后你本回合的攻击范围为无限，"..
    "且你本回合使用与你以此法弃置的牌花色相同的【杀】无次数限制，"..
    "若你以此法弃置的牌为装备牌，你可以弃置一名其他角色的一张牌。",

  ["#gongqi-use"] = "弓骑：弃置一张牌",
  ["#gongqi-discard"] = "弓骑：弃置一名其他角色的一张牌",
  ["@@gongqi_suit"] = "弓骑",

  ["$gongqi1"] = "弓马娴熟，百步穿杨！",
  ["$gongqi2"] = "看我这一箭！",
}

gongqi:addEffect("active", {
  mute = true,
  prompt = "#gongqi-use",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(gongqi.name, Player.HistoryPhase) == 0 and
      not player:isNude()
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return player:prohibitDiscard(Fk:getCardById(to_select)) == false
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local card = Fk:getCardById(effect.cards[1])

    room:notifySkillInvoked(player, gongqi.name, "offensive")
    player:broadcastSkillInvoke(gongqi.name)

    -- 记录花色
    room:setPlayerMark(player, "@@gongqi_suit", card.suit)

    -- 弃置牌
    room:throwCard(effect.cards[1], gongqi.name, player, player)

    -- 设置攻击范围为无限
    room:setPlayerMark(player, "@@gongqi_range", 1)

    -- 若为装备牌，可以弃置其他角色的一张牌
    if card.type == Card.TypeEquip then
      local targets = table.filter(room:getOtherPlayers(player), function(p)
        return not p:isNude()
      end)

      if #targets > 0 then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = gongqi.name,
          prompt = "#gongqi-discard",
          cancelable = true,
        })

        if #to > 0 then
          local id = room:askToChooseCard(player, {
            target = to[1],
            flag = "he",
            skill_name = gongqi.name,
          })
          room:throwCard(id, gongqi.name, to[1], player)
        end
      end
    end
  end,
})

-- 攻击范围为无限
gongqi:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    local card = data.card
    if not card or card.trueName ~= "slash" then return false end
    return player:getMark("@@gongqi_range") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.bypass_distances = true
  end,
})

-- 相同花色杀无次数限制
gongqi:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if player:getMark("@@gongqi_suit") > 0 and skill.trueName == "slash_skill" then
      if card and card.suit == player:getMark("@@gongqi_suit") then
        return 999
      end
    end
  end,
})

-- 回合结束清除标记
gongqi:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@gongqi_suit") > 0 or player:getMark("@@gongqi_range") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@gongqi_suit", 0)
    room:setPlayerMark(player, "@@gongqi_range", 0)
  end,
})

return gongqi
