class_name Stats
extends Resource


signal uptate_stats
signal health_changed(cur_health:int, max_health:int)
signal no_health
#region curves and buffs

enum BuffableStats {
	SPEED,
	STEALTH,
	MAX_HEALTH,
	REGEN,
	MELE_DEFENSE,
	MELE_POWER,
	MAGIC_POWER,
	MAGIC_DEFENSE
}


const STATCURVES:Dictionary[BuffableStats, Curve] = {
	BuffableStats.SPEED: preload("uid://buwa5pbocvvi4"),
	BuffableStats.STEALTH: preload("uid://3gw2m1pml6gr"),
	BuffableStats.MAX_HEALTH: preload("uid://c4wx01q2dsrws"),
	BuffableStats.REGEN: preload("uid://cseiv1ocal18y"),
	BuffableStats.MELE_DEFENSE: preload("uid://jimxwrtfim8o"),
	BuffableStats.MELE_POWER: preload("uid://d1rfkm4f6mwej"),
	BuffableStats.MAGIC_POWER: preload("uid://dp4r4jy37vpgy"),
	BuffableStats.MAGIC_DEFENSE: preload("uid://c4delxj3muty")
}
#endregion



#region Base stats

@export var base_level_exp:float = 100.0
@export var base_speed:float = 300.0
@export var base_regen:float = 50.0
@export var base_stealth:float = 20.0
@export var base_mele_power:float = 80.0
@export var base_magic_power:float = 60.0
@export var base_magic_defense:float = 40.0
@export var base_mele_defense:float = 60.0
@export var base_max_health:float = 500.0
#endregion
@export var base_stat_point_amount:int = 3
@export var experince:float = 0.0: set = _on_exp_set
@export var stat_points:int = 3
#region current stats
var current_speed:float 
var current_regen:float
var current_stealth:float
var current_mele_power:float
var current_magic_power:float
var current_magic_defense:float
var current_mele_defense:float
var current_max_health:float

var max_level:int = 999

var speed_lvl:int = 1
var regen_lvl:int = 1
var stealth_lvl:int = 1
var mele_power_lvl:int = 1
var magic_power_lvl:int = 1
var magic_defense_lvl:int = 1
var mele_defense_lvl:int = 1
var max_health_lvl:int = 1

#endregion

var level: int:
	get(): return floor(max(1.0, sqrt(experince / base_level_exp) + 0.5))

var health:float = 0.0: set = _on_health_set
var stat_buffs:Array[StatBuff]


func _init() -> void:
	setup_stats.call_deferred()
	


func _on_health_set(new_value:float) -> void:
	clampf(new_value, 0, current_max_health)
	health_changed.emit(health, current_max_health)
	if health <= 0.0:
		no_health.emit()


func add_buff(buff:StatBuff) -> void:
	stat_buffs.append(buff)
	recalculate_stats.call_deferred()


func remove_buff(buff:StatBuff) -> void:
	stat_buffs.erase(buff)
	recalculate_stats()

func recalculate_stats()->void:
#region buffs

	var stat_addens:Dictionary = {}
	var stat_multipliyers:Dictionary = {}
	for buff in stat_buffs:
		var stat_name:String = BuffableStats.keys()[buff.stat].to_lower()
		match buff.buff_type:
			StatBuff.BuffType.ADD:
				if not stat_addens.has(stat_name):
					stat_addens[stat_name] = 0.0
				stat_addens[stat_name] += buff.buff_amount
				
			StatBuff.BuffType.MULTIPLY:
				if not stat_multipliyers.has(stat_name):
					stat_multipliyers[stat_name] = 1.0
				stat_multipliyers[stat_name] += buff.buff_amount
	
#endregion
	
	var max_health_sample_pos:float = float(max_health_lvl) / 1000.0 - 0.001
	current_max_health = base_max_health * STATCURVES[BuffableStats.MAX_HEALTH].sample(max_health_sample_pos)
	var speed_sample_pos:float = float(speed_lvl) / 1000.0 - 0.001
	current_speed = base_speed * STATCURVES[BuffableStats.SPEED].sample(speed_sample_pos)
	var stealth_sample_pos:float = float(stealth_lvl) / 1000.0 - 0.001
	current_stealth = base_stealth * STATCURVES[BuffableStats.STEALTH].sample(stealth_sample_pos)
	var regen_sample_pos:float = float(regen_lvl) / 1000.0 - 0.001
	current_regen = base_regen * STATCURVES[BuffableStats.REGEN].sample(regen_sample_pos)
	var magic_defense_sample_pos:float = float(magic_defense_lvl) / 1000.0 - 0.001
	current_magic_defense = base_magic_defense * STATCURVES[BuffableStats.MAGIC_DEFENSE].sample(magic_defense_sample_pos)
	var magic_power_sample_pos:float = float(magic_power_lvl) / 1000.0 - 0.001
	current_magic_power = base_magic_power * STATCURVES[BuffableStats.MAGIC_POWER].sample(magic_power_sample_pos)
	var mele_defense_sample_pos:float = float(mele_defense_lvl) / 1000.0 - 0.001
	current_mele_defense = base_mele_defense * STATCURVES[BuffableStats.MELE_DEFENSE].sample(mele_defense_sample_pos)
	var mele_power_sample_pos:float = float(mele_power_lvl) / 1000.0 - 0.001
	current_mele_power = base_mele_power * STATCURVES[BuffableStats.MELE_POWER].sample(mele_power_sample_pos)
	
	
	for stat_name:String in stat_multipliyers:
		var cur_property_name:String = ("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliyers[stat_name])
	
	
	for stat_name:String in stat_addens:
		var cur_property_name:String = ("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addens[stat_name])
	uptate_stats.emit()
	
	

func setup_stats()->void:
	recalculate_stats()
	current_max_health = base_max_health


func _on_exp_set(new_value:float)->void:
	var old_level :int = level
	experince = new_value
	
	if not old_level == level:
		if level >= max_level:
			speed_lvl = max_level
			regen_lvl = max_level
			stealth_lvl = max_level
			mele_power_lvl = max_level
			magic_power_lvl = max_level
			magic_defense_lvl = max_level
			mele_defense_lvl = max_level
			max_health_lvl = max_level
			recalculate_stats()
			return
		speed_lvl += level - old_level
		regen_lvl += level - old_level
		stealth_lvl += level - old_level
		mele_power_lvl += level - old_level
		magic_power_lvl += level - old_level
		magic_defense_lvl += level - old_level
		mele_defense_lvl += level - old_level
		max_health_lvl += level - old_level 
		stat_points += (level - old_level) * base_stat_point_amount
		recalculate_stats()



func double_exp()->float:
	experince *= 2
	return experince
	
	
	
