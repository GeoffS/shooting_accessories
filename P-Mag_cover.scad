include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

makeAllGraphics = false;
makeJustSymbol = false;
makePlain = false;
// makeTest = false;

// RF Metal Magazine:
magX = 22.7;
magY = 60.55;  // A1-Mini PLA

magWithRibY = 64.14;
magRibX = 11.8;
magRibOffsetZ = 11.17;
magCatchZ = 28.34;
magCatchCtrY = 45.2;
magStopZ = 33.8;

magBodyInteriorX = magX;
magBodyInteriorRibX = magRibX;
magBodyInteriorY = magY + 0.5;
magBodyInteriorWithRibY = magWithRibY + 0.8; //0.5;

wallXY = 3;
//                   Bottom                                    Inside
//                  Graphics                    Core          Graphics
//      /------------------------------\   /------------\   /-----------\
wallZ = firstLayerHeight + 2*layerHeight + 10*layerHeight + 1*layerHeight;

echo(str("wallZ = ", wallZ));

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
catchCutsOffsetZ = wallZ + 2;
catchOffsetY = magCatchCtrY + wallXY;

$fn=180;

module cover(text=true, graphics=true)
{
	mainBody(text, graphics);

    // Catch bump:
    intersection()
    {
        exterior();

        magCatchBumpDia1 = 5.2;
        magCatchBumpDia2 = 2;
        magCatchBumpX = 1.2;
        magCatchBumpsOffsetX = -magBodyInteriorX/2;
        magCatchBumpsOffsetX1 = magCatchBumpsOffsetX + magCatchBumpX-0.2 - magCatchBumpDia1/2;
        magCatchBumpsOffsetX2 = magCatchBumpsOffsetX + magCatchBumpX     - magCatchBumpDia2/2;
        magCatchBumpsOffsetY1 = catchCutsY/2 - magCatchBumpDia1/2;
        magCatchBumpsOffsetY2 = catchCutsY/2 - magCatchBumpDia2/2;
        magCatchBumpOffsetZ1 = wallZ + magCatchZ + magCatchBumpDia1/2 - 1.17;
        magCatchBumpOffsetZ2 = wallZ + magCatchZ + magCatchBumpDia1/2 - 2.15;
        hull()
        {
            translate([magCatchBumpsOffsetX1, catchOffsetY, magCatchBumpOffsetZ1]) doubleY() tsp([0,magCatchBumpsOffsetY1,0], d=magCatchBumpDia1);
            translate([magCatchBumpsOffsetX2, catchOffsetY, magCatchBumpOffsetZ2]) doubleY() tsp([0,magCatchBumpsOffsetY2,0], d=magCatchBumpDia2);
        }
    }
    
    // Step to support the front of the magazine:
    translate([0, wallXY, 1]) hull()
    {
        
        magFrontStepZ = 7.9;
        frontStepZ = wallZ-1 + magFrontStepZ;

        magFrontStepX = 4.5;
        cornerDia = 1.5;
        frontStepFullY = 3;
        tcu([-magFrontStepX/2, -1, 0], [magFrontStepX, 1.1, frontStepZ]);
        doubleX() tcy([magFrontStepX/2-cornerDia/2, frontStepFullY-cornerDia/2, 0], d=cornerDia, h=frontStepZ);
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

module mainBody(text, graphics)
{
    difference()
    {
        exterior();        

        // Mag recess:
        tcu([-magBodyInteriorX/2, wallXY, wallZ], [magBodyInteriorX, magBodyInteriorY, 200]);

        // Rear rib recess:
        tcu([-magBodyInteriorRibX/2, wallXY, wallZ], [magBodyInteriorRibX, magBodyInteriorWithRibY, 200]);

        // Mag-catch cuts for springiness:
        translate([0, catchOffsetY, 0])
        {
            doubleY() tcu([-100, catchCutsY/2, catchCutsOffsetZ], [100, catchCutsGapY, 100]);
        }

        if(graphics)
        {
            // Cartridge outline on bottom:
            rotate180degressAroundTheCenter() translate([0,1.0,firstLayerHeight+2*layerHeight]) scale(0.34) translate([-34.8,0,-10]) 
                linear_extrude(height = 10, convexity = 10) import(file = "5.56 Outline.svg");

            if(text)
            {
                // Text on bottom:
                rotate180degressAroundTheCenter() translate([0.25, magBodyExteriorY/2, wallZ-layerHeight]) rotate([0,0,90])
                    linear_extrude(height = 10, convexity = 10) 
                        text("Defend Equality", 
                            font="Calibri:style=Bold",
                            size=5.8, 
                            valign="center", halign="center");
            }
        }
    }
}

module rotate180degressAroundTheCenter()
{
    translate([0, magBodyExteriorY/2, 0]) rotate([0,0,180]) translate([0, -magBodyExteriorY/2, 0]) children();
}

module clip(d=0)
{
	// tcu([-200, -400+catchOffsetY+d, -10], 400);
    // tcu([-200, magBodyExteriorY-10-d, -10], 400);

    tcu([-d, -200, -200], 400);
    // tcu([-400+d, -200, -200], 400);
    // tcu([-200, magBodyExteriorY/2, -200], 400);
}

if(developmentRender)
{
    display() translate([-40,0,0]) cover(text=false);
	display() cover();
    display() translate([ 40,0,0]) cover(graphics=false);
    display() translate([ 80,0,0]) test();
    displayGhost() tcu([-magBodyInteriorX/2, wallXY, wallZ], [magBodyInteriorX, magBodyInteriorY, magCatchZ]);

    // display() test();
}
else
{
	if(makeAllGraphics) cover();
    if(makeJustSymbol) cover(text=false);
    if(makePlain) cover(graphics=false);
    // if(makeTest) test();
}

module test()
{
    difference()
    {
        cover();
        tcu([-200, -200, wallZ+5*layerHeight], 400);
    }
}
