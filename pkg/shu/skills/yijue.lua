-- SPDX-License-Identifier: GPL-3.0-or-later
-- 关羽 - 义绝技能
-- 出牌阶段限一次，你可以弃置一张牌，然后令一名其他角色展示一张手牌，若此牌为：
-- 黑色，则直到回合结束，其不能使用或打出手牌且所有非锁定技失效、你使用【杀】对其造成伤害时此伤害+1；
-- 红色，则你获得此牌，然后你可以令其回复1点体力。

local yijue = fk.CreateSkill {
  name = "yijue",
}

Fk:loadTranslationTable {
  ["yijue"] = "义绝",
  [":yijue"] = "出牌阶段限一次，你可以弃置一张牌，然后令一名其他角色展示一张手牌，若此牌为："..
    "黑色，则直到回合结束，其不能使用或打出手牌且所有非锁定技失效、你使用【杀】对其造成伤害时此伤害+1；"..
    "红色，则你获得此牌，然后你可以令其回复1点体力。",

  ["#yijue-choose"] = "义绝：弃置一张牌，令一名角色展示手牌",
  ["#yijue-show"] = "义绝：请展示一张手牌",
  ["#yijue-recover"] = "义绝：是否令 %dest 回复1点体力？",
  ["@@yijue_black"] = "义绝",

  ["$yijue1"] = "关某之志，在于忠义！",
  ["$yijue2"] = "义之所至，生死相随！",
}

yijue:addEffect("active", {
  mute = true,
  prompt = "#yijue-choose",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(yijue.name, Player.HistoryPhase) == 0
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
    local card = effect.cards[1]

    room:notifySkillInvoked(player, yijue.name, "offensive", {target})

    -- 弃置牌
    room:throwCard(card, yijue.name, player, player)

    if target.dead or target:isKongcheng() then return end

    -- 令目标展示一张手牌
    local shown_card = room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = yijue.name,
      pattern = ".",
      prompt = "#yijue-show",
      cancelable = false,
    })[1]

    local shown = Fk:getCardById(shown_card)
    room:showCards(target, {shown_card}, yijue.name)

    if shown.color == Card.Black then
      -- 黑色：不能使用或打出手牌，非锁定技失效，杀伤害+1
      room:setPlayerMark(target, "@@yijue_black", player.id)
      room:setPlayerMark(target, "@@yijue_damage", 1)

      -- 非锁定技失效
      room:handleAddLoseSkills(target, "-yijue_disable", nil, false, true)
    else
      -- 红色：获得此牌，可选择回复体力
      room:moveCardTo(shown_card, Player.Hand, player, fk.ReasonPrey, yijue.name)

      if target:isWounded() then
        local choice = room:askToSkillInvoke(player, {
          skill_name = yijue.name,
          prompt = "#yijue-recover::" .. target.id,
        })

        if choice then
          room:recover{
            who = target,
            num = 1,
            recoverBy = player,
            skillName = yijue.name,
          }
        end
      end
    end
  end,
})

-- 杀伤害+1
yijue:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    local card = data.card
    if not card or card.trueName ~= "slash" then return false end

    local to = data.to
    return to:getMark("@@yijue_damage") > 0 and to:getMark("@@yijue_black") == player.id
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

-- 回合结束清除标记
yijue:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@yijue_black") ~= 0 or player:getMark("@@yijue_damage") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@yijue_black", 0)
    room:setPlayerMark(player, "@@yijue_damage", 0)
    room:handleAddLoseSkills(player, "yijue_disable", nil, false, true)
  end,
})

return yijue
