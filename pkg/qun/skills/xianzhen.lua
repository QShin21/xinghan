-- SPDX-License-Identifier: GPL-3.0-or-later
-- 高顺 - 陷阵技能
-- 每回合限一次，出牌阶段，你可以与一名角色拼点：
-- 若你赢，本回合你无视其防具，对其使用牌无距离和次数限制，对其使用每种牌名的牌第一次造成伤害时伤害+1；
-- 若你没赢，本回合你不能再使用【杀】，本回合的弃牌阶段开始时，你可以展示任意张【杀】，令这些牌此阶段不计入手牌上限。

local xianzhen = fk.CreateSkill {
  name = "xianzhen",
}

Fk:loadTranslationTable {
  ["xianzhen"] = "陷阵",
  [":xianzhen"] = "每回合限一次，出牌阶段，你可以与一名角色拼点："..
    "若你赢，本回合你无视其防具，对其使用牌无距离和次数限制，对其使用每种牌名的牌第一次造成伤害时伤害+1；"..
    "若你没赢，本回合你不能再使用【杀】，本回合的弃牌阶段开始时，你可以展示任意张【杀】，令这些牌此阶段不计入手牌上限。",

  ["#xianzhen-choose"] = "陷阵：选择一名角色进行拼点",
  ["@@xianzhen_target"] = "陷阵目标",
  ["@@xianzhen_no_slash"] = "陷阵禁杀",
  ["#xianzhen-show"] = "陷阵：展示任意张【杀】，令其不计入手牌上限",

  ["$xianzhen1"] = "陷阵之志，有死无生！",
  ["$xianzhen2"] = "攻无不克，战无不胜！",
}

xianzhen:addEffect("active", {
  mute = true,
  prompt = "#xianzhen-choose",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xianzhen.name, Player.HistoryTurn) == 0 and
      not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return player:prohibitDiscard(Fk:getCardById(to_select)) == false
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    if #selected_cards == 0 then return false end
    return to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, xianzhen.name, "offensive", {target})
    player:broadcastSkillInvoke(xianzhen.name)

    -- 拼点
    local pindian = room:pindian({player, target}, xianzhen.name)

    if pindian.results[player].winner then
      -- 赢了：设置标记
      room:setPlayerMark(player, "@@xianzhen_target", target.id)
    else
      -- 输了：不能使用杀
      room:setPlayerMark(player, "@@xianzhen_no_slash", 1)
    end
  end,
})

-- 不能使用杀
xianzhen:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    return player:getMark("@@xianzhen_no_slash") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.cancel = true
  end,
})

-- 弃牌阶段展示杀
xianzhen:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xianzhen.name) and
      player.phase == Player.Discard and player:getMark("@@xianzhen_no_slash") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local slashes = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).trueName == "slash"
    end)

    if #slashes == 0 then return false end

    local cards = room:askToCards(player, {
      min_num = 0,
      max_num = #slashes,
      include_equip = false,
      skill_name = xianzhen.name,
      pattern = tostring(Exppattern{ id = slashes }),
      prompt = "#xianzhen-show",
      cancelable = true,
    })

    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards

    room:showCards(player, cards, xianzhen.name)

    -- 设置不计入手牌上限
    room:setPlayerMark(player, "@@xianzhen_slashes", cards)
  end,
})

-- 不计入手牌上限
xianzhen:addEffect(fk.MaxCardsCalc, {
  can_refresh = function(self, event, target, player, data)
    local slashes = player:getMark("@@xianzhen_slashes")
    return slashes and #slashes > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local slashes = player:getMark("@@xianzhen_slashes")
    local count = 0
    for _, id in ipairs(slashes) do
      if table.contains(player:getCardIds("h"), id) then
        count = count + 1
      end
    end
    data.num = data.num + count
  end,
})

-- 回合结束清除标记
xianzhen:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@xianzhen_target") ~= 0 or
           player:getMark("@@xianzhen_no_slash") ~= 0 or
           player:getMark("@@xianzhen_slashes") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@xianzhen_target", 0)
    room:setPlayerMark(player, "@@xianzhen_no_slash", 0)
    room:setPlayerMark(player, "@@xianzhen_slashes", 0)
  end,
})

return xianzhen
