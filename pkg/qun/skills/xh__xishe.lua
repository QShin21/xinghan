-- SPDX-License-Identifier: GPL-3.0-or-later
-- 黄祖 - 袭射技能
-- 其他角色的准备阶段，你可以弃置你装备区里的一张牌，视为对其使用一张无距离限制的普通【杀】，
-- 若其体力值小于你，则此【杀】不能被响应，然后你可以重复此流程。

local xishe = fk.CreateSkill {
  name = "xh__xishe",
}

Fk:loadTranslationTable {
  ["xh__xishe"] = "袭射",
  [":xh__xishe"] = "其他角色的准备阶段，你可以弃置你装备区里的一张牌，视为对其使用一张无距离限制的普通【杀】，"..
    "若其体力值小于你，则此【杀】不能被响应，然后你可以重复此流程。",

  ["#xh__xishe-invoke"] = "袭射：是否弃置装备牌对其使用杀？",

  ["$xh__xishe1"] = "袭射之威，势不可挡！",
  ["$xh__xishe2"] = "江夏黄祖，射术无双！",
}

xishe:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player or not player:hasSkill(xishe.name) then return false end
    if target.phase ~= Player.Start then return false end
    
    -- 检查是否有装备牌
    return #player:getCardIds("e") > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xishe.name,
      prompt = "#xh__xishe-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    while #player:getCardIds("e") > 0 do
      -- 选择弃置装备牌
      local id = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = xishe.name,
        pattern = ".|.|.|equip",
        prompt = "选择一张装备牌弃置",
        cancelable = false,
      })
      
      room:throwCard(id, xishe.name, player, player)
      
      -- 使用杀
      local slash = Fk:cloneCard("slash")
      slash.skillName = xishe.name
      
      local extra_data = {}
      if target.hp < player.hp then
        extra_data.disresponsive = true
      end
      
      room:useCard{
        from = player.id,
        tos = {target.id},
        card = slash,
        extra_data = extra_data,
      }
      
      -- 询问是否继续
      if #player:getCardIds("e") > 0 then
        if not room:askToSkillInvoke(player, {
          skill_name = xishe.name,
          prompt = "#xh__xishe-invoke",
        }) then
          break
        end
      else
        break
      end
    end
  end,
})

return xishe
