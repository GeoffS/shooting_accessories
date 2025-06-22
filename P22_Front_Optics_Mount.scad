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

p22PicatinnyRailLength = 28.25;
p22PicatinnyRailNotchDepth = 1.8;
p22PicatinyRailFrontNotchZ = 6.0;
p22PicatinyRailBackNotchZ = p22PicatinyRailFrontNotchZ + 16.25;

p22ClearanceFromRailBottomToHighestPointOnSlideDuringInstallation = 51.6;
p22SlideWidth = 24.4;
p22DistFromFrontOfRailToCtrOfFirstSlot = 7.5;

clampScrewHoleDia = 4.4;
clampScrewHeadDia = 7.3;
clampScrewHeadZ = 4;
clampScrewNutDia = 8.0;
clampScrewNutZ = 3.0;
clampScrewZ = 30;
clampScrewExteriorDia = clampScrewNutDia + 3.8; //clampScrewNutDia*1.4 + 3;
clampScrewExteriorX = (clampScrewZ-0.0) + clampScrewNutZ;

clampCZ = 1;
clampX = clampScrewExteriorX/2 + 1*clampCZ;
clampOD = 14;
clampSplitX = 0.3;
clampOffsetY = -5;
clampCtrY = clampOD/2-clampCZ+clampOffsetY;
clampTopY = clampCtrY + clampOD/2;
clampBotY = clampCtrY - clampOD/2;

echo(str("clampTopY = ", clampTopY));

module itemModule()
{
    difference()
    {
        union()
        {
	        railClampExterior();
        }

        railClampInterior();
    }
}

module railClampExterior()
{
    hull()
    {
        doubleX() 
            translate([clampX-clampOD/2, clampCtrY, 0]) 
                simpleChamferedCylinderDoubleEnded(d=clampOD, h=p22PicatinnyRailLength, cz=clampCZ);
    }

    
    difference()
    {
        clampMountScrewsXform() 
        {
            hull()
            {
                translate([0,0,-clampScrewExteriorX/2]) 
                {
                    simpleChamferedCylinderDoubleEnded(d=clampScrewExteriorDia, h=clampScrewExteriorX, cz=1);
                    // bigD = clampScrewExteriorDia * 2.2;
                    // translate([0,10,0]) simpleChamferedCylinderDoubleEnded(d=bigD, h=clampScrewExteriorX, cz=1);
                }
            }
        }

        // Trim bottom of the screw exterior:
        tcu([-200, 0, -200], 400);
    }
}

module railClampInterior()
{
    p22RailInterior();

    // Split clamp in half:
    tcu([-clampSplitX/2, -15, -10], [clampSplitX, 20, 100]);

    // Hole for screws:
    ClampMountScrewHoles(); 

    // Clearance for bump just forward of the trigger guard:
    bumpDia = 37;
    difference()
    {
        translate([0,-1.5,0]) rotate([-17,0,0]) tcy([0,bumpDia/2,-10], d=bumpDia, h=20);
        doubleX() tcu([picatinnyMountFlatTopWidth/2, -200, -200], 400);
    }
}

module clampMountScrewsXform()
{
    translate([0, -clampScrewHoleDia/2+p22PicatinnyRailNotchDepth-0.3, p22PicatinyRailFrontNotchZ]) rotate([0, 90, 0]) children();
    translate([0, -clampScrewHoleDia/2+p22PicatinnyRailNotchDepth-0.3, p22PicatinyRailBackNotchZ]) rotate([0, 90, 0]) children();
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
        translate([0,0,-clampScrewExteriorX/2+clampScrewNutZ]) 
            rotate([0,0,0]) 
                //tcu([-clampScrewNutDia/2, -clampScrewNutDia/2, -100], [clampScrewNutDia, clampScrewNutDia, 100]);
                tcy([0, 0, -100], d=clampScrewNutDia, h=100, $fn=6);
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

        echo(str("picatinnyMountFlatTopHeight = ", picatinnyMountFlatTopHeight));
        tcu([-200, picatinnyMountFlatTopHeight, -200], 400);
        tcu([-200, -400, -200], 400);
    }

    // Extra space at the point of the rails:
    extraTipClearanceDia = 1.5;
    doubleX() tcy([p22MountWidthAtTipOfAngles/2-extraTipClearanceDia/5, picatinnyMountFlatTopHeight/2, p2RailOffsetZ], d=extraTipClearanceDia, h=p22RailLength);

    // Rail base:
    baseX = picatinnyMountRiserWidth + 2;
    baseOffsetY = 1;
    tcu([-baseX/2, baseOffsetY, p2RailOffsetZ], [baseX, picatinnyMountFlatTopHeight+picatinnyMountRiserHeight, p22RailLength]);
    // Rail base chamfering:
    doubleX() translate([baseX/2+1+1, clampTopY+1, p2RailOffsetZ]) rotate([0,0,-45-90]) tcu([-0, -10, p2RailOffsetZ], [10, 10, p22RailLength]);

}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
    // tcu([-200, -200, -400+p22PicatinyRailFrontNotchZ+d], 400);
}

if(developmentRender)
{
	display() itemModule();
    // displayGhost() p22RailGhost();
    displayGhost() gunGhost();
}
else
{
	itemModule();
}

module gunGhost()
{
    x = 24.5;
    y = 45.1;
    z = 100;
    difference()
    {
        union()
        {
            // Frame & slide:
            tcu([-x/2, 0, 0], [x, y, z]);
            tcu([-1.5, 0, 0], [3, 51.7, 15]);
        }
        // Trim off the rail part below the frame/slide:
        tcu([-200, -400+11.2, -1], 400);
    }
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
