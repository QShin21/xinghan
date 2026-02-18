-- SPDX-License-Identifier: GPL-3.0-or-later
-- 牛辅 - 宵袭技能
-- 锁定技，出牌阶段开始时，你失去1点体力或减1点体力上限，然后选择一项：
-- 1. 获得你攻击范围内的一名其他角色的一张牌；
-- 2. 视为对你攻击范围内的一名其他角色使用一张【杀】。

local xiaoxiong = fk.CreateSkill {
  name = "xiaoxiong",
}

Fk:loadTranslationTable {
  ["xiaoxiong"] = "宵袭",
  [":xiaoxiong"] = "锁定技，出牌阶段开始时，你失去1点体力或减1点体力上限，然后选择一项："..
    "1. 获得你攻击范围内的一名其他角色的一张牌；2. 视为对你攻击范围内的一名其他角色使用一张【杀】。",

  ["#xiaoxiong-choice1"] = "宵袭：选择失去体力或减体力上限",
  ["xiaoxiong_hp"] = "失去1点体力",
  ["xiaoxiong_maxhp"] = "减1点体力上限",
  ["#xiaoxiong-choice2"] = "宵袭：选择一项效果",
  ["xiaoxiong_get"] = "获得攻击范围内角色的一张牌",
  ["xiaoxiong_slash"] = "视为对攻击范围内角色使用一张【杀】",
  ["#xiaoxiong-target"] = "宵袭：选择攻击范围内的一名角色",

  ["$xiaoxiong1"] = "宵袭敌营，出其不意！",
  ["$xiaoxiong2"] = "夜袭敌寨，攻其不备！",
}

xiaoxiong:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiaoxiong.name) and
      player.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 选择失去体力或减体力上限
    local choices = {"xiaoxiong_hp", "xiaoxiong_maxhp"}
    local choice1 = room:askToChoice(player, {
      choices = choices,
      skill_name = xiaoxiong.name,
      prompt = "#xiaoxiong-choice1",
      detailed = false,
    })

    if choice1 == "xiaoxiong_hp" then
      room:loseHp(player, 1, xiaoxiong.name)
    else
      room:changeMaxHp(player, -1)
    end

    if player.dead then return end

    -- 获取攻击范围内的角色
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return player:inMyAttackRange(p)
    end)

    if #targets == 0 then return end

    -- 选择效果
    local choices2 = {"xiaoxiong_slash"}
    if table.find(targets, function(p) return not p:isNude() end) then
      table.insert(choices2, 1, "xiaoxiong_get")
    end

    local choice2 = room:askToChoice(player, {
      choices = choices2,
      skill_name = xiaoxiong.name,
      prompt = "#xiaoxiong-choice2",
      detailed = false,
    })

    -- 选择目标
    local available_targets = targets
    if choice2 == "xiaoxiong_get" then
      available_targets = table.filter(targets, function(p) return not p:isNude() end)
    end

    if #available_targets == 0 then return end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = available_targets,
      skill_name = xiaoxiong.name,
      prompt = "#xiaoxiong-target",
      cancelable = false,
    })[1]

    if choice2 == "xiaoxiong_get" then
      -- 获得一张牌
      local id = room:askToChooseCard(player, {
        target = to,
        flag = "he",
        skill_name = xiaoxiong.name,
      })
      room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, xiaoxiong.name, nil, false, to.id)
    else
      -- 视为使用杀
      local slash = Fk:cloneCard("slash")
      slash.skillName = xiaoxiong.name
      room:useCard{
        from = player.id,
        tos = {to.id},
        card = slash,
      }
    end
  end,
})

return xiaoxiong
