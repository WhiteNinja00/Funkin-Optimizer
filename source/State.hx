package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxCollision;

using StringTools;

class State extends FlxState {
	//options
	//name, variable, description
	var options:Array<Array<Dynamic>> = [
		['Shrink Spritesheets', 'shinksprsh', 'Shrinks the spritesheet and improves preformance'],
		['Minify luas', 'minlua', 'Shrinks lua files by making it 1 line (does not affect performance)']
	];


	//mb stuff
	var optimizedsize = 0.0;
	var originalsize = 0.0;
	var xmlsize = 0.0;
	var imagesize = 0.0;
	var jsonsize = 0.0;
	var audiosize = 0.0;
	var videosize = 0.0;
	var luasize = 0.0;
	var othersize = 0.0;

	//ui
	var checks:FlxTypedGroup<FlxSprite>;
	var checktext:FlxTypedGroup<FlxText>;
	var mbsize:FlxText;
	var mbsize2:FlxText;
	var description:FlxText;
	var bgcolor = 0xFF757575;

	//mouse stuff
	var mouseobject:FlxSprite;
	var mousescroll = 0.0;
	var curselected = -1;
	var oldcurselected = -1;

	override public function create() {
		FlxG.cameras.bgColor = bgcolor; //set bg color

		lol('assets/'); //load them assets!!!!
		

		//calculate the size
		originalsize = (xmlsize + imagesize + jsonsize + audiosize + videosize + luasize + othersize) / 1048576;
		originalsize = FlxMath.roundDecimal(originalsize, 2);


		//make mouse object
		mouseobject = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFFFFFFFF);
		add(mouseobject);


		//make ui
		checks = new FlxTypedGroup<FlxSprite>();
		add(checks);

		checktext = new FlxTypedGroup<FlxText>();
		add(checktext);

		var fontsize = 26;
		var bordersize = 2;

		for(i in 0...options.length) {
			var checkmark = new FlxSprite(10);
			checkmark.ID = i;
			checkmark.frames = Paths.returnatlas('checkmark');
			checkmark.animation.addByPrefix('unselected', 'idle unselected', 24);
			checkmark.animation.addByPrefix('selected', "idle selected", 24);
			checkmark.animation.play('unselected');
			checks.add(checkmark);

			var text = new FlxText(110, 0, FlxG.width - 800, options[i][0], fontsize);
			text.setFormat(Paths.returnfont('vcr.ttf'), fontsize, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
			text.borderSize = bordersize;
			text.y -= text.height;
			checktext.add(text);
		}

		var gradient:FlxSprite = new FlxSprite(0, FlxG.height).loadGraphic(Paths.returnimage('gradient'));
		gradient.y -= gradient.height;
		gradient.color = bgcolor;
		add(gradient);


		//make text
		mbsize = new FlxText(10, FlxG.height - 10, FlxG.width - 800, 'optimized size ' + optimizedsize + " mb's (estimation)", fontsize);
		mbsize.setFormat(Paths.returnfont('vcr.ttf'), fontsize, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		mbsize.borderSize = bordersize;
		mbsize.y -= mbsize.height;
		add(mbsize);

		mbsize2 = new FlxText(10, mbsize.y, FlxG.width - 800, 'original size ' + originalsize + " mb's", fontsize);
		mbsize2.setFormat(Paths.returnfont('vcr.ttf'), fontsize, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		mbsize2.borderSize = bordersize;
		mbsize2.y -= mbsize2.height;
		add(mbsize2);

		var coolfontsize = 18;
		var coolbordersize = 1.5;

		description = new FlxText(10, mbsize2.y - 12, FlxG.width, '', coolfontsize);
		description.setFormat(Paths.returnfont('vcr.ttf'), coolfontsize, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		description.borderSize = coolbordersize;
		description.y -= description.height;
		add(description);

		checkthing();

		super.create();
	}

	override public function update(elapsed:Float) {
		mouseobject.x = FlxG.mouse.x;
		mouseobject.y = FlxG.mouse.y;

		checks.forEach(function(check:FlxSprite) {
			check.color = 0xFFBFBFBF;
			if(FlxCollision.pixelPerfectCheck(mouseobject, check, 1)) {
				check.color = 0xFFFFFFFF;
				description.text = options[check.ID][2];
				curselected = check.ID;
				if(FlxG.mouse.justPressed) {
					FlxG.sound.play(Paths.returnsound('confirmMenu'));
					Reflect.setProperty(Variables, options[check.ID][1], !Reflect.getProperty(Variables, options[check.ID][1]));
					checkthing();
				}
			}
		});

		if(oldcurselected != curselected) {
			oldcurselected = curselected;
			FlxG.sound.play(Paths.returnsound('scrollMenu'));
		}

		if(FlxG.mouse.wheel != 0 && options.length > 3) {
			mousescroll += FlxG.mouse.wheel * 50;
			if(mousescroll > 0) {
				mousescroll = 0;
			}
			if(mousescroll < (-85 * (options.length - 3))) {
				mousescroll = -85 * (options.length - 3);
			}
			checkthing();
		}

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
					//do somethin with da file
				} else {
					var directory = haxe.io.Path.addTrailingSlash(path);
					lol();
				}
			}
		}
	}

	function checkthing() {
		checks.forEach(function(check:FlxSprite) {
			check.y = (10 + (check.ID * 100)) + mousescroll;
			if(Reflect.getProperty(Variables, options[check.ID][1])) {
				check.animation.play('selected');
				check.offset.set(8.5, 1);
			} else {
				check.animation.play('unselected');
				check.offset.set(0, 0);
			}
		});
		checktext.forEach(function(text:FlxSprite) {
			text.y = ((text.ID * 50) - 605) + mousescroll;
		});
	}
}
