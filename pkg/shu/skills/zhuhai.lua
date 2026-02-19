-- SPDX-License-Identifier: GPL-3.0-or-later
-- 徐庶 - 诛害技能
-- 其他角色的结束阶段，若该角色本回合造成过伤害则你可以将一张手牌当【杀】或【过河拆桥】对其使用。

local zhuhai = fk.CreateSkill {
  name = "xh__zhuhai",
}

Fk:loadTranslationTable {
  ["xh__zhuhai"] = "诛害",
  [":xh__zhuhai"] = "其他角色的结束阶段，若该角色本回合造成过伤害则你可以将一张手牌当【杀】或【过河拆桥】对其使用。",

  ["#xh__zhuhai-use"] = "诛害：将一张手牌当杀或过河拆桥使用",
  ["zhuhai_slash"] = "当杀使用",
  ["zhuhai_dismantlement"] = "当过河拆桥使用",

  ["$xh__zhuhai1"] = "诛害奸佞，替天行道！",
  ["$xh__zhuhai2"] = "害人者，必受其害！",
}

zhuhai:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player or not player:hasSkill(xh__zhuhai.name) then return false end
    if target.phase ~= Player.Finish then return false end
    if player:isKongcheng() then return false end
    
    -- 检查是否造成过伤害
    return target:getMark("@@zhuhai_damage") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = xh__zhuhai.name,
      pattern = ".",
      prompt = "#zhuhai-use",
      cancelable = true,
    })
    
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_id = event:getCostData(self).cards[1]
    
    local choice = room:askToChoice(player, {
      choices = {"zhuhai_slash", "zhuhai_dismantlement"},
      skill_name = xh__zhuhai.name,
      prompt = "选择当什么牌使用",
      detailed = false,
    })
    
    local card_name = choice == "zhuhai_slash" and "slash" or "dismantlement"
    local card = Fk:cloneCard(card_name)
    card.skillName = xh__zhuhai.name
    card:addSubcard(card_id)
    
    room:useCard{
      from = player.id,
      tos = {target.id},
      card = card,
    }
  end,
})

-- 记录伤害
zhuhai:addEffect(fk.Damage, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target and target.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(target, "@@zhuhai_damage", 1)
  end,
})

-- 回合结束清除标记
zhuhai:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@zhuhai_damage") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@zhuhai_damage", 0)
  end,
})

return zhuhai
