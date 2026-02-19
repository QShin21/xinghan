-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张绣 - 附敌技能
-- 当你受到伤害后，你可以交给伤害来源一张手牌，若如此做，
-- 你对与其势力相同的角色中体力值最大且大于等于你的一名角色造成1点伤害。

local fudi = fk.CreateSkill {
  name = "xh__fudi",
}

Fk:loadTranslationTable {
  ["xh__fudi"] = "附敌",
  [":xh__fudi"] = "当你受到伤害后，你可以交给伤害来源一张手牌，若如此做，"..
    "你对与其势力相同的角色中体力值最大且大于等于你的一名角色造成1点伤害。",

  ["#xh__fudi-invoke"] = "附敌：是否交给伤害来源一张手牌？",

  ["$xh__fudi1"] = "附敌之计，借刀杀人！",
  ["$xh__fudi2"] = "宛城张绣，附敌破敌！",
}

fudi:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(fudi.name) then return false end
    if not data.from or data.from:isDead() then return false end
    if player:isKongcheng() then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = fudi.name,
      prompt = "#xh__fudi-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local source = data.from
    
    -- 交给伤害来源一张手牌
    local id = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = fudi.name,
      pattern = ".",
      prompt = "选择一张手牌交给" .. source.name,
      cancelable = false,
    })
    
    room:moveCardTo(id, Player.Hand, source, fk.ReasonGive, fudi.name, nil, false, player.id)
    
    -- 找出同势力角色中体力值最大且大于等于你的
    local kingdom = source.kingdom
    local targets = table.filter(room.alive_players, function(p)
      return p.kingdom == kingdom and p.hp >= player.hp
    end)
    
    if #targets == 0 then return end
    
    -- 找出体力值最大的
    local max_hp = math.max(table.map(targets, function(p) return p.hp end))
    local max_targets = table.filter(targets, function(p)
      return p.hp == max_hp
    end)
    
    -- 随机选择一个
    local to = max_targets[math.random(1, #max_targets)]
    
    room:damage{
      from = player,
      to = to,
      damage = 1,
      skillName = fudi.name,
    }
  end,
})

return fudi
