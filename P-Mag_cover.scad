include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

makeAllGraphics = false;
makeJustSymbol = false;
makePlain = false;
// makeTest = false;

// RF metal and P-Mag plastic Magazines:
magX = 22.7;
magY = 60.55;  // A1-Mini PLA

magWithRibY = 64.14;
magRibX = 11.8;
magRibOffsetZ = 11.17;
magCatchZ = 28.34;
magCatchCtrY = 44.9;
magStopZ = 33.8;

magBodyInteriorX = magX;
magBodyInteriorRibX = magRibX;
magBodyInteriorY = magY + 0.5;
magBodyInteriorWithRibY = magWithRibY + 0.8;

// Y measured form the front.
metalMagFollowerRecessX1 = 5.4;
metalMagFollowerRecessX2 = 10.9;
metalMagFollowerRecessY1 = 19;
metalMagFollowerRecessY2 = 51;
metalMagFollowerRecessZ = 1.0;

wallXY = 3;
//                   Bottom                                    Inside
//                  Graphics                    Core          Graphics
//      /------------------------------\   /------------\   /-----------\
wallZ = firstLayerHeight + 2*layerHeight + 14*layerHeight + 1*layerHeight;

echo(str("wallZ = ", wallZ));

magBodyExteriorX = magBodyInteriorX + 2*wallXY;
magBodyExteriorY = magBodyInteriorWithRibY + 2*wallXY;
magBodyExteriorZ = wallZ + magStopZ - 1;

echo(str("magBodyExteriorX = ", magBodyExteriorX));
echo(str("magBodyExteriorY = ", magBodyExteriorY));
echo(str("magBodyExteriorZ = ", magBodyExteriorZ));

magBodyExteriorDia = 5;
magBodyExteriorCZ = 1.4;

exteriorXYCtrX = magBodyExteriorX/2 - magBodyExteriorDia/2;
exteriorXYCtr1Y = magBodyExteriorDia/2;
exteriorXYCtr2Y = magBodyExteriorY - magBodyExteriorDia/2;

catchCutsGapY = 1.0; //0.6;
catchCutsY = 9.5;
catchCutsOffsetZ = 20; //15; //wallZ + 2;
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
        magCatchBumpDia2 = 2.6;
        magCatchBumpX = 1.35;
        magCatchBumpsOffsetX = -magBodyInteriorX/2;
        magCatchBumpsOffsetX1 = magCatchBumpsOffsetX + magCatchBumpX-0.2 - magCatchBumpDia1/2;
        magCatchBumpsOffsetX2 = magCatchBumpsOffsetX + magCatchBumpX     - magCatchBumpDia2/2;
        magCatchBumpsOffsetY1 = catchCutsY/2 - magCatchBumpDia1/2;
        magCatchBumpsOffsetY2 = catchCutsY/2 - magCatchBumpDia2/2;
        magCatchBumpOffsetZ = wallZ + magCatchZ;
        magCatchBumpOffsetZ1 = magCatchBumpOffsetZ + magCatchBumpDia1/2 - 0.4;
        magCatchBumpOffsetZ2 = magCatchBumpOffsetZ + magCatchBumpDia2/2 + 0.15;
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

        // Recess for follower in metal magazine:
        translate([(metalMagFollowerRecessX2+metalMagFollowerRecessX1)/2-wallXY, metalMagFollowerRecessY1+wallXY, wallZ])
        {
            d = 3;
            dx = (metalMagFollowerRecessX2-metalMagFollowerRecessX1)/2 - d/2;
            cz = 1;
            h = metalMagFollowerRecessY2 - metalMagFollowerRecessY1 + 2*cz;
            translate([0, 0, d/2-metalMagFollowerRecessZ]) rotate([-90,0,0]) hull() doubleX() translate([dx, 0, 0]) simpleChamferedCylinderDoubleEnded(d=d, h=h, cz=1);
        }

        // Mag-catch cuts for springiness:
        translate([0, catchOffsetY, 0]) doubleY() catchSlot();

        if(graphics)
        {
            // Cartridge outline on bottom:
            rotate180degressAroundTheCenter() translate([0,1.0,firstLayerHeight+2*layerHeight]) scale(0.34) translate([-34.8,0,-10]) 
                linear_extrude(height = 10, convexity = 10) import(file = "5.56 Outline.svg");

            if(text)
            {
                // Text on inside:
                rotate180degressAroundTheCenter() translate([4.8, magBodyExteriorY/2, wallZ-layerHeight]) rotate([0,0,90])
                    linear_extrude(height = 10, convexity = 10) 
                        text("Defend Equality", 
                            font="Calibri:style=Bold",
                            size=5.0, 
                            valign="center", halign="center");
            }
        }
    }
}

module catchSlot()
{
    // %tcu([-100, catchCutsY/2, catchCutsOffsetZ], [100, catchCutsGapY, 100]);
    translate([-magBodyExteriorX/2+wallXY+1, catchCutsY/2, catchCutsOffsetZ]) catchCut(d=10, dy=catchCutsGapY, a=15, h=15);
}

module catchCut(d, dy, a, h)
{
    translate([-10, d/2, 0]) difference()
    {
        da = asin((dy/2)/h);
        echo(str("catchCut() da = ", da));

        catchCutHalf(d=d, a=a, x=10, y=15, z=100);
        translate([-1,0,0]) catchCutHalf(d=d-dy, a=a-da, x=20, y=20, z=101);
    }
}

module catchCutHalf(d, a, x, y, z)
{
    r = d/2;

    tcu([0,-r,0], [x, y, z]);
    rotate([0,90,0]) tcy([0,0,0], d=d, h=x);
    rotate([a,0,0]) tcu([0,-r,-z], [x, y, z]);
}

module rotate180degressAroundTheCenter()
{
    translate([0, magBodyExteriorY/2, 0]) rotate([0,0,180]) translate([0, -magBodyExteriorY/2, 0]) children();
}

module clip(d=0)
{
	// tcu([-200, -400+catchOffsetY+d, -10], 400);
    // tcu([-200, magBodyExteriorY-10-d, -10], 400);

	// tcu([-200, -400+metalMagFollowerRecessY1+3+d, -10], 400);
    // tcu([-200, metalMagFollowerRecessY2-3-d, -10], 400);

    // tcu([-d, -200, -200], 400);
    // tcu([-400+d, -200, -200], 400);
    // tcu([-200, magBodyExteriorY/2, -200], 400);
}

if(developmentRender)
{
    // display() translate([-40,0,0]) cover(text=false);
	display() cover();
    // display() translate([ 40,0,0]) cover(graphics=false);
    // display() translate([ 80,0,0]) test();

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
