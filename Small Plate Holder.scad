include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

// distanceBetweenArms = 80;

bearingOD = 22;
bearingZ = 7;

bearingHolderWallZ = 3;
bearingHolderTotalZ = bearingZ + bearingHolderWallZ;

clampScewwHoleDia = 2.9;
armZ = bearingHolderWallZ+bearingZ/2;

module itemModule()
{
	difference()
    {
        hull()
        {
            cylinder(d=bearingOD + 2*4, h=bearingHolderTotalZ);
            tcy([bearingOD/2+15,0,0], d=13, h=bearingHolderTotalZ);
        }

        // Bearing recess:
        tcy([0,0,bearingHolderWallZ], d=bearingOD+0.2, h=20);

        // Lip to hold bearing:
        tcy([0,0,-1], d=13.5, h=20);

        // Hole for the screw to retain the bearing:
        translate([0,0,armZ]) rotate([90,0,0]) tcy([0,0,0], d=clampScewwHoleDia, h=40);

        // Hole for the screws to clamp the arm:
        screw1X = bearingOD/2+6;
        screw2X = screw1X+7;
        translate([screw1X,0,armZ]) rotate([90,0,0]) tcy([0,0,0], d=clampScewwHoleDia, h=40);
        translate([screw2X,0,armZ]) rotate([-90,0,0]) tcy([0,0,0], d=clampScewwHoleDia, h=40);

        // Hole for the arm:
        armHoleDia = 1.9;
        armHoleWideSectionDia = 2.4;
        armHoleWideSectionCZ = (armHoleWideSectionDia - armHoleDia)/2 + nothing;
        translate([0,0,armZ]) rotate([0,90,0]) tcy([0,0,0], d=armHoleDia, h=40);
        wideSpotExtraX = clampScewwHoleDia + 3.5;
        translate([screw2X+wideSpotExtraX/2,0,armZ]) 
            rotate([0,-90,0]) 
                simpleChamferedCylinderDoubleEnded(d=armHoleWideSectionDia, h=screw2X-screw1X+wideSpotExtraX, cz=armHoleWideSectionCZ);
    }
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
    tcu([-200, -200, armZ-d], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
