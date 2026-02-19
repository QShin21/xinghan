-- SPDX-License-Identifier: GPL-3.0-or-later
-- 马腾 - 雄异技能
-- 限定技，出牌阶段，你可以令与你势力相同的所有角色各摸三张牌，
-- 然后若你的体力值为场上唯一最小，你回复1点体力：
-- 当你脱离濒死状态时，本技能视为未发动过并删除回复体力的效果。

local xiongyi = fk.CreateSkill {
  name = "xh__xiongyi",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["xh__xiongyi"] = "雄异",
  [":xh__xiongyi"] = "限定技，出牌阶段，你可以令与你势力相同的所有角色各摸三张牌，"..
    "然后若你的体力值为场上唯一最小，你回复1点体力：当你脱离濒死状态时，本技能视为未发动过并删除回复体力的效果。",

  ["#xh__xiongyi-invoke"] = "雄异：令同势力角色各摸三张牌",

  ["$xh__xiongyi1"] = "雄异西凉，威震天下！",
  ["$xh__xiongyi2"] = "西凉铁骑，何人能挡！",
}

xiongyi:addEffect("active", {
  mute = true,
  prompt = "#xiongyi-invoke",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(xh__xiongyi.name) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, xh__xiongyi.name, "support")
    player:broadcastSkillInvoke(xh__xiongyi.name)

    local kingdom = player.kingdom

    -- 同势力角色各摸三张牌
    local same_kingdom = table.filter(room.alive_players, function(p)
      return p.kingdom == kingdom
    end)

    for _, p in ipairs(same_kingdom) do
      if not p.dead then
        p:drawCards(3, xh__xiongyi.name)
      end
    end

    -- 检查体力值是否为场上唯一最小
    if player.dead then return end

    local min_hp = player.hp
    local is_unique_min = true

    for _, p in ipairs(room.alive_players) do
      if p ~= player and p.hp < min_hp then
        is_unique_min = false
        break
      end
    end

    if is_unique_min and player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = xh__xiongyi.name,
      }
      room:setPlayerMark(player, "@@xiongyi_recover", 1)
    end

    -- 标记技能已发动
    room:setPlayerMark(player, "@@xiongyi_used", 1)
  end,
})

-- 脱离濒死状态时重置技能
xiongyi:addEffect(fk.AfterDying, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@xiongyi_used") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@xiongyi_used", 0)
    room:setPlayerMark(player, "@@xiongyi_recover", 0)
    player:setSkillUseHistory(xh__xiongyi.name, 0, Player.HistoryGame)
  end,
})

return xiongyi
