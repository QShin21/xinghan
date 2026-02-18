-- SPDX-License-Identifier: GPL-3.0-or-later
-- 韩当 - 解烦技能
-- 限定技，出牌阶段，你可以选择一名角色，然后攻击范围内含有其的所有角色依次选择一项：
-- 1. 弃置一张武器牌；2. 令其摸一张牌。
-- 若当前轮数为1，此回合结束时，本技能视为未发动过。

local jiefan = fk.CreateSkill {
  name = "jiefan",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["jiefan"] = "解烦",
  [":jiefan"] = "限定技，出牌阶段，你可以选择一名角色，然后攻击范围内含有其的所有角色依次选择一项："..
    "1. 弃置一张武器牌；2. 令其摸一张牌。若当前轮数为1，此回合结束时，本技能视为未发动过。",

  ["#jiefan-choose"] = "解烦：选择一名角色",
  ["#jiefan-choice"] = "解烦：请选择一项",
  ["jiefan_choice1"] = "弃置一张武器牌",
  ["jiefan_choice2"] = "令其摸一张牌",

  ["$jiefan1"] = "休想伤我主公！",
  ["$jiefan2"] = "解烦之计，速速行事！",
}

jiefan:addEffect("active", {
  mute = true,
  prompt = "#jiefan-choose",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(jiefan.name) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, jiefan.name, "support", {target})
    player:broadcastSkillInvoke(jiefan.name)

    -- 获取攻击范围内含有目标的所有角色
    local attackers = table.filter(room.alive_players, function(p)
      return p:inMyAttackRange(target)
    end)

    -- 每个角色依次选择
    for _, p in ipairs(attackers) do
      if not p.dead then
        local has_weapon = table.find(p:getCardIds("he"), function(id)
          local card = Fk:getCardById(id)
          return card.type == Card.TypeEquip and card.sub_type == Card.SubtypeWeapon
        end)

        local choices = {"jiefan_choice2"}  -- 默认可以令其摸牌
        if has_weapon then
          table.insert(choices, 1, "jiefan_choice1")
        end

        local choice = room:askToChoice(p, {
          choices = choices,
          skill_name = jiefan.name,
          prompt = "#jiefan-choice",
          detailed = false,
        })

        if choice == "jiefan_choice1" then
          -- 弃置一张武器牌
          local weapon_cards = table.filter(p:getCardIds("he"), function(id)
            local card = Fk:getCardById(id)
            return card.type == Card.TypeEquip and card.sub_type == Card.SubtypeWeapon
          end)

          if #weapon_cards > 0 then
            local id = room:askToChooseCard(p, {
              target = p,
              flag = "he",
              skill_name = jiefan.name,
            })
            room:throwCard(id, jiefan.name, p, p)
          end
        else
          -- 令其摸一张牌
          if not target.dead then
            target:drawCards(1, jiefan.name)
          end
        end
      end
    end

    -- 若当前轮数为1，标记回合结束时重置
    if room.logic:getRoundNum() == 1 then
      room:setPlayerMark(player, "@@jiefan_reset", 1)
    end
  end,
})

-- 回合结束时重置
jiefan:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@jiefan_reset") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@jiefan_reset", 0)
    -- 重置技能使用次数
    player:setSkillUseHistory(jiefan.name, 0, Player.HistoryGame)
  end,
})

return jiefan
