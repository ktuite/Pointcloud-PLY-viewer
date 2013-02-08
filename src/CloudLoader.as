package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;

	public class CloudLoader extends EventDispatcher
	{
		public var cloud:CloudViewer;
		private var stream:URLStream;
		private var data:ByteArray;
		private var leftOvers:String;
		private var foundVertexCount:Boolean = false;
		public var vertexCount:int;
		
		public static const NEW_POINT:String = "new_point";
		public static const CLOUD_COMPLETE:String = "cloud_complete";
		public static const CLOUD_UPDATED:String = "cloud_updated";
				
		public function CloudLoader(cv:CloudViewer)
		{
			cloud = cv;
			stream = new URLStream();
			data = new ByteArray();
			
			leftOvers = "";
			
			stream.addEventListener( ProgressEvent.PROGRESS , streamProgress );
			stream.addEventListener( Event.COMPLETE , streamComplete );
		}
		
		public function load(path:String):void{
			try {
				stream.load( new URLRequest( path ) );
			}
			catch (error:Error){
			}
		}
		
		private function streamProgress(event:Event ):void
		{
			var latest:String = "";
			latest = leftOvers + stream.readUTFBytes(stream.bytesAvailable);
			
			var lines:Array = latest.split("\n");
			leftOvers = lines.pop();
			
			for (var i:int = 0; i < lines.length; i++){
				var line:String = lines[i].toString();
				
				line = line.replace(/^\s+|\s+$/gs, '');
				var d:Array = line.split(" ");
				var r:int, g:int, b:int, color:uint;
				if (!foundVertexCount && d.length == 3 && d[1] == "vertex"){
					foundVertexCount = true;
					vertexCount = d[2];
				}
				
				if (d.length == 9){
					r = d[6];
					g = d[7];
					b = d[8];
					cloud.addPoint(d[0], d[1], d[2], r, g, b);
					dispatchEvent(new Event(NEW_POINT));
				}
				else if (d.length == 6 || d.length == 7){
					r = d[3];
					g = d[4];
					b = d[5];
					color =  0xFF000000 | (r << 16) | (g << 8) | (b << 0);
					cloud.addPoint(d[0], d[1], d[2], r, g, b);
					dispatchEvent(new Event(NEW_POINT));
				}
			}
			
			dispatchEvent(new Event(CLOUD_UPDATED));
		}
		
		public function streamComplete( event:Event ):void
		{
			if ( stream.connected ) stream.close();
			dispatchEvent(new Event(CLOUD_COMPLETE));
		}
	}
}