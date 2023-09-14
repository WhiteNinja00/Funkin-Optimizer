package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxCollision;
import sys.FileSystem;

using StringTools;

class MainState extends FlxState {
	//options
	//name, variable, description
	var options:Array<Array<Dynamic>> = [
		//['JPEG Compression', 'jpegcomp', 'Slightly affects quality but decreases size'], // this shi take too long to code, gonna delay to other versions
		['Spritesheet cropping', 'shinksprsh', 'Does not affect quality and improves performance (may increse file size)'],
		['Minify Xmls', 'minxml', 'Shrinks xml files by making it 1 line (does not affect performance)'],
		['Minify luas', 'minlua', 'Shrinks lua files by making it 1 line (does not affect performance)'],
		['Minify Charts', 'minchart', 'Shrinks Charts by making it 1 line (does not affect performance)'],
		['Minify Character Json', 'minchar', 'Shrinks Character json by making it 1 line (does not affect performance)'],
		['Minify Week Jsons', 'minweek', 'Shrinks Week json files by making it 1 line (does not affect performance)']
	];


	//mb stuff
	var xmlsize = 0.0;
	var imagesize = 0.0;
	var chartsize = 0.0;
	var stagesize = 0.0;
	var charsize = 0.0;
	var weeksize = 0.0;
	var audiosize = 0.0;
	var videosize = 0.0;
	var luasize = 0.0;
	var spritesheetsize = 0.0;
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


