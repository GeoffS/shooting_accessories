include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

mm = 25.4;

makeBufferFrontPiece = false;
makeBufferRearPiece = false;

buffferTubeLength = 175 + 2.89; // Meas. from carbine lover kit.
bufferTubeID = 1.0 * mm; // Meas. from carbine lower.

lightSpringLength = 127; // Hillman from Ace Hardware.
lightSpringOD = 16.5; // Approx. meas. Hillman from Ace Hardware.

bcgExtensionPastUpperWhenInRearPosition = 40; // Needs re-measurement.

bufferOD = bufferTubeID - 1;
bufferSpringRecessDia = lightSpringOD + 1;

bufferFrontZ = 60;
bufferFrontCZ = 8*layerHeight;
bufferFrontSpringRecessZ = 30;

echo(str("bufferFrontCZ = ", bufferFrontCZ));

module bufferFrontPiece()
{
	difference()
    {
        simpleChamferedCylinderDoubleEnded(d=bufferOD, h=bufferFrontZ, cz=bufferFrontCZ);

        tcy([0,0,bufferFrontZ-bufferFrontSpringRecessZ], d=bufferSpringRecessDia, h=100);
        springCZ = 4*layerHeight;
        translate([0,0,bufferFrontZ-bufferSpringRecessDia/2-springCZ]) cylinder(d2=40, d1=0, h=20);
    }
}

module bufferRearPiece()
{
	
}

module clip(d=0)
{
	tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() bufferFrontPiece();
}
else
{
	if(makeBufferFrontPiece) bufferFrontPiece();
    if(makeBufferRearPiece) bufferRearPiece();
}
