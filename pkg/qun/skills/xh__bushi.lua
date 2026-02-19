-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张鲁 - 布施技能
-- 当你受到1点伤害后你可以获得一张"米"。当你对其他角色造成1点伤害后，其可以获得一张"米"。

local bushi = fk.CreateSkill {
  name = "xh__bushi",
}

Fk:loadTranslationTable {
  ["xh__bushi"] = "布施",
  [":xh__bushi"] = "当你受到1点伤害后你可以获得一张\"米\"。当你对其他角色造成1点伤害后，其可以获得一张\"米\"。",

  ["#xh__bushi-get"] = "布施：是否获得一张米？",
  ["#xh__bushi-give"] = "布施：是否令其获得一张米？",

  ["$xh__bushi1"] = "布施众生，五斗米道！",
  ["$xh__bushi2"] = "张鲁布施，汉中太平！",
}

-- 受到伤害后获得米
bushi:addEffect(fk.Damaged, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(bushi.name) then return false end
    
    local mi = player:getMark("@@yishe_mi")
    return mi and type(mi) == "table" and #mi > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = bushi.name,
      prompt = "#xh__bushi-get",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mi = player:getMark("@@yishe_mi")
    
    if mi and #mi > 0 then
      local id = table.remove(mi, 1)
      room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, bushi.name)
      room:setPlayerMark(player, "@@yishe_mi", mi)
      
      -- 如果是最后一张米，回复体力
      if #mi == 0 then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = "yishe",
        }
      end
    end
  end,
})

-- 造成伤害后给米
bushi:addEffect(fk.Damage, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(bushi.name) then return false end
    if not data.to or data.to == player then return false end
    
    local mi = player:getMark("@@yishe_mi")
    return mi and type(mi) == "table" and #mi > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = bushi.name,
      prompt = "#xh__bushi-give",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local mi = player:getMark("@@yishe_mi")
    
    if mi and #mi > 0 then
      local id = table.remove(mi, 1)
      room:moveCardTo(id, Player.Hand, to, fk.ReasonGive, bushi.name, nil, false, player.id)
      room:setPlayerMark(player, "@@yishe_mi", mi)
      
      -- 如果是最后一张米，回复体力
      if #mi == 0 then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = "yishe",
        }
      end
    end
  end,
})

return bushi