		//make mouse object
		mouseobject = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFFFFFFFF);
		add(mouseobject);


		//make ui
		checks = new FlxTypedGroup<FlxSprite>();
		add(checks);

		checktext = new FlxTypedGroup<FlxText>();
		add(checktext);

		var fontsize = 22;
		var bordersize = 2;

		for(i in 0...options.length) {
			var checkmark = new FlxSprite(10);
			checkmark.ID = i;
			checkmark.frames = Paths.returnatlas('checkmark');
			checkmark.animation.addByPrefix('unselected', 'idle unselected', 24);
			checkmark.animation.addByPrefix('selected', "idle selected", 24);
			checkmark.animation.play('unselected');
			checks.add(checkmark);

			var otherfontsize = 26;

			var text = new FlxText(110, 0, FlxG.width - 120, options[i][0], otherfontsize);
			text.setFormat(Paths.returnfont('vcr.ttf'), otherfontsize, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
			text.ID = i;
			text.borderSize = bordersize;
			text.scrollFactor.set();
			checktext.add(text);
		}

		var gradient:FlxSprite = new FlxSprite(0, FlxG.height).loadGraphic(Paths.returnimage('gradient'));
		gradient.y -= gradient.height;
		gradient.color = bgcolor;
		add(gradient);


		//make text
		mbsize = new FlxText(10, FlxG.height - 10, FlxG.width - 800, '', fontsize);
		mbsize.setFormat(Paths.returnfont('vcr.ttf'), fontsize, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		mbsize.borderSize = bordersize;
		mbsize.y -= mbsize.height;
		add(mbsize);

		mbsize2 = new FlxText(10, mbsize.y, FlxG.width - 800, 'original size ' + getsize() + " mb's", fontsize);
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

		var nothing = true;

		checks.forEach(function(check:FlxSprite) {
			check.color = 0xFFBFBFBF;
			if(FlxCollision.pixelPerfectCheck(mouseobject, check, 1)) {
				check.color = 0xFFFFFFFF;
				description.text = options[check.ID][2];
				nothing = false;
				curselected = check.ID;
				if(FlxG.mouse.justPressed) {
					var property = !Reflect.getProperty(Variables, options[check.ID][1]);
					if(property) {
						FlxG.sound.play(Paths.returnsound('confirm'));
					} else {
						FlxG.sound.play(Paths.returnsound('back'));
					}
					Reflect.setProperty(Variables, options[check.ID][1], property);
					checkthing();
					mbsize.text = 'optimized size ' + getsize(true) + " mb's (estimation)";
				}
			}
		});

		if(nothing) {
			description.text = '';
		}

		if(oldcurselected != curselected) {
			oldcurselected = curselected;
			FlxG.sound.play(Paths.returnsound('change'));
		}

		if(FlxG.mouse.wheel != 0 && options.length > 3) {
			mousescroll += FlxG.mouse.wheel * 50;
			if(mousescroll > 0) {
				mousescroll = 0;
			}
			var maxscroll = -87.5 * (options.length - 3);
			if(mousescroll < maxscroll) { 
				mousescroll = maxscroll;
			}
			checkthing();
		}

		if(FlxG.keys.justPressed.ENTER) {
			FlxG.switchState(new Compress());
		}

		super.update(elapsed);
	}

	function lol(directory:String = '') {
		if(sys.FileSystem.exists(directory)) {
			for (file in sys.FileSystem.readDirectory(directory)) {
				var path = haxe.io.Path.join([directory, file]);
				if (!sys.FileSystem.isDirectory(path)) {
					var stat:sys.FileStat = sys.FileSystem.stat(path);
					/*
					if(path.endsWith('.png') || path.endsWith('.jpeg')) {
						var skip = false;
						if(!skip) {
							imagesize += stat.size;
						}
					} else if(path.endsWith('.json')) {
						jsonsize += stat.size;
					} else if(path.endsWith('.wav') || path.endsWith('.mp3') || path.endsWith('.ogg')) {
						audiosize += stat.size;
					} else if(path.endsWith('.mov') || path.endsWith('.mp4')) {
						videosize += stat.size;
					} */
					//not important rn!!!!
					if(path.endsWith('.png')) {
						if(!FileSystem.exists(path.replace('.png', '.xml'))) {
							imagesize += stat.size;
						}
					} else if(path.endsWith('.xml')) {
						xmlsize += stat.size;
						stat = sys.FileSystem.stat(path.replace('.xml', '.png'));
						spritesheetsize += stat.size;
					} else if(path.endsWith('.lua')) {
						luasize += stat.size;
					} else if(path.endsWith('.json')) {
						if(path.contains('data')) {
							chartsize += stat.size;
						} else if(path.contains('characters')) {
							charsize += stat.size;
						} else if(path.contains('stages')) {
							stagesize += stat.size;
						} else if(path.contains('weeks')) {
							weeksize += stat.size;
						}
					} else {
						othersize += stat.size;
					}
					//do somethin with da file
				} else {
					var cooldirectory = haxe.io.Path.addTrailingSlash(path);
					lol(cooldirectory);
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
			text.y = ((text.ID * 100) + 45) + mousescroll;
		});
	}

	function getsize(optimized = false) {
		var coolsize = 0.0;
		if(optimized) {
			var coollua = luasize;
			if(Variables.minlua) {
				coollua = percent(luasize, 86.359);
			}
			var coolxml = xmlsize;
			if(Variables.minxml) {
				coolxml = percent(xmlsize, 98.625);
			}
			var coolsheet = spritesheetsize;
			if(Variables.shinksprsh) {
				coolsheet = percent(spritesheetsize, 101.258);
			}
			var coolimage = imagesize + coolsheet;
			if(Variables.jpegcomp) {
				coolimage = percent(coolimage, 100);
			}
			var coolchart = chartsize;
			if(Variables.minchart) {
				coolchart = percent(chartsize, 59.079);
			}
			var coolchar = charsize;
			if(Variables.minchar) {
				coolchar = percent(charsize, 73.486);
			}
			var coolweek = weeksize;
			if(Variables.minweek) {
				coolweek = percent(weeksize, 85.267);
			}
			var cooljson = coolchart + coolchar + coolweek;
			coolsize = (coolxml + coolimage + cooljson + audiosize + videosize + coollua + othersize) / 1048576;
			coolsize = FlxMath.roundDecimal(coolsize, 2);
		} else {
			coolsize = (xmlsize + imagesize + spritesheetsize + chartsize + charsize + weeksize + audiosize + videosize + luasize + othersize) / 1048576;
			coolsize = FlxMath.roundDecimal(coolsize, 2);
		}
		return coolsize;
	}

	function percent(num:Float, percent:Float) {
		return ((num / 100) * percent);
	}
}
