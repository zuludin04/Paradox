extends ProgressBar

var health = 0: set = _set_health

func _set_health(new_health):
	health = new_health
	value = new_health

func init_health(_health):
	health = _health
	max_value = health
	value = health
