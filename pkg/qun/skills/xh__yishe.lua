-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张鲁 - 义舍技能
-- 结束阶段，若你没有"米"，你可以摸两张牌，然后将两张牌置于武将牌上，称为"米"；
-- 当你移去最后一张"米"时，你回复1点体力。

local yishe = fk.CreateSkill {
  name = "xh__yishe",
}

Fk:loadTranslationTable {
  ["xh__yishe"] = "义舍",
  [":xh__yishe"] = "结束阶段，若你没有\"米\"，你可以摸两张牌，然后将两张牌置于武将牌上，称为\"米\"；"..
    "当你移去最后一张\"米\"时，你回复1点体力。",

  ["#xh__yishe-invoke"] = "义舍：是否摸两张牌并置米？",
  ["#xh__yishe-place"] = "义舍：选择两张牌置为米",
  ["@@xh__yishe_mi"] = "米",

  ["$xh__yishe1"] = "义舍布施，五斗米道！",
  ["$xh__yishe2"] = "张鲁义舍，汉中太平！",
}

yishe:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(yishe.name) then return false end
    if player.phase ~= Player.Finish then return false end
    
    -- 检查是否有米
    local mi = player:getMark("@@yishe_mi")
    return not mi or #mi == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yishe.name,
      prompt = "#xh__yishe-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 摸两张牌
    player:drawCards(2, yishe.name)
    
    -- 选择两张牌置为米
    local cards = room:askToCards(player, {
      min_num = 2,
      max_num = 2,
      include_equip = false,
      skill_name = yishe.name,
      pattern = ".",
      prompt = "#xh__yishe-place",
      cancelable = false,
    })
    
    -- 置为米
    local mi = player:getMark("@@yishe_mi") or {}
    if type(mi) ~= "table" then mi = {} end
    
    for _, id in ipairs(cards) do
      table.insert(mi, id)
      room:moveCardTo(id, Card.Processing, player, fk.ReasonPut, yishe.name)
    end
    
    room:setPlayerMark(player, "@@yishe_mi", mi)
  end,
})

return yishe
