-- SPDX-License-Identifier: GPL-3.0-or-later
-- 韩当 - 解烦技能
-- 限定技，出牌阶段，你可以选择一名角色，然后攻击范围内含有其的所有角色依次选择一项：
-- 1.弃置一张武器牌；2.令其摸一张牌。若当前轮数为1，此回合结束时，本技能视为未发动过。

local jiefan = fk.CreateSkill {
  name = "xh__jiefan",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["xh__jiefan"] = "解烦",
  [":xh__jiefan"] = "限定技，出牌阶段，你可以选择一名角色，然后攻击范围内含有其的所有角色依次选择一项："..
    "1.弃置一张武器牌；2.令其摸一张牌。若当前轮数为1，此回合结束时，本技能视为未发动过。",

  ["#xh__jiefan-target"] = "解烦：选择一名角色",
  ["jiefan_discard"] = "弃置一张武器牌",
  ["jiefan_draw"] = "令其摸一张牌",

  ["$xh__jiefan1"] = "解烦救急，义不容辞！",
  ["$xh__jiefan2"] = "江东猛将，解烦救困！",
}

jiefan:addEffect("active", {
  mute = true,
  prompt = "#xh__jiefan-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(jiefan.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return true
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, jiefan.name, "support", {target})
    player:broadcastSkillInvoke(jiefan.name)

    -- 找出攻击范围内含有目标的所有角色
    local attackers = table.filter(room.alive_players, function(p)
      return p:distanceTo(target) <= p:getAttackRange()
    end)

    for _, attacker in ipairs(attackers) do
      if attacker.dead then goto continue end
      
      -- 检查是否有武器牌
      local has_weapon = table.find(attacker:getCardIds("he"), function(id)
        return Fk:getCardById(id).sub_type == Card.SubtypeWeapon
      end)
      
      local choice
      if has_weapon then
        choice = room:askToChoice(attacker, {
          choices = {"jiefan_discard", "jiefan_draw"},
          skill_name = jiefan.name,
          prompt = "选择一项",
          detailed = false,
        })
      else
        choice = "jiefan_draw"
      end
      
      if choice == "jiefan_discard" then
        local weapon_cards = table.filter(attacker:getCardIds("he"), function(id)
          return Fk:getCardById(id).sub_type == Card.SubtypeWeapon
        end)
        local id = room:askToCards(attacker, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = jiefan.name,
          pattern = tostring(Exppattern{ id = weapon_cards }),
          prompt = "选择一张武器牌弃置",
          cancelable = false,
        })
        room:throwCard(id, jiefan.name, attacker, player)
      else
        target:drawCards(1, jiefan.name)
      end
      
      ::continue::
    end

    -- 如果当前轮数为1，标记回合结束时重置
    local round = room:getBanner("round_count") or 1
    if round == 1 then
      room:setPlayerMark(player, "@@jiefan_reset", 1)
    end
  end,
})

-- 回合结束重置
jiefan:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@jiefan_reset") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@jiefan_reset", 0)
    player:setSkillUseHistory(jiefan.name, 0, Player.HistoryGame)
  end,
})

return jiefan
