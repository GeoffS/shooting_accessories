include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

mm = 25.4;

makeBufferFrontPiece = false;
makeBufferRearPiece = false;
makeBufferFrontPieceNoGuide = false;
makeBufferRearPieceNoGuide = false;

bufferTubeLength = 175 + 2.89; // Meas. from carbine lover kit.
bufferTubeID = 1.0 * mm; // Meas. from carbine lower.

lightSpringLength = 127; // Hillman from Ace Hardware.
lightSpringOD = 16.5; // Approx. meas. Hillman from Ace Hardware.

bufferSpringAtFullExtensionZ = lightSpringLength - 4; // Compressed 4mm

guideRodOD = 10;

bcgExtensionPastUpperWhenInRearPosition = 40; // Needs re-measurement.

bufferOD = bufferTubeID - 1;
bufferSpringRecessDia = lightSpringOD + 1;

// Front piece calculations:
bufferFrontZ = 60;
bufferFrontCZ = 7*layerHeight;
bufferFrontSolidAboveSpring = 20;
bufferFrontSpringRecessZ = bufferFrontZ - bufferFrontSolidAboveSpring;

bufferFrontSpringRecessPositionAtFullExtensionZ = bufferTubeLength - bufferFrontSolidAboveSpring;
bufferFrontSpringRecessPositionAtFullCompressionZ = bufferFrontSpringRecessPositionAtFullExtensionZ - bcgExtensionPastUpperWhenInRearPosition;

echo(str("bufferFrontSpringRecessPositionAtFullExtensionZ = ", bufferFrontSpringRecessPositionAtFullExtensionZ));
echo(str("bufferFrontSpringRecessPositionAtFullCompressionZ = ", bufferFrontSpringRecessPositionAtFullCompressionZ));

// The rear piece calculations:
bufferSpringFrontFromFrontExtendedZ = bufferFrontZ - bufferFrontSpringRecessZ;
bufferSpringFrontFromRearExtendedZ = bufferTubeLength - bufferSpringFrontFromFrontExtendedZ;

bufferSpringRearFromRearExtendedZ = bufferSpringFrontFromRearExtendedZ - bufferSpringAtFullExtensionZ;

bufferRearZ = 75;

// Just for display to make sure we're not abusing the spring:
springLengthAfFullCompression = bufferSpringAtFullExtensionZ - bcgExtensionPastUpperWhenInRearPosition;
spfcPct = springLengthAfFullCompression/lightSpringLength * 100;
echo(str("Compressed Spring = ", springLengthAfFullCompression, "mm (", spfcPct, "%)"));

// Guide-Rod Calculations:
guideRodRecessDia = guideRodOD + 1.5;
guideRodFrontRecessZ = 15;
guideRodRearRecessZ = 20;

guideRodRearOffsetZ = bufferSpringRearFromRearExtendedZ - guideRodRearRecessZ;
guideRodZ = bufferFrontSpringRecessPositionAtFullCompressionZ - guideRodRearOffsetZ + guideRodFrontRecessZ - 3;

echo(str("guideRodZ = ", guideRodZ));

// $fn = 180;

module bufferFrontPiece(springGuide)
{
	difference()
    {
        // Exterior:
        simpleChamferedCylinderDoubleEnded(d=bufferOD, h=bufferFrontZ, cz=bufferFrontCZ);

        // Spring recess:
        tcy([0,0,bufferFrontZ-bufferFrontSpringRecessZ], d=bufferSpringRecessDia, h=100);
        springCZ = 7*layerHeight;
        translate([0,0,bufferFrontZ-bufferSpringRecessDia/2-springCZ]) cylinder(d2=40, d1=0, h=20);

        // Guide-Rod recess:
        if(springGuide)
        {
            tcy([0,0,bufferFrontZ-bufferFrontSpringRecessZ-guideRodFrontRecessZ], d=guideRodRecessDia, h=100);
            d2 = bufferSpringRecessDia - nothing;
            translate([0,0,bufferFrontZ-bufferFrontSpringRecessZ-guideRodRecessDia/2-1.5]) cylinder(d2=d2, d1=0, h=d2/2);
        }
    }
}

module bufferRearPiece(springGuide)
{
	difference()
    {
        simpleChamferedCylinderDoubleEnded(d=bufferOD, h=bufferRearZ, cz=bufferFrontCZ);

        // Spring recess:
        tcy([0,0,bufferSpringRearFromRearExtendedZ], d=bufferSpringRecessDia, h=100);
        springCZ = 7*layerHeight;
        translate([0,0,bufferRearZ-bufferSpringRecessDia/2-springCZ]) cylinder(d2=40, d1=0, h=20);

        // Guide-Rod recess:
        if(springGuide)
        {
            d = guideRodOD + 0.4;
            tcy([0,0,guideRodRearOffsetZ], d=d, h=100);
            d2 = bufferSpringRecessDia - nothing;
            translate([0,0,bufferSpringRearFromRearExtendedZ-d/2-4*layerHeight]) cylinder(d2=d2, d1=0, h=d2/2);
        }
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

    // translate([-40,0,0]) fullStack(compressionZ=0, showSpring=true);
    // translate([  0,0,0]) fullStack(compressionZ=bcgExtensionPastUpperWhenInRearPosition, showSpring=true);

    // translate([-40,0,0]) fullStack(compressionZ=0, showGuideRod=true);
    // translate([  0,0,0]) fullStack(compressionZ=bcgExtensionPastUpperWhenInRearPosition, showGuideRod=true);

    // display() bufferFrontPiece();
    display() bufferRearPiece();
    translate([-80,0,0]) fullStack(compressionZ=0, springGuide=false, showSpring=true);
    translate([-40,0,0]) fullStack(compressionZ=bcgExtensionPastUpperWhenInRearPosition, springGuide=false, showSpring=true);
}
else
{
	if(makeBufferFrontPiece) bufferFrontPiece(springGuide=true);
    if(makeBufferRearPiece) bufferRearPiece(springGuide=true);
	if(makeBufferFrontPieceNoGuide) bufferFrontPiece(springGuide=false);
    if(makeBufferRearPieceNoGuide) bufferRearPiece(springGuide=false);
}

module fullStack(compressionZ, springGuide, showSpring=false, showGuideRod=false)
{
    display() bufferRearPiece(springGuide=springGuide);
    display() translate([0,0,bufferTubeLength-compressionZ]) rotate([180,0,0]) bufferFrontPiece(springGuide=springGuide);

    // Spring:
    if(showSpring) displayGhost() tcy([0,0,bufferSpringRearFromRearExtendedZ], d=lightSpringOD, h=bufferSpringAtFullExtensionZ-compressionZ);

    // Guide-Rod:
    if(showGuideRod && springGuide) displayGhost() tcy([0,0,guideRodRearOffsetZ], d=guideRodOD, h=guideRodZ);
    
    // BufferTube:
    displayGhost() difference()
    {
        tcy([0,0,-3], d=bufferTubeID+4, h=bufferTubeLength+3);
        tcy([0,0,0], d=bufferTubeID, h=200);
    };
}
