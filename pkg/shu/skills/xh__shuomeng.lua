-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孙乾 - 说盟技能
-- 出牌阶段结束时，你可以拼点：若你赢，你视为使用【无中生有】；若你没赢，对手视为对你使用【过河拆桥】。

local shuomeng = fk.CreateSkill {
  name = "xh__shuomeng",
}

Fk:loadTranslationTable {
  ["xh__shuomeng"] = "说盟",
  [":xh__shuomeng"] = "出牌阶段结束时，你可以拼点：若你赢，你视为使用【无中生有】；若你没赢，对手视为对你使用【过河拆桥】。",

  ["#xh__shuomeng-invoke"] = "说盟：是否进行拼点？",

  ["$xh__shuomeng1"] = "说盟结好，共图大业！",
  ["$xh__shuomeng2"] = "唇枪舌剑，以理服人！",
}

shuomeng:addEffect(fk.EventPhaseEnd, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuomeng.name) and
      player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player, false)
    local targets_with_cards = table.filter(targets, function(p)
      return not p:isKongcheng()
    end)
    
    if #targets_with_cards == 0 then return false end
    
    return room:askToSkillInvoke(player, {
      skill_name = shuomeng.name,
      prompt = "#xh__shuomeng-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isKongcheng()
    end)
    
    if #targets == 0 then return end
    
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = shuomeng.name,
      prompt = "选择拼点对象",
      cancelable = false,
    })[1]
    
    local pindian = room:pindian({player, to}, shuomeng.name)
    
    if pindian.results[player].winner then
      -- 赢了：视为使用无中生有
      local card = Fk:cloneCard("ex_nihilo")
      card.skillName = shuomeng.name
      room:useCard{
        from = player.id,
        card = card,
      }
    else
      -- 输了：对手视为对你使用过河拆桥
      local card = Fk:cloneCard("dismantlement")
      card.skillName = shuomeng.name
      room:useCard{
        from = to.id,
        tos = {player.id},
        card = card,
      }
    end
  end,
})

return shuomeng
