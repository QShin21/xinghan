-- SPDX-License-Identifier: GPL-3.0-or-later
-- 梁兴 - 掳掠技能
-- 出牌阶段开始时，你可以选择一名有手牌且手牌数小于你的角色，然后其选择一项：
-- 1.交给你所有手牌，然后你结束此阶段；2.你视为对其使用一张造成伤害+1的【杀】。

local lulve = fk.CreateSkill {
  name = "lulve",
}

Fk:loadTranslationTable {
  ["lulve"] = "掳掠",
  [":lulve"] = "出牌阶段开始时，你可以选择一名有手牌且手牌数小于你的角色，然后其选择一项："..
    "1.交给你所有手牌，然后你结束此阶段；2.你视为对其使用一张造成伤害+1的【杀】。",

  ["#lulve-target"] = "掳掠：选择一名手牌数小于你的角色",
  ["lulve_give"] = "交给你所有手牌",
  ["lulve_slash"] = "你视为对其使用一张伤害+1的杀",

  ["$lulve1"] = "掳掠之威，势不可挡！",
  ["$lulve2"] = "西凉铁骑，掳掠天下！",
}

lulve:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(lulve.name) then return false end
    if player.phase ~= Player.Play then return false end
    if player:isKongcheng() then return false end
    
    -- 检查是否有手牌数小于你的角色
    local targets = table.filter(player.room.alive_players, function(p)
      return p ~= player and not p:isKongcheng() and p:getHandcardNum() < player:getHandcardNum()
    end)
    
    return #targets > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and not p:isKongcheng() and p:getHandcardNum() < player:getHandcardNum()
    end)
    
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = lulve.name,
      prompt = "#lulve-target",
      cancelable = true,
    })
    
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    
    local choice = room:askToChoice(to, {
      choices = {"lulve_give", "lulve_slash"},
      skill_name = lulve.name,
      prompt = "选择一项",
      detailed = false,
    })
    
    if choice == "lulve_give" then
      -- 交给你所有手牌
      local handcards = to:getCardIds("h")
      room:moveCardTo(handcards, Player.Hand, player, fk.ReasonGive, lulve.name, nil, false, to.id)
      
      -- 结束此阶段
      player.phase = Player.Finish
    else
      -- 视为使用伤害+1的杀
      local slash = Fk:cloneCard("slash")
      slash.skillName = lulve.name
      
      room:useCard{
        from = player.id,
        tos = {to.id},
        card = slash,
        extra_data = { lulve = true },
      }
    end
  end,
})

-- 伤害+1
lulve:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    return data.extra_data and data.extra_data.lulve
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

return lulve
