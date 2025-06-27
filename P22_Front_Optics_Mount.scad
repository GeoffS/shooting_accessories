include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

m4ClearanceDia = 4.4;
m4HeadClearanceDia = 7.5;
m4SocketHeadZ = 4;
m4NutDia = 8.05; // Hex, $fn=6
m4NutZ = 3.0;

m3ClearanceDia = 3.4;
m3HeadClearanceDia = 6;
m3SocketHeadZ = 3;
m3NutDia = 7.55; // Square, $fn=4
m3NutZ = 2.4;

picatinnyMountWidth = 21.0;
picatinnyMountFlatTopHeight = 5.45; // 6.50 55.1
// picatinnyMountAngleWidth = 2.96; // 2.81 2.40
picatinnyMountAngleWidth = tan(45) * picatinnyMountFlatTopHeight/2;
picatinnyMountFlatTopWidth = 16.0;
picatinnyMountRiserHeight = 2.47; //2.99 3.87
p22MountWidthAtTipOfAngles = picatinnyMountFlatTopWidth + 2*picatinnyMountAngleWidth + 0.4;
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

clampScrewHoleDia = m4ClearanceDia;
clampScrewHeadDia = m4HeadClearanceDia;
clampScrewHeadZ = m4SocketHeadZ;
clampScrewNutDia = m4NutDia;
clampScrewNutZ = m4NutZ;
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
        riserInterior();
        rmrMountHoles();
    }
}

riserWallThickness = 6;
riserWallInsideX = 27; //31.5; //27;
riserWallBottomY = 0;
// MAGIC NUMBER!!! ----------------------vvvv
riserWallBottomCtrY = riserWallBottomY + 1; //0.53;
riserWallTopY = 40;
riserWallTopCtrY = riserWallTopY + riserWallThickness/2;
riserX = riserWallInsideX + 2*riserWallThickness;
riserForwardZ = p22PicatinnyRailLength;
riserBackZ = 91; //55.5; // Back to the ejection port, max. = 91mm

echo(str("riserX = ", riserX));

backRiserSidesMagicNumber1 = 15; //6.75;
backRiserSidesMagicNumber2 = riserBackZ - riserForwardZ + 2*clampCZ;
backRiserSidesMagicNumber3 = -0.02; //0.03; //1.75;
backRiserSidesMagicNumber4 = -15;  // Height of back end of the riser.

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
        doubleX() hull() 
        {
            backRiserTopCylinder();
            translate([riserWallThickness/2+riserWallInsideX/2, 0, 0]) backRiserXform()
            {
                simpleChamferedCylinderDoubleEnded(d=riserWallThickness, h=backRiserSidesMagicNumber1, cz=clampCZ);
                simpleChamferedCylinderDoubleEnded(d=riserWallThickness, h=backRiserSidesMagicNumber2, cz=clampCZ);
            }
        }

        // Back riser top:
        hull() doubleX() backRiserTopCylinder();
    }

    // Frame supports:
    difference()
    {
        topY = 13.8 + 0.8;
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

module backRiserTopCylinder()
{
    translate([0, riserWallTopCtrY, 0])
    {
        translate([riserWallThickness/2+riserWallInsideX/2, 0, 0]) 
            simpleChamferedCylinderDoubleEnded(d=riserWallThickness, h=backRiserSidesMagicNumber2, cz=clampCZ);
    }
}

module riserInterior()
{
    translate([0, riserWallTopY, 0]) 
    {
        d1 = 12;
        d2 = 1;
        
        translate([0, -d1/2+riserWallThickness*0.4, 0])
        {
            // Center cylinder:
            tcy([0, 0, -10], d=d1, h=100);

            // End chamfers:
            translate([0,0,riserBackZ/2]) doubleZ() translate([0,0,riserBackZ/2-d1/2-1]) cylinder(d2=20, d1=0, h=10);
        }
    }
}

module backRiserXform()
{
    // MAGIC NUMBERS:  -----------------vvvvv
    translate([0, riserWallBottomCtrY + backRiserSidesMagicNumber3, 0]) children(0);
    translate([0,    riserWallTopCtrY + backRiserSidesMagicNumber4, 0]) children(1);
}

rmrHoleCtrsX = 18.8;
rmrHoleCtrsZ = 19.0; // From rear edge
rmrZ = 45.3;
rmrHolesDia = m3ClearanceDia;
rmrNutDia = m3NutDia;
rmrNutfn = 4;
rmrNutAngle = 0;
rmrNutZ = m3NutZ;
rmrNutExtraZ = 2.0;

echo(str("rmrNutZ = ", rmrNutZ));

rmrOffsetZ = riserBackZ - clampCZ - rmrHolesDia/2 - rmrHoleCtrsZ;

module rmrMountHoles()
{
    difference()
    {
        doubleX() translate([rmrHoleCtrsX/2, riserWallTopY, rmrOffsetZ]) rotate([-90,0,0])
        {
            // Through hole:
            tcy([0,0,-7], d=rmrHolesDia, h=20);

            // Nut recess:
            rotate([0,0,rmrNutAngle]) 
            {
                tcy([0,0,-10+rmrNutZ+rmrNutExtraZ], d=rmrNutDia, h=10, $fn=rmrNutfn);
                roundOpeningDia = rmrNutDia + 3;
                hull()
                {
                    tcy([0,0,-10+rmrNutExtraZ], d=rmrNutDia, h=10, $fn=rmrNutfn);
                    tcy([0,0,-10], d=roundOpeningDia, h=10);
                }
            }
        }
        // Trim anything that cuts into the riser side:
        doubleX() tcu([riserWallInsideX/2, -10, 0], 100);
    }
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
    // tcu([0, -200, -200], 400);
    // tcu([-200, -200, -400+p22PicatinyRailFrontNotchZ+d], 400);
    // tcu([rmrHoleCtrsX/2-d, -200, -200], 400);
    // tcu([-200,-200,50], 400);
    // tcu([riserWallThickness/2+riserWallInsideX/2,-200, -200], 400);
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
