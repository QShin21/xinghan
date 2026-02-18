-- SPDX-License-Identifier: GPL-3.0-or-later
-- 荀彧 - 驱虎技能
-- 出牌阶段限一次，你可以与一名体力值大于你的角色拼点：
-- 若你赢，你令该角色对其攻击范围内由你选择的另一名角色造成1点伤害；
-- 若你没赢，其对你造成1点伤害。

local quhu = fk.CreateSkill {
  name = "quhu",
}

Fk:loadTranslationTable {
  ["quhu"] = "驱虎",
  [":quhu"] = "出牌阶段限一次，你可以与一名体力值大于你的角色拼点："..
    "若你赢，你令该角色对其攻击范围内由你选择的另一名角色造成1点伤害；若你没赢，其对你造成1点伤害。",

  ["#quhu-choose"] = "驱虎：选择一名体力值大于你的角色进行拼点",
  ["#quhu-target"] = "驱虎：选择 %dest 攻击范围内的一名角色，令其受到1点伤害",

  ["$quhu1"] = "两虎相斗，旁观成败。",
  ["$quhu2"] = "驱兽相争，坐收渔利。",
}

quhu:addEffect("active", {
  mute = true,
  prompt = "#quhu-choose",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(quhu.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return player:prohibitDiscard(Fk:getCardById(to_select)) == false
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    if #selected_cards == 0 then return false end
    return to_select ~= player and to_select.hp > player.hp
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card = effect.cards[1]

    room:notifySkillInvoked(player, quhu.name, "offensive", {target})

    -- 拼点
    local pindian = room:pindian({player, target}, quhu.name)

    if pindian.results[player].winner then
      -- 玩家赢
      player:broadcastSkillInvoke(quhu.name, 1)

      -- 选择目标攻击范围内的一名角色
      local targets = table.filter(room:getOtherPlayers(target), function(p)
        return target:inMyAttackRange(p)
      end)

      if #targets > 0 then
        local victim = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = quhu.name,
          prompt = "#quhu-target::" .. target.id,
          cancelable = false,
        })[1]

        room:damage{
          from = target,
          to = victim,
          damage = 1,
          skillName = quhu.name,
        }
      end
    else
      -- 玩家输
      player:broadcastSkillInvoke(quhu.name, 2)
      room:damage{
        from = target,
        to = player,
        damage = 1,
        skillName = quhu.name,
      }
    end
  end,
})

return quhu
