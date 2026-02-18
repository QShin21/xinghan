-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 群雄武将包
local extension = Package:new("xinhan_qun")
extension.extensionName = "xinhanwujiang"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinhanwujiang/pkg/qun/skills")

Fk:loadTranslationTable {
  ["xinhan_qun"] = "星汉灿烂·群",
}

-- 贾诩，男，群，3勾玉
General:new(extension, "jiaxu", "qun", 3):addSkills { "wansha", "luanwu", "weimu" }
Fk:loadTranslationTable {
  ["jiaxu"] = "贾诩",
  ["#jiaxu"] = "冷酷的毒士",
  ["illustrator:jiaxu"] = "KayaK",
  ["~jiaxu"] = "我的时辰……到了……",
}

-- 吕布，男，群，5勾玉
General:new(extension, "lvbu", "qun", 5):addSkills { "wushuang", "liyu" }
Fk:loadTranslationTable {
  ["lvbu"] = "吕布",
  ["#lvbu"] = "武的化身",
  ["illustrator:lvbu"] = "KayaK",
  ["~lvbu"] = "不可能！",
}

-- 貂蝉，女，群，3勾玉
General:new(extension, "diaochan", "qun", 3, 3, General.Female):addSkills { "biyue" }
Fk:loadTranslationTable {
  ["diaochan"] = "貂蝉",
  ["#diaochan"] = "绝世的舞姬",
  ["illustrator:diaochan"] = "KayaK",
  ["~diaochan"] = "父亲大人，对不起……",
}

-- 董卓，男，群，4勾玉
General:new(extension, "dongzhuo", "qun", 4):addSkills { "jiuchi", "hengzheng" }
Fk:loadTranslationTable {
  ["dongzhuo"] = "董卓",
  ["#dongzhuo"] = "魔王",
  ["illustrator:dongzhuo"] = "KayaK",
  ["~dongzhuo"] = "汉室……亡了……",
}

-- 袁绍，男，群，4勾玉
General:new(extension, "yuanshao", "qun", 4):addSkills { "luanji" }
Fk:loadTranslationTable {
  ["yuanshao"] = "袁绍",
  ["#yuanshao"] = "高贵的名门",
  ["illustrator:yuanshao"] = "KayaK",
  ["~yuanshao"] = "老天不公啊！",
}

-- 田丰，男，群，3勾玉
General:new(extension, "tianfeng", "qun", 3):addSkills { "sijian", "suishi" }
Fk:loadTranslationTable {
  ["tianfeng"] = "田丰",
  ["#tianfeng"] = "河北谋士",
  ["illustrator:tianfeng"] = "KayaK",
  ["~tianfeng"] = "吾命休矣……",
}

-- 马腾，男，群，4勾玉
General:new(extension, "mateng", "qun", 4):addSkills { "mashu", "xiongyi" }
Fk:loadTranslationTable {
  ["mateng"] = "马腾",
  ["#mateng"] = "西凉太守",
  ["illustrator:mateng"] = "KayaK",
  ["~mateng"] = "西凉……完了……",
}

-- 李儒，男，群，3勾玉
General:new(extension, "liru", "qun", 3):addSkills { "mieji", "juece", "fengcheng" }
Fk:loadTranslationTable {
  ["liru"] = "李儒",
  ["#liru"] = "魔士",
  ["illustrator:liru"] = "KayaK",
  ["~liru"] = "主公……",
}

-- 高顺，男，群，4勾玉
General:new(extension, "gaoshun", "qun", 4):addSkills { "xianzhen", "jinjiu" }
Fk:loadTranslationTable {
  ["gaoshun"] = "高顺",
  ["#gaoshun"] = "陷阵营主",
  ["illustrator:gaoshun"] = "KayaK",
  ["~gaoshun"] = "陷阵……败了……",
}

-- 孙策(群)，男，群，4勾玉
General:new(extension, "sunce_qun", "qun", 4):addSkills { "liantao" }
Fk:loadTranslationTable {
  ["sunce_qun"] = "孙策",
  ["#sunce_qun"] = "江东小霸王",
  ["illustrator:sunce_qun"] = "KayaK",
  ["~sunce_qun"] = "大业未成……",
}

-- 刘表，男，群，3勾玉
General:new(extension, "liubiao", "qun", 3):addSkills { "zishou", "zongshi" }
Fk:loadTranslationTable {
  ["liubiao"] = "刘表",
  ["#liubiao"] = "荆州牧",
  ["illustrator:liubiao"] = "KayaK",
  ["~liubiao"] = "荆州……",
}

-- 杨彪，男，群，3勾玉
General:new(extension, "yangbiao", "qun", 3):addSkills { "zhaohan", "rangjie" }
Fk:loadTranslationTable {
  ["yangbiao"] = "杨彪",
  ["#yangbiao"] = "汉室忠臣",
  ["illustrator:yangbiao"] = "KayaK",
  ["~yangbiao"] = "汉室……",
}

-- 张角，男，群，3勾玉
General:new(extension, "zhangjiao", "qun", 3):addSkills { "leiji", "guidao" }
Fk:loadTranslationTable {
  ["zhangjiao"] = "张角",
  ["#zhangjiao"] = "天公将军",
  ["illustrator:zhangjiao"] = "KayaK",
  ["~zhangjiao"] = "黄天……",
}

-- 于吉，男，群，3勾玉
General:new(extension, "yuji", "qun", 3):addSkills { "guhuo" }
Fk:loadTranslationTable {
  ["yuji"] = "于吉",
  ["#yuji"] = "太平道人",
  ["illustrator:yuji"] = "KayaK",
  ["~yuji"] = "蛊惑……",
}

return extension
