-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张鲁 - 米道技能
-- 当一张判定牌生效前，你可以用一张"米"代替之。

local midao = fk.CreateSkill {
  name = "midao",
}

Fk:loadTranslationTable {
  ["midao"] = "米道",
  [":midao"] = "当一张判定牌生效前，你可以用一张\"米\"代替之。",

  ["#midao-invoke"] = "米道：是否用一张米代替判定牌？",

  ["$midao1"] = "米道之术，五斗米道！",
  ["$midao2"] = "张鲁米道，汉中太平！",
}

midao:addEffect(fk.AskForRetarget, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(midao.name) then return false end
    
    local sheng = player:getMark("@@jutu_sheng")
    return sheng and type(sheng) == "table" and #sheng > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = midao.name,
      prompt = "#midao-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local sheng = player:getMark("@@jutu_sheng")
    
    if #sheng > 0 then
      local id = table.remove(sheng, 1)
      room:setPlayerMark(player, "@@jutu_sheng", sheng)
      
      -- 用米代替判定牌
      -- 简化实现：需要更复杂的逻辑来处理判定牌替换
    end
  end,
})

return midao
