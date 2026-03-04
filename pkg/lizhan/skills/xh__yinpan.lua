local yinpan = fk.CreateSkill{
  name = "xh__yinpan",
  frequency = Skill.Limited,
  limit_mark = "@@xh__yinpan",
}

Fk:loadTranslationTable{
  ["xh__yinpan"] = "引叛",
  [":xh__yinpan"] = "限定技，出牌阶段开始时，你可以对一名其他角色造成X点伤害（X为其因“明策”摸牌的次数）。",
  ["#xh__yinpan-choose"] = "引叛：对一名角色造成其因“明策”摸牌次数的伤害",
  ["@@xh__yinpan"] = "引叛",

  ["$xh__yinpan1"] = "计成势起，反者自溃。",
  ["$xh__yinpan2"] = "引其离心，叛意自生。",
}

yinpan:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(yinpan.name) then return false end
    if player.phase ~= Player.Play then return false end
    if player:getMark("@@xh__yinpan") == 0 then return false end

    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if p:getMark("xh__mingce_draw") > 0 then
        return true
      end
    end
    return false
  end,

  on_cost = function(self, event, target, player, data)
    local room = player.room
    local candidates = table.filter(room:getOtherPlayers(player, false), function(p)
      return p:getMark("xh__mingce_draw") > 0
    end)

    if #candidates == 0 then return false end

    local tos = room:askToChoosePlayers(player, {
      targets = candidates,
      min_num = 1,
      max_num = 1,
      prompt = "#xh__yinpan-choose",
      skill_name = yinpan.name,
      cancelable = true,
    })

    if #tos > 0 then
      event:setCostData(self, tos[1])
      return true
    end
    return false
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self)
    if not to or to.dead or player.dead then return end

    local x = to:getMark("xh__mingce_draw")
    if x <= 0 then
      room:setPlayerMark(player, "@@xh__yinpan", 0)
      room:updateAllLimitSkillUI(player)
      return
    end

    player:broadcastSkillInvoke(yinpan.name)
    room:damage{
      from = player,
      to = to,
      damage = x,
      skillName = yinpan.name,
    }

    room:setPlayerMark(player, "@@xh__yinpan", 0)
    room:updateAllLimitSkillUI(player)

    room:setPlayerMark(to, "xh__mingce_draw", 0)
  end,
})

return yinpan