include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

picatinnyMountWidth = 21.0;
picatinnyMountFlatTopHeight = 5.45; // 6.50 55.1
// picatinnyMountAngleWidth = 2.96; // 2.81 2.40
picatinnyMountAngleWidth = tan(45) * picatinnyMountFlatTopHeight/2;
picatinnyMountFlatTopWidth = 16.0;
picatinnyMountRiserHeight = 2.47; //2.99 3.87
p22MountWidthAtTipOfAngles = picatinnyMountFlatTopWidth + 2*picatinnyMountAngleWidth;
extraTipClearanceDia = 1.5;

echo(str("picatinnyMountAngleWidth = ", picatinnyMountAngleWidth));
picatinnyMountRiserWidth = 15.4;

p22PicatinnyRailLength = 28.25;
p22PicatinnyRailLengthExtension = 33.0;
p22PicatinnyRailNotchDepth = 1.8;
p22PicatinyRailFrontNotchZ = 6.0;
p22PicatinyRailBackNotchZ = p22PicatinyRailFrontNotchZ + 16.25;

// p22ClearanceFromRailBottomToHighestPointOnSlideDuringInstallation = 51.6;
// p22DistFromFrontOfRailToCtrOfFirstSlot = 7.5;

clampScrewHoleDia = 4.4;
clampScrewHeadDia = 7.4;
clampScrewHeadZ = 4;
clampScrewNutDia = 8.05;
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
            riserExterior();
        }

        railClampInterior();
    }
}

riserWallThickness = 6;
riserWallInsideX = 27; //31.5; //27;
riserWallBottomY = 0;
// MAGIC NUMBER!!! ----------------------vvvv
riserWallBottomCtrY = riserWallBottomY + 1; //0.53;
riserWallTopY = 43;
riserWallTopCtrY = riserWallTopY+riserWallThickness/2;
riserX = riserWallInsideX + 2*riserWallThickness;
riserForwardZ = p22PicatinnyRailLength;
riserBackZ = 55.5; // Back to the ejection port.

echo(str("riserX = ", riserX));

backRiserSidesMagicNumber1 = 6.75;
backRiserSidesMagicNumber2 = riserBackZ - riserForwardZ + 2*clampCZ;

module riserExterior()
{
    // Forward riser sides:
    doubleX() hull() translate([riserWallThickness/2+riserWallInsideX/2, 0, 0])
    {
        translate([0, riserWallBottomCtrY, 0]) simpleChamferedCylinderDoubleEnded(d=riserWallThickness, h=riserForwardZ, cz=clampCZ);
        translate([0,    riserWallTopCtrY, 0]) simpleChamferedCylinderDoubleEnded(d=riserWallThickness, h=riserForwardZ, cz=clampCZ);
    }

    // Forward riser top:
    hull() translate([0, riserWallTopCtrY, 0])
    {
        doubleX() translate([riserWallThickness/2+riserWallInsideX/2, 0, 0]) 
            simpleChamferedCylinderDoubleEnded(d=riserWallThickness, h=riserForwardZ, cz=clampCZ);
    }

    translate([0,0,riserForwardZ-2*clampCZ])
    {
        // Back riser sides:
        doubleX() hull() translate([riserWallThickness/2+riserWallInsideX/2, 0, 0]) backRiserXform()
        {
            // MAGIC NUMBERS:  ----------------------------------------vvvv
            simpleChamferedCylinderDoubleEnded(d=riserWallThickness, h=backRiserSidesMagicNumber1, cz=clampCZ);
            simpleChamferedCylinderDoubleEnded(d=riserWallThickness, h=backRiserSidesMagicNumber2, cz=clampCZ);
        }

        // Back riser top:
        hull() translate([0, riserWallTopCtrY, 0])
        {
            doubleX() 
                translate([riserWallThickness/2+riserWallInsideX/2, 0, 0]) 
                    simpleChamferedCylinderDoubleEnded(d=riserWallThickness, h=backRiserSidesMagicNumber2, cz=clampCZ);
        }
    }

