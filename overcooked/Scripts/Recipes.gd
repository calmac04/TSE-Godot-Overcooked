extends Node
var recipelist = []
var timerval = 0
var frametime = 0
var rng = RandomNumberGenerator.new()
var randomtimer = rng.randf_range(0.0, 10.0)
var score = 0

func _physics_process(delta):
	frametime = frametime + 1
	if frametime > 60:
		frametime = 0
		timerval = timerval + 1
		#print(timerval)
		if timerval >= randomtimer:
			timerval = 0
			randomtimer = rng.randf_range(15.0, 30.0)
			#print(randomtimer)
			var item = ["onionsoup",50]
			if recipelist.size() < 5:
				recipelist.append(item)
		for n in recipelist:
			if n[1] == 0:
				recipelist.erase(n)
				print("recipe failed")
				score = score - 25
			n[1] = n[1] - 1
		#print(recipelist)
	pass

func removerecipe(dish):
	for n in recipelist:
		if n == dish:
			score = score + n[1]
			recipelist.erase(n)
		break
	pass
