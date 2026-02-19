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
  ["#gongqi-discard"] = "弓骑：是否弃置一名角色的一张牌？",
  ["@@gongqi_suit"] = "弓骑",

  ["$gongqi1"] = "弓骑射敌，百步穿杨！",
  ["$gongqi2"] = "弓马娴熟，百发百中！",
}

gongqi:addEffect("active", {
  mute = true,
  prompt = "#gongqi-use",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(gongqi.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return table.contains(player:getCardIds("he"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local card_id = effect.cards[1]
    local card = Fk:getCardById(card_id)

    room:notifySkillInvoked(player, gongqi.name, "offensive")
    player:broadcastSkillInvoke(gongqi.name)

    local is_equip = card.type == Card.TypeEquip
    local suit = card.suit

    room:throwCard(card_id, gongqi.name, player, player)

    -- 设置标记
    room:setPlayerMark(player, "@@gongqi_suit", suit)
    room:setPlayerMark(player, "@@gongqi_infinite", 1)

    -- 如果是装备牌，可以弃置其他角色一张牌
    if is_equip then
      local targets = table.filter(room.alive_players, function(p)
        return p ~= player and not p:isNude()
      end)
      
      if #targets > 0 then
        if room:askToSkillInvoke(player, {
          skill_name = gongqi.name,
          prompt = "#gongqi-discard",
        }) then
          local to = room:askToChoosePlayers(player, {
            min_num = 1,
            max_num = 1,
            targets = targets,
            skill_name = gongqi.name,
            prompt = "选择一名角色弃置其一张牌",
            cancelable = false,
          })[1]
          
          local id = room:askToChooseCard(player, {
            target = to,
            flag = "he",
            skill_name = gongqi.name,
          })
          room:throwCard(id, gongqi.name, to, player)
        end
      end
    end
  end,
})

-- 攻击范围无限
gongqi:addEffect("distance", {
  correct_func = function(self, from, to)
    if from:getMark("@@gongqi_infinite") > 0 then
      return 999
    end
    return 0
  end,
})

-- 杀无次数限制
gongqi:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if skill.trueName == "slash_skill" and player:getMark("@@gongqi_suit") == card.suit then
      return 999
    end
    return 0
  end,
})

-- 回合结束清除标记
gongqi:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@gongqi_suit") ~= 0 or player:getMark("@@gongqi_infinite") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@gongqi_suit", 0)
    room:setPlayerMark(player, "@@gongqi_infinite", 0)
  end,
})

return gongqi
