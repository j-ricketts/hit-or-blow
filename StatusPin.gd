extends Pin


enum Status {MISS, BLOW, HIT}

func initialise(type, pos, play_generate_anim=true):
	if type == Status.BLOW:
		pass
	elif type == Status.HIT:
		pass
		
	.initialise(pos, play_generate_anim)

