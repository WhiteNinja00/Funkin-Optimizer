package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import flixel.text.FlxText;

using StringTools;

class State extends FlxState {
	var optimizedsize = 0.0;
	var originalsize = 0.0;
	var xmlsize = 0.0;
	var imagesize = 0.0;
	var jsonsize = 0.0;
	var audiosize = 0.0;
	var videosize = 0.0;
	var luasize = 0.0;
	var othersize = 0.0;

	var checks:FlxTypedGroup<FlxSprite>;
	var mbsize:FlxText;
	var mbsize2:FlxText;

	override public function create() {
		FlxG.cameras.bgColor = 0xff555555;

		lol('assets/');
		
		originalsize = (xmlsize + imagesize + jsonsize + audiosize + videosize + luasize + othersize) / 1048576;
		originalsize = FlxMath.roundDecimal(originalsize, 2);
		trace(originalsize);

		checks = new FlxTypedGroup<FlxSprite>();
		add(checks);

		var checkmark = new FlxSprite(10, 10);
		checkmark.ID = 0;
		checkmark.frames = returnatlas('images/checkmark');
		checkmark.animation.addByPrefix('unselected', 'idle unselected');
		checkmark.animation.addByPrefix('selected', "idle selected", 24, false);
		checkmark.animation.play('unselected');
		checks.add(checkmark);

		var fontsize = 26;
		var bordersize = 2;

		mbsize = new FlxText(10, FlxG.height - 10, FlxG.width - 800, 'optimized size ' + optimizedsize + " mb's (estimation)", fontsize);
		mbsize.setFormat('assets/font/vcr.ttf', fontsize, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		mbsize.borderSize = bordersize;
		mbsize.y -= mbsize.height;
		add(mbsize);

		mbsize2 = new FlxText(10, mbsize.y - 5, FlxG.width - 800, 'original size ' + originalsize + " mb's", fontsize);
		mbsize2.setFormat('assets/font/vcr.ttf', fontsize, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		mbsize2.borderSize = bordersize;
		mbsize2.y -= mbsize2.height;
		add(mbsize2);

		super.create();
	}

	override public function update(elapsed:Float) {
		checks.forEach(function(check:FlxSprite) {

		});

		super.update(elapsed);
	}

	function lol(directory:String = '') {
		if(sys.FileSystem.exists(directory)) {
			for (file in sys.FileSystem.readDirectory(directory)) {
				var path = haxe.io.Path.join([directory, file]);
				if (!sys.FileSystem.isDirectory(path)) {
					var stat:sys.FileStat = sys.FileSystem.stat(path);
					if(path.endsWith('.png') || path.endsWith('.jpeg')) {
						imagesize += stat.size;
					} else if(path.endsWith('.json')) {
						jsonsize += stat.size;
					} else if(path.endsWith('.wav') || path.endsWith('.mp3') || path.endsWith('.ogg')) {
						audiosize += stat.size;
					} else if(path.endsWith('.xml')) {
						xmlsize += stat.size;
					} else if(path.endsWith('.mov') || path.endsWith('.mp4')) {
						videosize += stat.size;
					} else if(path.endsWith('.lua')) {
						luasize += stat.size;
					} else {
						othersize += stat.size;
					}
					// do something with file
				} else {
					var directory = haxe.io.Path.addTrailingSlash(path);
					lol();
				}
			}
		}
	}

	function returnatlas(filename:String) {
		return FlxAtlasFrames.fromSparrow('assets/$filename.png', Assets.getText('assets/$filename.xml'));
	}
}
