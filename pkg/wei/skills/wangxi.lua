-- SPDX-License-Identifier: GPL-3.0-or-later
-- 李典 - 忘隙技能
-- 当你对其他角色造成1点伤害后，或当你受到其他角色造成的1点伤害后，
-- 若该角色存活，你可以摸两张牌，然后将其中一张牌交给该角色。

local wangxi = fk.CreateSkill {
  name = "xh__wangxi",
}

Fk:loadTranslationTable {
  ["xh__wangxi"] = "忘隙",
  [":xh__wangxi"] = "当你对其他角色造成1点伤害后，或当你受到其他角色造成的1点伤害后，"..
    "若该角色存活，你可以摸两张牌，然后将其中一张牌交给该角色。",

  ["#xh__wangxi-invoke"] = "忘隙：你可以摸两张牌，然后将其中一张牌交给 %dest",
  ["#xh__wangxi-give"] = "忘隙：选择一张牌交给 %dest",

  ["$xh__wangxi1"] = "前嫌尽释，共图大业。",
  ["$xh__wangxi2"] = "既往不咎，携手同行。",
}

-- 造成伤害后
wangxi:addEffect(fk.Damage, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__wangxi.name) and
      data.to and data.to ~= player and not data.to.dead and data.damage > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xh__wangxi.name,
      prompt = "#wangxi-invoke::" .. data.to.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to

    -- 摸两张牌
    player:drawCards(2, xh__wangxi.name)

    if player.dead or to.dead or player:isKongcheng() then return end

    -- 将其中一张牌交给该角色
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = xh__wangxi.name,
      pattern = ".",
      prompt = "#wangxi-give::" .. to.id,
      cancelable = false,
    })

    room:moveCardTo(card, Player.Hand, to, fk.ReasonGive, xh__wangxi.name, nil, false, player.id)
  end,
})

-- 受到伤害后
wangxi:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__wangxi.name) and
      data.from and data.from ~= player and not data.from.dead and data.damage > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xh__wangxi.name,
      prompt = "#wangxi-invoke::" .. data.from.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.from

    -- 摸两张牌
    player:drawCards(2, xh__wangxi.name)

    if player.dead or to.dead or player:isKongcheng() then return end

    -- 将其中一张牌交给该角色
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = xh__wangxi.name,
      pattern = ".",
      prompt = "#wangxi-give::" .. to.id,
      cancelable = false,
    })

    room:moveCardTo(card, Player.Hand, to, fk.ReasonGive, xh__wangxi.name, nil, false, player.id)
  end,
})

return wangxi
