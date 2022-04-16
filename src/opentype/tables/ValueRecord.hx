package opentype.tables;
class ValueRecord {
    public function new() {}
    public var xPlacement : Int;
    public var yPlacement : Int;
    public var xAdvance : Int;
    public var yAdvance : Int;

    public var xPlaDevice : Int;
    public var yPlaDevice : Int;
    public var xAdvDevice : Int;
    public var yAdvDevice : Int;    

    function toString():String return 'ValueRecord{$xPlacement, $yPlacement, $xAdvance, $yAdvance, $xPlaDevice, $yPlaDevice, $xAdvDevice, $yAdvDevice}';
}