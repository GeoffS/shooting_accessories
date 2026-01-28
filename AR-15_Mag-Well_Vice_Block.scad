include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

makeBlock = false;
makeTest = false;

firstLayerHeight = 0.2;
layerHeight = 0.2;
magWidth = 22.2; // Slightly less that 7/8"
magLength = 60.5;
magRibLength = 64;
magRibWidth = 11;
magStopHeight = 70;
magWellBottomAngle = 0; //10;

magCatchRampBottomZ = 60;
magCatchTopZ = 63.5;
magCatchX = 1.4;
magCatchY = 13.4;
magCatchZ = 6.5;

magStopExtraXY = 8;

magBlockViceX = magWidth + 2*magStopExtraXY;
magBlockViceY = magLength + 2*magStopExtraXY;
magBlockViceZ = 60;
magBlockZ = magStopHeight + magBlockViceZ;

magBlockDia = 4;
magBlockCZ = 1.5;

magBlockViceDia = 8;
magBlockViceCZ = 2.5;

// From pre-MAGIC conversion:
// ECHO: "magwellStopFactorY = 1.01543"
// ECHO: "magBlockViceY = 76.5"
// ECHO: "magwellStopY = 77.6804"
// ECHO: "magwellStopFactorY * magStopExtraXY = 8.12344"
// ECHO: "magwellStopExtraY = 6.12344"
// ECHO: "mainMagWellAngledStop() dy = 9.8754"
// ECHO: "mainMagWellAngledStop() dy = 9.8754"

// MAGIC!!
// Probably...
//vvvvvvvvvvvvvvvv
// magwellStopFactorY = 1/cos(magWellBottomAngle);
// magwellStopFactorY = 1.01543;
// echo(str("magwellStopFactorY = ", magwellStopFactorY));

// // MAGIC!!
// //  -----------vvvvvvv
// magwellStopY = 77.6804; //magwellStopFactorY * magBlockViceY;

// // MAGIC!!
// //  ----------------vvvvvvv
// magwellStopExtraY = 6.12344; //magwellStopFactorY * magStopExtraXY - 2;

// echo(str("magBlockViceY = ", magBlockViceY));
// echo(str("magwellStopY = ", magwellStopY));
// // echo(str("magwellStopFactorY * magStopExtraXY = ", magwellStopFactorY * magStopExtraXY));
// echo(str("magwellStopExtraY = ", magwellStopExtraY));

$fn = 180;

module exp()
{

}

module itemModule()
{
    viceSection();
    magWellAngledStop();

	// difference()
    // {
    //     union()
    //     {
    //         // Core that goes into the mag-wall:
    //         // magCore();
    //         // magCoreRib();
    //         // magCatchRamp();
            
    //         // Angled piece that goes into the vice:
    //         // hull()
    //         {
    //             viceSection();
    //             magWellAngledStop();
    //         }
    //     }

    //     // magCatchRecess();
    // }
}

module magCatchXform()
{
    children();
}

module magCatchRamp()
{

}

module magCatchRecess()
{

}

module magCore()
{
    // magCoreParams(x=magWidth, y=magLength, dy=magwellStopExtraY);
    magCoreParams(x=magWidth, y=magLength, dy=0);
}

module magCoreRib()
{
    dy = (magRibLength-magLength)/2 + magwellStopExtraY;
    magCoreParams(x=magRibWidth, y=magRibLength, dy=dy);
}

module magCoreParams(x, y, dy)
{
    mwdx = x/2 - magBlockDia/2;
    mwdy = y/2 - magBlockDia/2;
    translate([0, dy, -magBlockViceZ]) 
        hull() doubleX() doubleY() 
            translate([mwdx, mwdy, 0])
                simpleChamferedCylinderDoubleEnded(d=magBlockDia, h=magBlockZ, cz=magBlockCZ);
}

module angledStopXform()
{
    rotate([magWellBottomAngle,0,0]) children();
}

module viceSection()
{
    difference()
    {
        mainViceSection();
        // angledStopXform() tcu([-200,-200,-magBlockViceCZ-0.2], 400);
    }
}

viceDX = magBlockViceX/2 - magBlockViceDia/2;

module mainViceSection()
{
    vdy = magBlockViceY/2 - magBlockViceDia/2;
    echo("mainViceSection() vdy =", vdy);
    doubleY() 
        translate([viceDX, vdy, -magBlockViceZ]) 
            simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=magBlockViceZ, cz=magBlockViceCZ);
}

module magWellAngledStop()
{
    echo("magWellBottomAngle =", magWellBottomAngle);
    f = 1.0047; //1/cos(magWellBottomAngle);
    #rotate([3,0,0]) scale([1, f, 1]) difference()
    {
        mainViceSection();
        // tcu([-200,-200,-400-magBlockViceCZ], 400);
    }
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
    // tcu([magBlockViceX/2-magBlockViceDia/2-d, -400, -400], 800);
    tcu([-400, -200, -200], 400);
}

if(developmentRender)
{
    dx = magBlockViceX/2-magBlockViceDia/2;;
	display() translate([-dx, 0, 0]) itemModule();

    // displayGhost() tcu([-150, magBlockViceY/2, -150], 300);
    // displayGhost() tcu([-150, -300-magBlockViceY/2, -150], 300);

    // display() translate([100,0,0]) testModule();
}
else
{
	if(makeBlock) itemModule();
    if(makeTest) testModule();
}

module testModule()
{
    difference()
    {
        itemModule();
        tcy([0,0,-400+55], d=400, h=400);
        tcy([0,0,80], d=400, h=400);
    }
}