    // Frame supports:
    difference()
    {
        topY = 13.8;
        x = riserX - riserWallThickness; //riserWallInsideX + 2*clampCZ;

        intersection() 
        {
            // Starting block:
            tcu([-x/2, 0, 0], [x, topY, 50]);

            // Trim rear angle:
            z0 = riserForwardZ - 2*clampCZ; // + 1.04;
            hull() backRiserXform()
            {
                tcu([-50,0,0], [100, 1, z0+backRiserSidesMagicNumber1]);
                tcu([-50,0,0], [100, 1, z0+backRiserSidesMagicNumber2]);
            }
        }

        // Trim inside:
        insideX = 24.4;
        tcu([-insideX/2, 0, -10], [insideX, 20, 200]);

        // Chamfer top:
        cz = 0.6;
        doubleX() 
            translate([insideX/2+1+cz, topY+1, 0]) 
                rotate([0,0,-45-90]) 
                    tcu([-3, -10, -10], [10, 10, 200]);
    }
}

module riserInterior()
{
    
}

module backRiserXform()
{
    // MAGIC NUMBER:  ----------------vvvv
    translate([0, riserWallBottomCtrY+1.75, 0]) children(0);
    translate([0,    riserWallTopCtrY, 0]) children(1);
}

module railClampExterior()
{
    hull()
    {
        // Main clamp section:
        doubleX() 
            translate([riserX/2-clampOD/2, clampCtrY, 0]) 
                simpleChamferedCylinderDoubleEnded(d=clampOD, h=p22PicatinnyRailLength, cz=clampCZ);

        // Clamp extension back to end of rail:
        extensionODAdj = 3.5; //clampOD - riserWallThickness; //3.5;
        extensionOD = clampOD - extensionODAdj;
        echo(str("extensionODAdj = ", extensionODAdj));
        echo(str("extensionOD = ", extensionOD));
        doubleX() 
            translate([riserX/2-clampOD/2+extensionODAdj/2, clampCtrY+extensionODAdj/2, 0]) 
                simpleChamferedCylinderDoubleEnded(d=extensionOD, h=p22PicatinnyRailLengthExtension, cz=clampCZ);
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
        translate([0, -1.5, p22PicatinnyRailLength]) rotate([17,0,0]) tcy([0, bumpDia/2,-10], d=bumpDia, h=20);
        // MAGIC NUMBER: vvvvvvvvv
        doubleX() tcu([15.5/2+0.45, -200, -200], 400);
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
                tcy([0, 0, -100], d=clampScrewNutDia, h=100, $fn=6);
    }
}

module p22RailInterior()
{
    p22RailLength = 100;
    p2RailOffsetZ = -10;

    // Rail:
    difference()
    {
        // union()
        hull()
        {
            doubleX() 
                translate([p22MountWidthAtTipOfAngles/2+0.2, picatinnyMountFlatTopHeight/2, p2RailOffsetZ]) 
                    rotate([0,0,-45-90]) 
                        tcu([-0, -10, 0], [10, 10, p22RailLength]);
        }

        echo(str("picatinnyMountFlatTopHeight = ", picatinnyMountFlatTopHeight));
        tcu([-200, picatinnyMountFlatTopHeight, -200], 400);
        tcu([-200, -400, -200], 400);
    }

    // Extra space at the point of the rails:
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
    tcu([0, -200, -200], 400);
    // tcu([-200, -200, -400+p22PicatinyRailFrontNotchZ+d], 400);
}

if(developmentRender)
{
	display() itemModule();

    // displayGhost() p22RailGhost();
    // displayGhost() gunGhost();
}
else
{
	itemModule();
}

module gunGhost()
{
    x = 24.5;
    z = 100;
    difference()
    {
        union()
        {
            // // Frame & slide with clearance to disassemble:
            // 
            // tcu([-x/2, 0, 0], [x, 45.1, z]);
            // tcu([-1.5, 0, 0], [3, 51.7, 15]);

            // Frame & slide without clearance to disassemble:
            tcu([-x/2, 0, 0], [x, 36, z]);
            tcu([-1.5, 0, 0], [3, 41.5, 15]);
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
