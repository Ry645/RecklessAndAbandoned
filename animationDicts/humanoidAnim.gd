class_name HumanoidAnim

const DICT_POSSIBLE_ANIMATION_DESTINATIONS = {
	#blockState
	#TODO have lower swing for each in place of holdSwordArm: new feature
	"holdSwordArm" = ["raiseQuickBlock", "swing"],
	"lowerQuickBlock" = ["raiseQuickBlock"],
	"raiseQuickBlock" = ["lowerQuickBlock", "parry1"],
	"parry1" = ["holdSwordArm", "parry2"],
	"parry2" = ["holdSwordArm", "parry3"],
	"parry3" = ["holdSwordArm", "parry2"],
	
	"swing" = ["swing_001", "holdSwordArm"],
	"swing_001" = ["swing_002", "holdSwordArm"],
	"swing_002" = ["swing_001", "holdSwordArm"],
	
	#legState
	"rest" = "walkAnimation",
	"walkAnimation" = "rest",
}

const DICT_PARRY_PROCESS = {
	"raiseQuickBlock" = "parry1",
	"parry1" = "parry2",
	"parry2" = "parry3",
	"parry3" = "parry2",
}
const DICT_ATTACK_PROCESS = {
	"holdSwordArm" = "swing",
	"swing" = "swing_001",
	"swing_001" = "swing_002",
	"swing_002" = "swing_001",
}
const DICT_LOWER_SWORD_PROCESS = {
	"raiseQuickBlock" = "lowerQuickBlock",
}

var animationsToTravelTo:Array
var animationTree:AnimationTree

func _init(animTree:AnimationTree):
	animationTree = animTree

func appendAnimation(parameterPath, stateToTravel:String):
	animationsToTravelTo.append([parameterPath, stateToTravel])

func updateAnimations():
	for animation in animationsToTravelTo:
		var animationPlayback:AnimationNodeStateMachinePlayback = animationTree.get(animation[0])
		
		match animation[1]:
			#custom animation
			"parry":
				if animationPlayback.get_current_node() in DICT_PARRY_PROCESS:
					animation[1] = DICT_PARRY_PROCESS[animationPlayback.get_current_node()] #get current to play next
			"attack":
				if animationPlayback.get_current_node() in DICT_ATTACK_PROCESS:
					animation[1] = DICT_ATTACK_PROCESS[animationPlayback.get_current_node()]
			"lowerSword":
				if animationPlayback.get_current_node() in DICT_LOWER_SWORD_PROCESS:
					animation[1] = DICT_LOWER_SWORD_PROCESS[animationPlayback.get_current_node()]
				else:
					#HACK will later just add in new animations to cover holdSwordArm
					animation[1] = "holdSwordArm"
		
		# get current animation, and all possible nodes to travel to using a dictionary
		# if you travel to a animation, then it checks to see if it's even possible using the dictionary
		# if not, stop, if yes, start new animation
		
		if animationPlayback.get_current_node() && animation[1] in DICT_POSSIBLE_ANIMATION_DESTINATIONS[animationPlayback.get_current_node()]:
			animationPlayback.travel(animation[1])
		
	
	animationsToTravelTo.clear()

