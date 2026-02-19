-- SPDX-License-Identifier: GPL-3.0-or-later
-- 牛辅 - 宵袭技能
-- 锁定技，出牌阶段开始时，你失去1点体力或减1点体力上限，然后选择一项：
-- 1.获得你攻击范围内的一名其他角色的一张牌；2.视为对你攻击范围内的一名其他角色使用一张【杀】。

local xiaoxiong = fk.CreateSkill {
  name = "xiaoxiong",
}

Fk:loadTranslationTable {
  ["xiaoxiong"] = "宵袭",
  [":xiaoxiong"] = "锁定技，出牌阶段开始时，你失去1点体力或减1点体力上限，然后选择一项："..
    "1.获得你攻击范围内的一名其他角色的一张牌；2.视为对你攻击范围内的一名其他角色使用一张【杀】。",

  ["xiaoxiong_losehp"] = "失去1点体力",
  ["xiaoxiong_losemaxhp"] = "减1点体力上限",
  ["xiaoxiong_get"] = "获得一张牌",
  ["xiaoxiong_slash"] = "使用一张杀",

  ["$xiaoxiong1"] = "宵袭敌营，出其不意！",
  ["$xiaoxiong2"] = "夜袭之计，攻其不备！",
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
    
    -- 选择代价
    local choice = room:askToChoice(player, {
      choices = {"xiaoxiong_losehp", "xiaoxiong_losemaxhp"},
      skill_name = xiaoxiong.name,
      prompt = "选择代价",
      detailed = false,
    })
    
    if choice == "xiaoxiong_losehp" then
      room:loseHp(player, 1, xiaoxiong.name)
    else
      room:changeMaxHp(player, -1)
    end
    
    -- 找出攻击范围内的角色
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and player:distanceTo(p) <= player:getAttackRange()
    end)
    
    if #targets == 0 then return end
    
    -- 选择效果
    local effect = room:askToChoice(player, {
      choices = {"xiaoxiong_get", "xiaoxiong_slash"},
      skill_name = xiaoxiong.name,
      prompt = "选择效果",
      detailed = false,
    })
    
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = xiaoxiong.name,
      prompt = "选择目标",
      cancelable = false,
    })[1]
    
    if effect == "xiaoxiong_get" then
      -- 获得一张牌
      if not to:isNude() then
        local id = room:askToChooseCard(player, {
          target = to,
          flag = "he",
          skill_name = xiaoxiong.name,
        })
        room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, xiaoxiong.name)
      end
    else
      -- 使用杀
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
