-- SPDX-License-Identifier: GPL-3.0-or-later
-- 杨彪 - 义争技能
-- 出牌阶段限一次，你可以与一名手牌数大于你的角色拼点：
-- 若你赢，其跳过下个摸牌阶段；若你没赢，其可以对你造成至多2点伤害。

local yizheng = fk.CreateSkill {
  name = "xh__yizheng",
}

Fk:loadTranslationTable {
  ["xh__yizheng"] = "义争",
  [":xh__yizheng"] = "出牌阶段限一次，你可以与一名手牌数大于你的角色拼点："..
    "若你赢，其跳过下个摸牌阶段；若你没赢，其可以对你造成至多2点伤害。",

  ["#xh__yizheng-target"] = "义争：选择一名手牌数大于你的角色",
  ["#xh__yizheng-damage"] = "义争：是否对杨彪造成伤害？",

  ["$xh__yizheng1"] = "义争之志，不屈不挠！",
  ["$xh__yizheng2"] = "杨彪义争，汉室忠臣！",
}

yizheng:addEffect("active", {
  mute = true,
  prompt = "#yizheng-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xh__yizheng.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player and to_select:getHandcardNum() > player:getHandcardNum() and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, xh__yizheng.name, "control", {target})
    player:broadcastSkillInvoke(xh__yizheng.name)

    local pindian = room:pindian({player, target}, xh__yizheng.name)
    
    if pindian.results[player].winner then
      -- 你赢：跳过下个摸牌阶段
      room:setPlayerMark(target, "@@yizheng_skip", 1)
    else
      -- 你没赢：可以对你造成至多2点伤害
      if target:isAlive() then
        local damage = room:askToChoice(target, {
          choices = {"0", "1", "2"},
          skill_name = xh__yizheng.name,
          prompt = "#yizheng-damage",
          detailed = false,
        })
        
        local num = tonumber(damage)
        if num > 0 then
          room:damage{
            from = target,
            to = player,
            damage = num,
            skillName = xh__yizheng.name,
          }
        end
      end
    end
  end,
})

-- 跳过摸牌阶段
yizheng:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if player.phase ~= Player.Draw then return false end
    return player:getMark("@@yizheng_skip") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@yizheng_skip", 0)
    player:skip(Player.Draw)
  end,
})

return yizheng
