include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

picatinnyMountWidth = 21.0;
picatinnyMountFlatTopHeight = 5.45; // 6.50 55.1
// picatinnyMountAngleWidth = 2.96; // 2.81 2.40
picatinnyMountAngleWidth = tan(45) * picatinnyMountFlatTopHeight/2;
picatinnyMountFlatTopWidth = 16.0;
picatinnyMountRiserHeight = 2.47; //2.99 3.87

echo(str("picatinnyMountAngleWidth = ", picatinnyMountAngleWidth));
picatinnyMountRiserWidth = 15.4;

p22PicatinnyRailLength = 25;

p22ClearanceFromRailBottomToHighestPointOnSlideDuringInstallation = 51.6;
p22SlideWidth = 24.4;
p22DistFromFrontOfRailToCtrOfFirstSlot = 7.5;

clampX = 16;
clampOD = 10;
clampCZ = 2;
clampSplitX = 2;
clampOffsetY = -1;
clampCtrY = clampOD/2-clampCZ+clampOffsetY;
clampTopY = clampCtrY + clampOD/2;
clampBotY = clampCtrY - clampOD/2;

// screwHeadRecessDia = 6.1;
// screwHeadRecessZ = 3.5;
// screwHoleDia = 3.55;
// nutXY = 5.7;
// nutZ = 2.5;
// screwZ = 16;

clampScrewHoleDia = 3.55;
clampScrewHeadDia = 6.1;
clampScrewHeadZ = 3;
clampScrewNutXY = 5.7;
clampScrewNutZ = 2.5;
clampScrewZ = 16;
clampScrewExteriorDia = clampScrewNutXY*1.4 + 3;
clampScrewExteriorX = (clampScrewZ-0.5) + clampScrewHeadZ + clampScrewNutZ;

echo(str("clampTopY = ", clampTopY));

module itemModule()
{
	railClamp();
}

module railClamp()
{
    difference()
    {
        union()
        {
            hull()
            {
                doubleX() 
                    translate([clampX-clampOD/2, clampCtrY, 0]) 
                        simpleChamferedCylinderDoubleEnded(d=clampOD, h=p22PicatinnyRailLength, cz=clampCZ);
            }

            
            clampMountScrewsXform() hull()
            {
                translate([0,0,-clampScrewExteriorX/2]) 
                {
                    simpleChamferedCylinderDoubleEnded(d=clampScrewExteriorDia, h=clampScrewExteriorX, cz=1);
                    bigD = clampScrewExteriorDia * 2.2;
                    translate([0,10,0]) difference()
                    {
                        simpleChamferedCylinderDoubleEnded(d=bigD, h=clampScrewExteriorX, cz=1);
                        tcu([-200, -1, -200], 400);
                    }
                }
            }
        }

        p22RailInterior();

        // Split clamp in half:
        tcu([-clampSplitX/2, -15, -10], [clampSplitX, 20, 100]);

        // Hole for screw:
        ClampMountScrewHoles(); 
    }
}

module clampMountScrewsXform()
{
    translate([0, clampBotY-clampScrewHoleDia/2, p22PicatinnyRailLength/2]) rotate([0, 90, 0]) children();
}

module ClampMountScrewHoles()
{
    clampMountScrewsXform() 
    {
        // Hole:
        tcy([0,0,-100], d=clampScrewHoleDia, h=200);
        // Head recess:
        tcy([0,0,clampScrewExteriorX/2-clampScrewHeadZ], d=clampScrewHeadDia, h=200);
        // Nut recess:
        translate([0,0,-clampScrewExteriorX/2+clampScrewNutZ]) rotate([0,0,45]) tcu([-clampScrewNutXY/2, -clampScrewNutXY/2, -100], [clampScrewNutXY, clampScrewNutXY, 100]);
    }
}

module p22RailInterior()
{
    p22RailLength = 100;
    p2RailOffsetZ = -10;
    p22MountWidthAtTipOfAngles = picatinnyMountFlatTopWidth + 2*picatinnyMountAngleWidth;

    // Rail:
    difference()
    {
        // union()
        hull()
        {
            doubleX() translate([p22MountWidthAtTipOfAngles/2+0.2, picatinnyMountFlatTopHeight/2, p2RailOffsetZ]) rotate([0,0,-45-90]) tcu([-0, -10, 0], [10, 10, p22RailLength]);
        }

        tcu([-200, picatinnyMountFlatTopHeight, -200], 400);
        tcu([-200, -400, -200], 400);
    }

    // Extra space at the point of the rails:
    extraTipClearanceDia = 1.5;
    doubleX() tcy([p22MountWidthAtTipOfAngles/2-extraTipClearanceDia/5, picatinnyMountFlatTopHeight/2, -10], d=extraTipClearanceDia, h=200);

    // Rail base:
    baseX = picatinnyMountRiserWidth + 2;
    baseOffsetY = 1;
    tcu([-baseX/2, baseOffsetY, 0], [baseX, picatinnyMountFlatTopHeight+picatinnyMountRiserHeight, p22RailLength]);
    // Rail base chamfering:
    doubleX() translate([baseX/2+1+1, clampTopY+1, p2RailOffsetZ]) rotate([0,0,-45-90]) tcu([-0, -10, p2RailOffsetZ], [10, 10, p22RailLength]);

}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();
    displayGhost() p22RailGhost();
}
else
{
	itemModule();
}

module p22RailGhost()
{
    p22RailLength = 27.4;
    p22MountWidthAtTipOfAngles = picatinnyMountFlatTopWidth + 2*picatinnyMountAngleWidth;

    difference()
    {
        union()
        {
            tcu([-picatinnyMountFlatTopWidth/2, 0, 0], [picatinnyMountFlatTopWidth, picatinnyMountFlatTopHeight, p22RailLength]);
            doubleX() translate([p22MountWidthAtTipOfAngles/2+0.2, picatinnyMountFlatTopHeight/2, 0]) rotate([0,0,-45-90]) tcu([-0, -10, 0], [10, 10, p22RailLength]);
        }

        tcu([-200, picatinnyMountFlatTopHeight, -200], 400);
        tcu([-200, -400, -200], 400);
        doubleX() tcu([p22MountWidthAtTipOfAngles/2, -200, -200], 400);
    }

    tcu([-picatinnyMountRiserWidth/2, 0, 0], [picatinnyMountRiserWidth, picatinnyMountFlatTopHeight+picatinnyMountRiserHeight, p22RailLength]);
}
