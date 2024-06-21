class_name AnimationDictionaries

static var player = {
	"parameters/ArmState/conditions/block" = [["parameters/ArmState/conditions/block", true], ["parameters/ArmState/conditions/lowerBlock", false]] ,
	"parameters/ArmState/conditions/lowerBlock" = [["parameters/ArmState/conditions/lowerBlock", true], ["parameters/ArmState/conditions/block", false], ["parameters/ArmState/conditions/firstParry", false], ["parameters/ArmState/conditions/secondParry", false], ["parameters/ArmState/conditions/swtichParry1", false],["parameters/ArmState/conditions/swtichParry2", false]] ,
	"parameters/ArmState/conditions/firstParry" = [["parameters/ArmState/conditions/firstParry", true], ["parameters/ArmState/conditions/block", false]] ,
	"parameters/ArmState/conditions/secondParry" = [["parameters/ArmState/conditions/secondParry", true], ["parameters/ArmState/conditions/firstParry", false]] ,
	"parameters/ArmState/conditions/swtichParry1" = [["parameters/ArmState/conditions/swtichParry1", true], ["parameters/ArmState/conditions/secondParry", false], ["parameters/ArmState/conditions/swtichParry2", false]] ,
	"parameters/ArmState/conditions/swtichParry2" = [["parameters/ArmState/conditions/swtichParry2", true], ["parameters/ArmState/conditions/swtichParry1", false]] ,
	
	"parameters/legState/conditions/idle" = [["parameters/legState/conditions/idle", true], ["parameters/legState/conditions/walk", false]] ,
	"parameters/legState/conditions/walk" = [["parameters/legState/conditions/walk", true], ["parameters/legState/conditions/idle", false]] ,
}
