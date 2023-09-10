package;

import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;

class Paths {
	public static function returnatlas(filename:String) {
		return FlxAtlasFrames.fromSparrow(returnimage(filename), Assets.getText(returnimage(filename, 'xml')));
	}

	public static function returnimage(filename:String, filetype = 'png') {
		return 'assets/images/$filename.$filetype';
	}

	public static function returnfont(fontname:String) {
		return 'assets/font/$fontname';
	}

    public static function returnsound(soundname:String) {
		return 'assets/sound/$soundname.ogg';
	}
}
