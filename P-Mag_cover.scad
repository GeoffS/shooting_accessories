include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

makeCover = false;
makeTest = false;

magY = 60.56;
magWithRibY = 64.14;
magX = 22.7; //22.6;
magRibX = 11.8;
magRibOffsetZ = 11.17;
magFrontStepX = 4.5;
magFrontStepZ = 7.9; //4.3;
magCatchZ = 28.34;
magCatchCtrY = 45.2; //44.7;
magStopZ = 33.8;

magBodyInteriorX = magX;
magBodyInteriorRibX = magRibX;
magBodyInteriorY = magY + 0.5;
magBodyInteriorWithRibY = magWithRibY + 0.5;

wallXY = 3;
wallZ = 2;

magBodyExteriorX = magBodyInteriorX + 2*wallXY;
magBodyExteriorY = magBodyInteriorWithRibY + 2*wallXY;
magBodyExteriorZ = magStopZ;

echo(str("magBodyExteriorX = ", magBodyExteriorX));
echo(str("magBodyExteriorY = ", magBodyExteriorY));

magBodyExteriorDia = 5;
magBodyExteriorCZ = 1.4;

exteriorXYCtrX = magBodyExteriorX/2 - magBodyExteriorDia/2;
exteriorXYCtr1Y = magBodyExteriorDia/2;
exteriorXYCtr2Y = magBodyExteriorY - magBodyExteriorDia/2;

catchCutsGapY = 0.6;
catchCutsY = 9;
catchCutsOffsetZ = 15;
catchOffsetY = magCatchCtrY + wallXY;

module cover()
{
	mainBody();

    // Catch bump:
    intersection()
    {
        exterior();

        magCatchBumpDia = 4;
        magCatchBumpOffsetZ = wallZ + magCatchZ + magCatchBumpDia/2 - 0.9;
        magCatchBumpsOffsetY = catchCutsY/2 - magCatchBumpDia/2;
        translate([-magBodyInteriorX/2-magCatchBumpDia/2+0.7, catchOffsetY, magCatchBumpOffsetZ]) hull() doubleY() tsp([0,magCatchBumpsOffsetY,0], d=magCatchBumpDia);
    }
    
    // Step to support the front of the magazine:
    translate([0, wallXY, 1]) hull()
    {
        frontStepFullY = 2.5;
        frontStepInsideY = 5.5;
        frontStepZ = wallZ-1 + magFrontStepZ;
        frontStepInsideDia = 2;
        tcu([-magFrontStepX/2, 0, 0], [magFrontStepX, 1.9, frontStepZ]);
        cornerDia = 2.5;
        doubleX() tcy([magFrontStepX/2-cornerDia/2-0.1, frontStepFullY, 0], d=cornerDia, h=frontStepZ);
        tcy([0, frontStepInsideY-frontStepInsideDia/2, 0], d=frontStepInsideDia, h=frontStepZ);
    }
}

module exterior()
{
    hull() 
    {
        doubleX() translate([exteriorXYCtrX,0,0]) 
        {
            translate([0,exteriorXYCtr1Y,0]) simpleChamferedCylinderDoubleEnded(d=magBodyExteriorDia, h=magBodyExteriorZ, cz=magBodyExteriorCZ);
            translate([0,exteriorXYCtr2Y,0]) simpleChamferedCylinderDoubleEnded(d=magBodyExteriorDia, h=magBodyExteriorZ, cz=magBodyExteriorCZ);
        }
    }
}

module mainBody()
{
    difference()
    {
        exterior();        

        // Mag recess:
        tcu([-magBodyInteriorX/2, wallXY, wallZ], [magBodyInteriorX, magBodyInteriorY, 200]);

        // Rear rib recess:
        tcu([-magBodyInteriorRibX/2, wallXY, wallZ+magRibOffsetZ], [magBodyInteriorRibX, magBodyInteriorWithRibY, 200]);
        dy = 1;
        tcu([-magBodyInteriorRibX/2, wallXY+dy, wallZ], [magBodyInteriorRibX, magBodyInteriorY+dy, 200]);

        // Mag-catch cuts for springiness:
        translate([0, catchOffsetY, 0])
        {
            doubleY() tcu([-100, catchCutsY/2, catchCutsOffsetZ], [100, catchCutsGapY, 100]);
        }

        // Cartridge outline on bottom:
        translate([0,4,firstLayerHeight+2*layerHeight]) scale(0.3) translate([-34.8,0,-10]) linear_extrude(height = 10, convexity = 10) import(file = "5.56 Outline.svg");
    }
}

module clip(d=0)
{
	// tcu([-200, -400+catchOffsetY+d, -10], 400);
    // tcu([-d, -200, -200], 400);
    // tcu([-200, magBodyExteriorY/2, -200], 400);
}

if(developmentRender)
{
	// display() cover();
    // displayGhost() tcu([-magBodyInteriorX/2, wallXY, wallZ], [magBodyInteriorX, magBodyInteriorY, magCatchZ]);

    display() test();
}
else
{
	if(makeCover) cover();
    if(makeTest) test();
}

module test()
{
    difference()
    {
        cover();
        tcu([-200, -200, firstLayerHeight+5*layerHeight], 400);
    }
}
