include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

mm = 25.4;

makeBufferFrontPiece = false;
makeBufferRearPiece = false;

bufferTubeLength = 175 + 2.89; // Meas. from carbine lover kit.
bufferTubeID = 1.0 * mm; // Meas. from carbine lower.

lightSpringLength = 127; // Hillman from Ace Hardware.
lightSpringOD = 16.5; // Approx. meas. Hillman from Ace Hardware.

bufferSpringAtFullExtensionZ = lightSpringLength - 4; // Compressed 4mm

bufferSpringGuidRodOD = 10;

bcgExtensionPastUpperWhenInRearPosition = 40; // Needs re-measurement.

bufferOD = bufferTubeID - 1;
bufferSpringRecessDia = lightSpringOD + 1;

// Front piece calculations:
bufferFrontZ = 60;
bufferFrontCZ = 7*layerHeight;
bufferFrontSpringRecessZ = 30;

echo(str("bufferFrontCZ = ", bufferFrontCZ));

// The rear piece calculations:
bufferSpringFrontFromFrontExtendedZ = bufferFrontZ - bufferFrontSpringRecessZ;
bufferSpringFrontFromRearExtendedZ = bufferTubeLength - bufferSpringFrontFromFrontExtendedZ;

bufferSpringRearFromRearExtendedZ = bufferSpringFrontFromRearExtendedZ - bufferSpringAtFullExtensionZ;

bufferRearZ = 75;

springLengthAfFullCompression = bufferSpringAtFullExtensionZ - bcgExtensionPastUpperWhenInRearPosition;
spfcPct = springLengthAfFullCompression/lightSpringLength * 100;
echo(str("Compressed Spring = ", springLengthAfFullCompression, "mm (", spfcPct, "%)"));

module bufferFrontPiece()
{
	difference()
    {
        simpleChamferedCylinderDoubleEnded(d=bufferOD, h=bufferFrontZ, cz=bufferFrontCZ);

        tcy([0,0,bufferFrontZ-bufferFrontSpringRecessZ], d=bufferSpringRecessDia, h=100);
        springCZ = 7*layerHeight;
        translate([0,0,bufferFrontZ-bufferSpringRecessDia/2-springCZ]) cylinder(d2=40, d1=0, h=20);
    }
}

module bufferRearPiece()
{
	difference()
    {
        simpleChamferedCylinderDoubleEnded(d=bufferOD, h=bufferRearZ, cz=bufferFrontCZ);

        tcy([0,0,bufferSpringRearFromRearExtendedZ], d=bufferSpringRecessDia, h=100);
        springCZ = 7*layerHeight;
        translate([0,0,bufferRearZ-bufferSpringRecessDia/2-springCZ]) cylinder(d2=40, d1=0, h=20);
    }
}

module clip(d=0)
{
	tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	// display() bufferRearPiece();
    // display() translate([-40,0,0]) bufferFrontPiece();

    // display() bufferRearPiece();
    // display() translate([0,0,bufferTubeLength]) rotate([180,0,0]) bufferFrontPiece();
    // displayGhost() tcy([0,0,bufferSpringRearFromRearExtendedZ], d=lightSpringOD, h=bufferSpringAtFullExtensionZ);
    // displayGhost() difference()
    // {
    //     tcy([0,0,-3], d=bufferTubeID+4, h=bufferTubeLength+3);
    //     tcy([0,0,0], d=bufferTubeID, h=200);
    // };

    translate([-40,0,0]) fullStack(compressionZ = 0);
    translate([  0,0,0]) fullStack(compressionZ=bcgExtensionPastUpperWhenInRearPosition);
}
else
{
	if(makeBufferFrontPiece) bufferFrontPiece();
    if(makeBufferRearPiece) bufferRearPiece();
}

module fullStack(compressionZ)
{
    display() bufferRearPiece();
    display() translate([0,0,bufferTubeLength-compressionZ]) rotate([180,0,0]) bufferFrontPiece();
    displayGhost() tcy([0,0,bufferSpringRearFromRearExtendedZ], d=lightSpringOD, h=bufferSpringAtFullExtensionZ-compressionZ);
    displayGhost() difference()
    {
        tcy([0,0,-3], d=bufferTubeID+4, h=bufferTubeLength+3);
        tcy([0,0,0], d=bufferTubeID, h=200);
    };
}
