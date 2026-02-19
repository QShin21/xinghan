-- SPDX-License-Identifier: GPL-3.0-or-later
-- 鲍信 - 毅谋技能
-- 当与你距离1以内的角色受到伤害后，你可以选择一项：
-- 1.令其摸一张牌；2.令其将一张手牌交给另一名角色，然后其摸一张牌。

local yimou = fk.CreateSkill {
  name = "xh__yimou",
}

Fk:loadTranslationTable {
  ["xh__yimou"] = "毅谋",
  [":xh__yimou"] = "当与你距离1以内的角色受到伤害后，你可以选择一项："..
    "1.令其摸一张牌；2.令其将一张手牌交给另一名角色，然后其摸一张牌。",

  ["#xh__yimou-invoke"] = "毅谋：选择一项效果",
  ["yimou_draw"] = "令其摸一张牌",
  ["yimou_give"] = "令其将一张手牌交给另一名角色，然后其摸一张牌",

  ["$xh__yimou1"] = "毅谋兼备，智勇双全！",
  ["$xh__yimou2"] = "坚毅果敢，谋定后动！",
}

yimou:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(yimou.name) then return false end
    if player:distanceTo(target) > 1 then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local choices = {"yimou_draw"}
    if not target:isKongcheng() then
      table.insert(choices, "yimou_give")
    end
    
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = yimou.name,
      prompt = "#xh__yimou-invoke",
      detailed = false,
    })
    
    event:setCostData(self, {choice = choice})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    
    if choice == "yimou_draw" then
      target:drawCards(1, yimou.name)
    else
      -- 选择一张手牌交给另一名角色
      local others = table.filter(room.alive_players, function(p)
        return p ~= target
      end)
      
      if #others > 0 then
        local card_id = room:askToCards(target, {
          min_num = 1,
          max_num = 1,
          include_equip = false,
          skill_name = yimou.name,
          pattern = ".",
          prompt = "选择一张手牌交给另一名角色",
          cancelable = false,
        })
        
        local to = room:askToChoosePlayers(target, {
          min_num = 1,
          max_num = 1,
          targets = others,
          skill_name = yimou.name,
          prompt = "选择一名角色获得此牌",
          cancelable = false,
        })[1]
        
        room:moveCardTo(card_id[1], Player.Hand, to, fk.ReasonGive, yimou.name, nil, false, target.id)
        target:drawCards(1, yimou.name)
      end
    end
  end,
})

return yimou
