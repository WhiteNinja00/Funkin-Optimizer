package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import flixel.FlxState;
import openfl.display.JPEGEncoderOptions;
import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import openfl.utils.ByteArray;
import haxe.io.Bytes;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

using StringTools;

class Compress extends FlxState {
    //ui
	var bgcolor = 0xFF757575;
    var text:FlxText;
    var fontsize = 26;
	var bordersize = 2;
    var defaulttext = 'Compressing...\nplease do not tab out';

    //things
    var compressing = false;
    var error = false;
    var stopapp = false;
    var curerror:Array<Dynamic> = [];

    //image
    public static var image:FlxSprite;

	override public function create() {
        image = new FlxSprite();
        add(image);

        var realbg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, bgcolor);
        add(realbg);
        
		FlxG.cameras.bgColor = bgcolor; //set bg color

        text = new FlxText(0, 0, FlxG.width - 20, defaulttext, fontsize);
		text.setFormat(Paths.returnfont('vcr.ttf'), fontsize, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		text.borderSize = bordersize;
        text.screenCenter();
		add(text);

		super.create();
        
        new FlxTimer().start(0.1, loadthecompresser, 1); //so the text can load
	}

	override public function update(elapsed:Float) {
        if(!stopapp) {
            if(!compressing) {
                if(FlxG.keys.justPressed.ESCAPE) {
                    FlxG.switchState(new MainState());
                }
                if(error) {
                    if(FlxG.keys.justPressed.ENTER) {
                        text.text = defaulttext;
                        text.screenCenter();
                        new FlxTimer().start(0.1, loadthecompresser, 1); //so the text can load
                        compressing = true;
                    }
                }   
            }
        }

		super.update(elapsed);
	}

    function loadthecompresser(timer:FlxTimer) {
        curerror = execute(error);
        error = false;
        text.text = textreturn(curerror);
        text.screenCenter();
        dostuff();
        compressing = false;
    }

    function textreturn(thing:Array<Dynamic>) {
        switch(thing[0]) {
            case 0:
                return 'optimization complete\npress ESC to return';
            case 1:
                return 'error\nare you sure you want to continue without deleting the "' + thing[1] + '" folder?\npress ENTER to continue\n press ESC to return';
            case 2:
                return 'error\nthe "assets" folder is missing\nclose the app and reopen once\nthe "assets" folder is added';
            default:
                return 'ERROR!!!!\nUNIDENTIFIED ERROR\nREPORT TO GITHUB IMMEDIATELY\nhttps://github.com/WhiteNinja00/Funkin-Optimizer';
        }
    }

    function dostuff() {
        switch(curerror[0]) {
            case 0:
            case 1:
                error = true;
            case 2:
                stopapp = true;
            default:
                stopapp = true;
        }
    }

    public static function execute(skip:Bool = false):Array<Dynamic> {
        var defaultfoldername = 'assetsoptimized'; //if you wanna change the name of the exported folder change this!! and do NOT change it to "assets"
        if(!FileSystem.exists('assets/')) {
            return [2];
        }
        if(FileSystem.exists('./' + defaultfoldername + '/') && !skip) {
            return [1, defaultfoldername];
        }
        FileSystem.createDirectory('./$defaultfoldername/');
        //checkfolders('assets/', defaultfoldername);
        Sys.command('Xcopy assets ' + defaultfoldername + ' /H /C /I /S /D');
        checkfiles('assets/', defaultfoldername);
        return [0];
    }

    /*
    public static function checkfolders(directory:String, folder:String) {
        if(sys.FileSystem.exists(directory)) {
			for (file in sys.FileSystem.readDirectory(directory)) {
				var path = haxe.io.Path.join([directory, file]);
				if (sys.FileSystem.isDirectory(path)) {
					var cooldirectory = haxe.io.Path.addTrailingSlash(path);
                    Sys.command('Xcopy ' + cooldirectory + ' ' + cooldirectory.replace('assets', folder));
                    checkfiles(cooldirectory, folder);
				}
			}
		}
    }
    */

    public static function checkfiles(directory:String, folder:String) {
        if(sys.FileSystem.exists(directory)) {
			for (file in sys.FileSystem.readDirectory(directory)) {
				var path = haxe.io.Path.join([directory, file]);
				if (!sys.FileSystem.isDirectory(path)) {
                    var newpath = path.replace('assets', folder);
                    if(path.endsWith('.png')) {
                        if(Variables.jpegcomp) {
                            image.loadGraphic(openfl.display.BitmapData.fromFile(path));
                            savepng(image.pixels, newpath);
                        }
                    } else if(path.endsWith('.xml')) {
                        if(Variables.shinksprsh) {
                            savepng(cropsheet(path), newpath);
                        }
                        if(Variables.minxml) {
                            sys.io.File.saveContent(newpath, minify(sys.io.File.getContent(path)));
                        }
                    } else if(path.endsWith('.lua')) {
                        if(Variables.minlua) {
                            sys.io.File.saveContent(newpath, minify(sys.io.File.getContent(path)));
                        }
                    }
				} else {
					var cooldirectory = haxe.io.Path.addTrailingSlash(path);
					checkfiles(cooldirectory, folder);
				}
			}
		}
    }

    public static function minify(text:String) {
        var splittext:Array<String> = text.toString().split('\n');
        var cleanedtext:Array<String> = [];
        for(word in splittext) {
            var start = false;
            var wordstring = '';
            for(letter in word.split('')) {
                if(!start) {
                    if(letter != ' ' && letter != '	') {
                        start = true;
                    }
                }
                if(start) {
                    wordstring += letter;
                }
            }
            if(!wordstring.startsWith('//') && !wordstring.startsWith('--') && !wordstring.startsWith('<!--') && wordstring != '') {
                cleanedtext.push(wordstring);
            }
        }
        var finalstring = '';
        for(word in cleanedtext) {
            finalstring += word;
        }
        return finalstring;
    }

    public static function cropsheet(path:String) {
        var imagepath = path.replace('.xml', '.png');
        image.loadGraphic(openfl.display.BitmapData.fromFile(imagepath));
        var box = [0.0, 0.0];
        for(f in FlxAtlasFrames.fromSparrow(openfl.display.BitmapData.fromFile(imagepath), sys.io.File.getContent(path)).frames) {
            if(f.frame.right > box[0]) {
                box[0] = f.frame.right;
            }
            if(f.frame.bottom > box[1]) {
                box[1] = f.frame.bottom;
            }
        }
        image.clipRect = new FlxRect(0, 0, box[0], box[1]);
        image.updateHitbox();
        return image.pixels;
    }

    public static function savepng(bitdata:BitmapData, path:String) {
        var byteArray:ByteArray = new ByteArray();
        if(Variables.jpegcomp) {
            bitdata.encode(bitdata.rect, new JPEGEncoderOptions(), byteArray);
        } else {
            bitdata.encode(bitdata.rect, new PNGEncoderOptions(), byteArray);
        }
        sys.io.File.saveBytes(path, Bytes.ofData(byteArray));
    }
}
