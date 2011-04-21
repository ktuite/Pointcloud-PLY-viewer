package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.utils.Endian;
	import flash.utils.Timer;
	import flash.ui.Keyboard;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Point3D;
	import sandy.core.data.Vertex;
	import sandy.core.scenegraph.*;
	import sandy.events.StarFieldRenderEvent;

	public class CloudViewer extends StarField
	{
		private var tGroupA:TransformGroup;
		private var tGroupB:TransformGroup;
		private var lastX:Number;
		private var lastY:Number;
		private var camera:Camera3D;
		
		public var numPoints:int;			// number of points in starfield 
		public var fixedPosition:Boolean; 	// for enabling and disabling motion 
		public var panInsteadOfRotate:Boolean;
		public var originalScale:Number;
		
		private var width:int;
		private var height:int;
		
		public var status:TextField;
		
		public function CloudViewer(root:Group, c:Camera3D, _w:int, _h:int, _scale:int, p_sName:String="")
		{
			super(p_sName);

			tGroupA = new TransformGroup();
			tGroupB = new TransformGroup();
			
			tGroupA.addChild(this);
			tGroupB.addChild(tGroupA)
			root.addChild(tGroupB);
			
			camera = c;
			fixedPosition = false;
			panInsteadOfRotate = false;
			
			numPoints = 0;

			
			originalScale = _scale;
			scale(originalScale);
			
			width = _w;
			height = _h;
			
			status = new TextField();
			status.text = "Loading...";
			status.width = 200;
		}
		
		public function addPoint(p1:Number, p2:Number, p3:Number, r:int, g:int ,b:int):void{
			// sandy uses left-hand coordinate system so flip the x coordinate
			stars.push(new Vertex(-1*p1, p2, p3));
			var color:uint = 0xFF000000 | (r << 16) | (g << 8) | (b << 0);
			starColors.push(color);
			numPoints++;
		}
		
		public function pointToString(i:int):String{	
			var str:String = "";
		
			str = str + stars[i].x + " " + stars[i].y + " " + stars[i].z + " ";
			
			var r:int = (starColors[i] >> 16) & 0xFF;
			var g:int = (starColors[i] >> 8) & 0xFF;
			var b:int = (starColors[i] >> 0) & 0xFF;
			
			str = str + r + " " + g + " " + b;
			return str;	
		}
		
		public function cloudMouseDown(event: MouseEvent):void {
			lastX = event.stageX;
			lastY = event.stageY;
		}
		
		public function cloudMouseUp(event: MouseEvent):void {

		}
		
		public function cloudMouseMove(event: MouseEvent):void {
			if (!fixedPosition && event.buttonDown) {
				var s:Number;
				if(event.altKey) {
					s = Math.pow(1.01, -(lastY - event.stageY));
					tGroupB.scaleX *= s;
					tGroupB.scaleY *= s;
					tGroupB.scaleZ *= s;
				} else if (event.shiftKey || panInsteadOfRotate) {
					tGroupB.translate(
						(lastX - event.stageX)/5.2,
						(lastY - event.stageY)/5.2,
						0);
				} else {
					if ( Math.abs(lastY - event.stageY) > 3)
						tGroupB.rotateAxis(1, 0, 0, (lastY - event.stageY) / -5.0);
					
					if ( Math.abs(lastX - event.stageX) > 3) 
					tGroupB.rotateAxis(0, 1, 0, (lastX - event.stageX) / 5.0);
				}
				
				lastX = event.stageX;
				lastY = event.stageY;
			}
		}
		
		public function cloudMouseWheel(event: MouseEvent):void {
			var s:Number = Math.pow(1.01, event.delta);
			tGroupB.scaleX *= s;
			tGroupB.scaleY *= s;
			tGroupB.scaleZ *= s;
		}
		
		public function keyDownHandler( event : KeyboardEvent ) : void
		{
			if (event.keyCode == 82){
				// r: reset
				resetModel();
			}
		}
		
		public function scale(s:Number):void{
			tGroupB.scaleX *= s;
			tGroupB.scaleY *= s;
			tGroupB.scaleZ *= s;
		}
		
		public function enableMovement(enable:Boolean=true):void{
			if (enable)
				fixedPosition = false;
			else
				fixedPosition = true;
		}
		
		public function getEnableMovement():Boolean{
			return !fixedPosition;
		}
		
		public function resetModel():void{
			tGroupB.resetCoords();
			tGroupB.scaleX = originalScale;
			tGroupB.scaleY = originalScale;
			tGroupB.scaleZ = originalScale;
		}
	
	}
}