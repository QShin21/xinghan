-- SPDX-License-Identifier: GPL-3.0-or-later
-- 徐荣 - 凶镬技能
-- 每局游戏限三次，出牌阶段限一次，你可以选择一名角色，
-- 令其本回合下次受到的伤害+1，且其下个出牌阶段开始时进行判定...

local xionghuo = fk.CreateSkill {
  name = "xh__xionghuo",
}

Fk:loadTranslationTable {
  ["xh__xionghuo"] = "凶镬",
  [":xh__xionghuo"] = "每局游戏限三次，出牌阶段限一次，你可以选择一名角色，"..
    "令其本回合下次受到的伤害+1，且其下个出牌阶段开始时进行判定，若结果为："..
    "♢，你对其造成1点火焰伤害且其本回合不能对你使用【杀】；"..
    "♡，其失去1点体力且其本回合手牌上限-1；"..
    "♤或♧，你获得其装备区和手牌区里的各一张牌。",

  ["#xh__xionghuo-target"] = "凶镬：选择一名角色",
  ["@@xh__xionghuo_damage"] = "凶镬",
  ["@@xh__xionghuo_judge"] = "凶镬判定",

  ["$xh__xionghuo1"] = "凶镬之威，谁敢争锋！",
  ["$xh__xionghuo2"] = "镬烹之刑，威震天下！",
}

xionghuo:addEffect("active", {
  mute = true,
  prompt = "#xh__xionghuo-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xionghuo.name, Player.HistoryPhase) == 0 and
      player:usedSkillTimes(xionghuo.name, Player.HistoryGame) < 3
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return true
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, xionghuo.name, "offensive", {target})
    player:broadcastSkillInvoke(xionghuo.name)

    -- 令其下次受到伤害+1
    room:addPlayerMark(target, "@@xionghuo_damage", 1)
    
    -- 标记下个出牌阶段判定
    room:addPlayerMark(target, "@@xionghuo_judge", player.id)
  end,
})

-- 伤害+1
xionghuo:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@xionghuo_damage") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
    player.room:setPlayerMark(player, "@@xionghuo_damage", 0)
  end,
})

-- 出牌阶段开始时判定
xionghuo:addEffect(fk.EventPhaseStart, {
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
    
    room:setPlayerMark(player, "@@xionghuo_judge", 0)
    
    local judge = room:judge{
      who = player,
      reason = xionghuo.name,
    }
    
    local suit = judge.card.suit
    
    if suit == Card.Diamond then
      -- 造成1点火焰伤害且本回合不能对source使用杀
      room:damage{
        from = source,
        to = player,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = xionghuo.name,
      }
      room:addPlayerMark(player, "@@xionghuo_no_slash", source.id)
    elseif suit == Card.Heart then
      -- 失去1点体力且本回合手牌上限-1
      room:loseHp(player, 1, xionghuo.name)
      room:addPlayerMark(player, "@@xionghuo_hand_limit", -1)
    else
      -- 获得装备区和手牌区各一张牌
      if source then
        local equip_cards = player:getCardIds("e")
        local hand_cards = player:getCardIds("h")
        
        if #equip_cards > 0 then
          local id = room:askToChooseCard(source, {
            target = player,
            flag = "e",
            skill_name = xionghuo.name,
          })
          room:moveCardTo(id, Player.Hand, source, fk.ReasonPrey, xionghuo.name)
        end
        
        if #hand_cards > 0 then
          local id = room:askToChooseCard(source, {
            target = player,
            flag = "h",
            skill_name = xionghuo.name,
          })
          room:moveCardTo(id, Player.Hand, source, fk.ReasonPrey, xionghuo.name)
        end
      end
    end
  end,
})

return xionghuo
