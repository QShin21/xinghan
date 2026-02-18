-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 蜀国武将包
local extension = Package:new("xinhan_shu")
extension.extensionName = "xinhanwujiang"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinhanwujiang/pkg/shu/skills")

Fk:loadTranslationTable {
  ["xinhan_shu"] = "星汉灿烂·蜀",
}

-- 赵云，男，蜀，4勾玉
General:new(extension, "zhaoyun", "shu", 4):addSkills { "longdan", "yajiao" }
Fk:loadTranslationTable {
  ["zhaoyun"] = "赵云",
  ["#zhaoyun"] = "常山赵子龙",
  ["illustrator:zhaoyun"] = "KayaK",
  ["~zhaoyun"] = "这，就是失败的滋味吗……",
}

-- 张飞，男，蜀，4勾玉
General:new(extension, "zhangfei", "shu", 4):addSkills { "paoxiao" }
Fk:loadTranslationTable {
  ["zhangfei"] = "张飞",
  ["#zhangfei"] = "万夫不当",
  ["illustrator:zhangfei"] = "KayaK",
  ["~zhangfei"] = "实在是……打不动了……",
}

-- 关羽，男，蜀，4勾玉
General:new(extension, "guanyu", "shu", 4):addSkills { "wusheng", "yijue" }
Fk:loadTranslationTable {
  ["guanyu"] = "关羽",
  ["#guanyu"] = "武圣",
  ["illustrator:guanyu"] = "KayaK",
  ["~guanyu"] = "什么？此地竟有……",
}

-- 刘备，男，蜀，4勾玉
General:new(extension, "liubei", "shu", 4):addSkills { "renwang" }
Fk:loadTranslationTable {
  ["liubei"] = "刘备",
  ["#liubei"] = "乱世的枭雄",
  ["illustrator:liubei"] = "KayaK",
  ["~liubei"] = "这就是……桃园吗……",
}

-- 诸葛亮，男，蜀，3勾玉
General:new(extension, "zhugeliang", "shu", 3):addSkills { "bazhen", "huoji", "kanpo" }
Fk:loadTranslationTable {
  ["zhugeliang"] = "诸葛亮",
  ["#zhugeliang"] = "卧龙",
  ["illustrator:zhugeliang"] = "KayaK",
  ["~zhugeliang"] = "将星陨落……",
}

-- 黄月英，女，蜀，3勾玉
General:new(extension, "huangyueying", "shu", 3, 3, General.Female):addSkills { "jizhi", "qicai" }
Fk:loadTranslationTable {
  ["huangyueying"] = "黄月英",
  ["#huangyueying"] = "归隐的杰女",
  ["illustrator:huangyueying"] = "KayaK",
  ["~huangyueying"] = "亮……",
}

-- 孙乾，男，蜀，3勾玉
General:new(extension, "sunqian", "shu", 3):addSkills { "shuomeng" }
Fk:loadTranslationTable {
  ["sunqian"] = "孙乾",
  ["#sunqian"] = "说客",
  ["illustrator:sunqian"] = "KayaK",
  ["~sunqian"] = "主公……",
}

-- 张世平，男，蜀，3勾玉
General:new(extension, "zhangshiping", "shu", 3):addSkills { "hongji" }
Fk:loadTranslationTable {
  ["zhangshiping"] = "张世平",
  ["#zhangshiping"] = "商贾",
  ["illustrator:zhangshiping"] = "KayaK",
  ["~zhangshiping"] = "生意……",
}

-- 马超，男，蜀，4勾玉
General:new(extension, "machao", "shu", 4):addSkills { "mashu", "tieji" }
Fk:loadTranslationTable {
  ["machao"] = "马超",
  ["#machao"] = "一骑当千",
  ["illustrator:machao"] = "KayaK",
  ["~machao"] = "西凉……",
}

-- 关平，男，蜀，4勾玉
General:new(extension, "guanping", "shu", 4):addSkills { "longyin", "jiezhong" }
Fk:loadTranslationTable {
  ["guanping"] = "关平",
  ["#guanping"] = "忠义",
  ["illustrator:guanping"] = "KayaK",
  ["~guanping"] = "父亲……",
}

-- 魏延，男，蜀，4勾玉
General:new(extension, "weiyan", "shu", 4):addSkills { "kuanggu", "qimou" }
Fk:loadTranslationTable {
  ["weiyan"] = "魏延",
  ["#weiyan"] = "狂骨",
  ["illustrator:weiyan"] = "KayaK",
  ["~weiyan"] = "谁敢杀我！",
}

-- 黄忠，男，蜀，4勾玉
General:new(extension, "huangzhong", "shu", 4):addSkills { "liegong" }
Fk:loadTranslationTable {
  ["huangzhong"] = "黄忠",
  ["#huangzhong"] = "老当益壮",
  ["illustrator:huangzhong"] = "KayaK",
  ["~huangzhong"] = "老矣……",
}

-- 徐庶，男，蜀，4勾玉
General:new(extension, "xushu", "shu", 4):addSkills { "zhuhai", "qianxin" }
Fk:loadTranslationTable {
  ["xushu"] = "徐庶",
  ["#xushu"] = "忠孝",
  ["illustrator:xushu"] = "KayaK",
  ["~xushu"] = "母亲……",
}

return extension
