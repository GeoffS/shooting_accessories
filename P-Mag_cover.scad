include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

magY = 60.56;
magWithRibY = 64.14;
magX = 22.6;
magRibX = 11.8;
magRibOffsetZ = 11.17;
magFrontStepX = 4;
magFrontStepY = 5;
magFrontStepZ = 4.3;
magCatchZ = 28.34;
magCatchCtrY = 44.7;
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
magBodyExteriorCZ = 2;

exteriorXYCtrX = magBodyExteriorX/2 - magBodyExteriorDia/2;
exteriorXYCtr1Y = magBodyExteriorDia/2;
exteriorXYCtr2Y = magBodyExteriorY - magBodyExteriorDia/2;

catchCutsGapY = 0.6;
catchCutsY = 8;
catchCutsOffsetZ = 15;
catchOffsetY = magCatchCtrY + wallXY;

module itemModule()
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
    
    // Front step:
    intersection()
    {
        exterior();

        hull()
        {
            tcy([0, wallXY+magFrontStepY-magFrontStepX/2, 0], d=magFrontStepX, h=magFrontStepZ+wallZ);
            tcy([0, 0, 0], d=magFrontStepX+3, h=magFrontStepZ+wallZ);
        }
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
    }
}

module clip(d=0)
{
	// tcu([-200, -400+catchOffsetY+d, -10], 400);
    // tcu([-d, -200, -200], 400);
}

if(developmentRender)
{
	display() itemModule();
    // displayGhost() tcu([-magBodyInteriorX/2, wallXY, wallZ], [magBodyInteriorX, magBodyInteriorY, magCatchZ]);
}
else
{
	itemModule();
}
