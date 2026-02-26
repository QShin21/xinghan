local mizhao = fk.CreateSkill {
  name = "xh__mizhao",
}

Fk:loadTranslationTable {
  ["xh__mizhao"] = "密诏",
  [":xh__mizhao"] = "出牌阶段限一次，你可以与对手拼点，拼点赢的角色视为对拼点没赢的角色使用一张无距离和次数限制的普通【杀】。",
  
  ["#xh__mizhao"] = "密诏：与对手拼点，拼点赢的角色视为对没赢的角色使用【杀】",
  ["#xh__mizhao-choose"] = "密诏：选择与 %dest 拼点的角色，拼点胜者视为对失败者使用【杀】",

  ["$xh__mizhao1"] = "爱卿世受皇恩，堪此重任。",
  ["$xh__mizhao2"] = "此诏事关重大，切记小心行事。",
}

mizhao:addEffect("active", {
  anim_type = "control",
  prompt = "#xh__mizhao",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(mizhao.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    
    -- 让目标与另一个角色拼点
    if target.dead or target:isKongcheng() then return end
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return target:canPindian(p) and p ~= target
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      skill_name = mizhao.name,
      min_num = 1,
      max_num = 1,
      targets = targets,
      prompt = "#xh__mizhao-choose::"..target.id,
      cancelable = false,
    })[1]
    
    -- 发起拼点
    local pindian = target:pindian({to}, mizhao.name)
    
    -- 拼点胜利的角色使用无距离、无次数限制的普通【杀】
    if pindian.results[to].winner then
      local winner, loser
      if pindian.results[to].winner == target then
        winner = target
        loser = to
      else
        winner = to
        loser = target
      end
      if loser.dead then return end
      
      -- 使用无距离、无次数限制的【杀】
      room:useVirtualCard("slash", nil, winner, loser, mizhao.name)
    end
  end
})

return mizhao