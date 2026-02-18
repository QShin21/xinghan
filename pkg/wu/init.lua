-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 吴国武将包
local extension = Package:new("xinhan_wu")
extension.extensionName = "xinhanwujiang"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinhanwujiang/pkg/wu/skills")

Fk:loadTranslationTable {
  ["xinhan_wu"] = "星汉灿烂·吴",
}

-- 孙坚，男，吴，4/5勾玉
local sunjian = General:new(extension, "sunjian", "wu", 4, 5)
sunjian:addSkills { "hulie", "yinghun" }
Fk:loadTranslationTable {
  ["sunjian"] = "孙坚",
  ["#sunjian"] = "江东猛虎",
  ["illustrator:sunjian"] = "KayaK",
  ["~sunjian"] = "有埋伏……呃……",
}

-- 孙权，男，吴，4勾玉
General:new(extension, "sunquan", "wu", 4):addSkills { "zhiheng" }
Fk:loadTranslationTable {
  ["sunquan"] = "孙权",
  ["#sunquan"] = "年轻的贤君",
  ["illustrator:sunquan"] = "KayaK",
  ["~sunquan"] = "父亲，大哥，仲谋愧矣……",
}

-- 孙尚香，女，吴，3勾玉
General:new(extension, "sunshangxiang", "wu", 3, 3, General.Female):addSkills { "jieyin" }
Fk:loadTranslationTable {
  ["sunshangxiang"] = "孙尚香",
  ["#sunshangxiang"] = "弓腰姬",
  ["illustrator:sunshangxiang"] = "KayaK",
  ["~sunshangxiang"] = "不，还不可以……",
}

-- 甘宁，男，吴，4勾玉
General:new(extension, "ganning", "wu", 4):addSkills { "qixi" }
Fk:loadTranslationTable {
  ["ganning"] = "甘宁",
  ["#ganning"] = "锦帆游侠",
  ["illustrator:ganning"] = "KayaK",
  ["~ganning"] = "别想……跑……",
}

-- 吕蒙，男，吴，4勾玉
General:new(extension, "lvmeng", "wu", 4):addSkills { "keji" }
Fk:loadTranslationTable {
  ["lvmeng"] = "吕蒙",
  ["#lvmeng"] = "白衣渡江",
  ["illustrator:lvmeng"] = "KayaK",
  ["~lvmeng"] = "被看穿了吗……",
}

-- 黄盖，男，吴，4勾玉
General:new(extension, "huanggai", "wu", 4):addSkills { "kurou", "zhaxiang" }
Fk:loadTranslationTable {
  ["huanggai"] = "黄盖",
  ["#huanggai"] = "轻身为国",
  ["illustrator:huanggai"] = "KayaK",
  ["~huanggai"] = "再无……苦肉计了……",
}

-- 周瑜，男，吴，3勾玉
General:new(extension, "zhouyu", "wu", 3):addSkills { "yingzi", "fanjian" }
Fk:loadTranslationTable {
  ["zhouyu"] = "周瑜",
  ["#zhouyu"] = "大都督",
  ["illustrator:zhouyu"] = "KayaK",
  ["~zhouyu"] = "既生瑜，何生亮……",
}

-- 大乔，女，吴，3勾玉
General:new(extension, "daqiao", "wu", 3, 3, General.Female):addSkills { "guose", "liuli" }
Fk:loadTranslationTable {
  ["daqiao"] = "大乔",
  ["#daqiao"] = "矜持之花",
  ["illustrator:daqiao"] = "KayaK",
  ["~daqiao"] = "伯符……",
}

-- 陆逊，男，吴，3勾玉
General:new(extension, "luxun", "wu", 3):addSkills { "qianxun", "lianying" }
Fk:loadTranslationTable {
  ["luxun"] = "陆逊",
  ["#luxun"] = "儒生雄才",
  ["illustrator:luxun"] = "KayaK",
  ["~luxun"] = "还是……太年轻了……",
}

-- 孙策，男，吴，4勾玉
General:new(extension, "sunce", "wu", 4):addSkills { "jiang", "hunzi" }
Fk:loadTranslationTable {
  ["sunce"] = "孙策",
  ["#sunce"] = "江东小霸王",
  ["illustrator:sunce"] = "KayaK",
  ["~sunce"] = "内事不决问张昭，外事不决问周瑜……",
}

-- 庞统，男，吴，3勾玉
General:new(extension, "pangtong", "wu", 3):addSkills { "guolun", "zhanji" }
Fk:loadTranslationTable {
  ["pangtong"] = "庞统",
  ["#pangtong"] = "凤雏",
  ["illustrator:pangtong"] = "KayaK",
  ["~pangtong"] = "落凤坡……",
}

-- 韩当，男，吴，4勾玉
General:new(extension, "handang", "wu", 4):addSkills { "gongqi", "jiefan" }
Fk:loadTranslationTable {
  ["handang"] = "韩当",
  ["#handang"] = "石城侯",
  ["illustrator:handang"] = "KayaK",
  ["~handang"] = "江东……",
}

return extension
