package;

using StringTools;

class Minify {
    public static function execute(text:String) {
        var splittext:Array<String> = text.split('\n');
        var finalstring = '';
        for(i in 0...splittext.length) {
            var thing = splittext[i];
            if(!(thing.startsWith('//') || thing.startsWith('--'))) {
                finalstring += ' ' + thing;
            }
        }
        return finalstring;
    }
}
