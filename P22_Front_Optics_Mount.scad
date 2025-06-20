include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

picatinnyMountWidth = 21.0;
picatinnyMountHeight = 5.45; // 6.50 55.1
picatinnyMountAngleWidth = 2.96; // 2.81 2.40
picatinnyMountRiserHeight = 2.47; //2.99 3.87

p22ClearanceFromRailBottomToHighestPointOnSlideDuringInstallation = 51.6;
p22SlideWidth = 24.4;
p22DistFromFrontOfRailToCtrOfFirstSlot = 7.5;

module itemModule()
{
	railClamp();
}

module railClamp()
{
    
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
