-- SPDX-License-Identifier: GPL-3.0-or-later
-- 徐荣 - 凶镬技能
-- 每局游戏限三次，出牌阶段限一次，你可以选择一名角色，令其本回合下次受到的伤害+1，
-- 且其下个出牌阶段开始时进行判定，若结果为：
-- ♢，你对其造成1点火焰伤害且其本回合不能对你使用【杀】；
-- ♡，其失去1点体力且其本回合手牌上限-1；
-- ♤或♧，你获得其装备区和手牌区里的各一张牌。

local xionghuo = fk.CreateSkill {
  name = "xionghuo",
}

Fk:loadTranslationTable {
  ["xionghuo"] = "凶镬",
  [":xionghuo"] = "每局游戏限三次，出牌阶段限一次，你可以选择一名角色，令其本回合下次受到的伤害+1，"..
    "且其下个出牌阶段开始时进行判定，若结果为：♢，你对其造成1点火焰伤害且其本回合不能对你使用【杀】；"..
    "♡，其失去1点体力且其本回合手牌上限-1；♤或♧，你获得其装备区和手牌区里的各一张牌。",

  ["#xionghuo-choose"] = "凶镬：选择一名角色",
  ["@@xionghuo_damage"] = "凶镬",
  ["@@xionghuo_judge"] = "凶镬判定",

  ["$xionghuo1"] = "凶镬加身，在劫难逃！",
  ["$xionghuo2"] = "镬汤地狱，等你来尝！",
}

xionghuo:addEffect("active", {
  mute = true,
  prompt = "#xionghuo-choose",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xionghuo.name, Player.HistoryPhase) == 0 and
      player:usedSkillTimes(xionghuo.name, Player.HistoryGame) < 3
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, xionghuo.name, "offensive", {target})
    player:broadcastSkillInvoke(xionghuo.name)

    -- 令其本回合下次受到的伤害+1
    room:addPlayerMark(target, "@@xionghuo_damage", 1)

    -- 标记下个出牌阶段进行判定
    room:addPlayerMark(target, "@@xionghuo_judge", player.id)
  end,
})

-- 伤害+1
xionghuo:addEffect(fk.DamageInflicted, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@xionghuo_damage") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + player:getMark("@@xionghuo_damage")
    player.room:setPlayerMark(player, "@@xionghuo_damage", 0)
  end,
})

-- 下个出牌阶段开始时判定
xionghuo:addEffect(fk.EventPhaseStart, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and
      player:getMark("@@xionghuo_judge") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local source_id = player:getMark("@@xionghuo_judge")
    local source = room:getPlayerById(source_id)

    if not source then return end

    -- 进行判定
    local judge = {
      who = player,
      reason = xionghuo.name,
      pattern = ".",
    }
    room:judge(judge)

    local card = Fk:getCardById(judge.card.id)

    -- 清除标记
    room:setPlayerMark(player, "@@xionghuo_judge", 0)

    if card.suit == Card.Diamond then
      -- ♢：造成1点火焰伤害，不能对你使用杀
      room:damage{
        from = source,
        to = player,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = xionghuo.name,
      }
      room:setPlayerMark(player, "@@xionghuo_no_slash", source.id)

    elseif card.suit == Card.Heart then
      -- ♡：失去1点体力，手牌上限-1
      room:loseHp(player, 1, xionghuo.name)
      room:addPlayerMark(player, "@@xionghuo_hand_limit", 1)

    else
      -- ♤或♧：获得装备区和手牌区里的各一张牌
      local equip_cards = player:getCardIds("e")
      local hand_cards = player:getCardIds("h")

      if #equip_cards > 0 then
        local id = room:askToChooseCard(source, {
          target = player,
          flag = "e",
          skill_name = xionghuo.name,
        })
        room:moveCardTo(id, Player.Hand, source, fk.ReasonPrey, xionghuo.name, nil, false, player.id)
      end

      if #hand_cards > 0 and not player.dead then
        hand_cards = player:getCardIds("h")
        if #hand_cards > 0 then
          local id = room:askToChooseCard(source, {
            target = player,
            flag = "h",
            skill_name = xionghuo.name,
          })
          room:moveCardTo(id, Player.Hand, source, fk.ReasonPrey, xionghuo.name, nil, false, player.id)
        end
      end
    end
  end,
})

-- 不能对来源使用杀
xionghuo:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    local no_slash = player:getMark("@@xionghuo_no_slash")
    if no_slash == 0 then return false end

    local card = data.card
    if not card or card.trueName ~= "slash" then return false end

    -- 检查目标是否包含来源
    local tos = data.tos
    return table.contains(tos, no_slash)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.cancel = true
  end,
})

-- 手牌上限-1
xionghuo:addEffect(fk.MaxCardsCalc, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@xionghuo_hand_limit") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.num = data.num - player:getMark("@@xionghuo_hand_limit")
  end,
})

-- 回合结束清除标记
xionghuo:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@xionghuo_no_slash") ~= 0 or
           player:getMark("@@xionghuo_hand_limit") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@xionghuo_no_slash", 0)
    room:setPlayerMark(player, "@@xionghuo_hand_limit", 0)
  end,
})

return xionghuo
