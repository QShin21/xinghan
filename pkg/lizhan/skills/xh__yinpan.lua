local yinpan = fk.CreateSkill{
  name = "xh__yinpan",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["xh__yinpan"] = "引叛",
  [":xh__yinpan"] = "限定技，出牌阶段，你可以对一名因“明策”摸过牌的其他角色造成X点伤害（X为其因“明策”摸牌的次数）。",

  ["#xh__yinpan"] = "引叛：对一名因“明策”摸过牌的角色造成X点伤害",
  ["@@xh__yinpan_count"] = "引叛计数",

  ["$xh__yinpan1"] = "引叛之计，借刀杀人！",
  ["$xh__yinpan2"] = "陈宫引叛，天下大乱！",
}

local function getMingceDrawCount(player)
  local mark = player:getTableMark("@@xh__yinpan_count")
  if type(mark) == "table" then
    return #mark
  elseif type(mark) == "number" then
    return mark
  end
  return 0
end

local function clearMingceDrawCount(room, player)
  local mark = player:getTableMark("@@xh__yinpan_count")
  if type(mark) == "table" then
    while #mark > 0 do
      room:removeTableMark(player, "@@xh__yinpan_count", mark[1])
      mark = player:getTableMark("@@xh__yinpan_count")
      if type(mark) ~= "table" then
        break
      end
    end
  end
end

yinpan:addEffect("active", {
  anim_type = "offensive",
  prompt = "#xh__yinpan",
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,

  can_use = function(self, player)
    if player.phase ~= Player.Play then return false end
    if player:usedSkillTimes(yinpan.name, Player.HistoryGame) > 0 then return false end

    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if getMingceDrawCount(p) > 0 then
        return true
      end
    end
    return false
  end,

  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and getMingceDrawCount(to_select) > 0
  end,

  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if not player or player.dead or not target or target.dead then return end

    local x = getMingceDrawCount(target)
    if x <= 0 then return end

    room:damage{
      from = player,
      to = target,
      damage = x,
      skillName = yinpan.name,
    }

    if not target.dead then
      clearMingceDrawCount(room, target)
    end
  end,
})

return yinpan
