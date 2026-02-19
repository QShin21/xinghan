-- SPDX-License-Identifier: GPL-3.0-or-later
-- 魏延 - 狂骨技能
-- 当你对距离1以内的一名角色造成1点伤害后，若你与其的距离于其因受到此伤害而扣减体力前小于等于1，
-- 你可以回复1点体力或摸一张牌。

local kuanggu = fk.CreateSkill {
  name = "kuanggu",
}

Fk:loadTranslationTable {
  ["kuanggu"] = "狂骨",
  [":kuanggu"] = "当你对距离1以内的一名角色造成1点伤害后，若你与其的距离于其因受到此伤害而扣减体力前小于等于1，"..
    "你可以回复1点体力或摸一张牌。",

  ["#kuanggu-invoke"] = "狂骨：选择回复1点体力或摸一张牌",
  ["kuanggu_recover"] = "回复1点体力",
  ["kuanggu_draw"] = "摸一张牌",

  ["$kuanggu1"] = "狂骨噬血，战无不胜！",
  ["$kuanggu2"] = "谁敢挡我！",
}

kuanggu:addEffect(fk.Damage, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(kuanggu.name) then return false end
    if not data.to or data.damage ~= 1 then return false end
    
    -- 检查距离
    if player:distanceTo(data.to) > 1 then return false end
    
    return true
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local choices = {"kuanggu_draw"}
    if player:isWounded() then
      table.insert(choices, "kuanggu_recover")
    end
    
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = kuanggu.name,
      prompt = "#kuanggu-invoke",
      detailed = false,
    })
    
    event:setCostData(self, {choice = choice})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    
    if choice == "kuanggu_recover" then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = kuanggu.name,
      }
    else
      player:drawCards(1, kuanggu.name)
    end
  end,
})

return kuanggu
