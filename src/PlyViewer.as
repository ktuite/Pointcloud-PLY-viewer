package
{
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.*;
	
	[SWF(width="600", height="400", backgroundColor="#ffffff", frameRate="30")]
	
	public class PlyViewer extends Sprite
	{
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var cloud:CloudViewer;
		
		public function PlyViewer()
		{
			var w:int = 600;
			var h:int = 400;
			
			// Camera
			camera = new Camera3D(w, h);
			camera.x = 0;
			camera.y = 5;
			camera.z = 50;
			camera.near = 0;
			camera.lookAt(0,0,0);
			
			// Root group 
			var root:Group = new Group;
			scene = new Scene3D( "scene", this, camera, root );
			
			// get the name of the model and how much to scale it by
			var model_file:String = LoaderInfo(this.root.loaderInfo).parameters.model_file;
			var scale:int = LoaderInfo(this.root.loaderInfo).parameters.model_scale;
			
			// point cloud 
			cloud = new CloudViewer(root, camera, w, h, scale);
			addChild(cloud.status);
			
			// load the points 
			var cloudLoader:CloudLoader = new CloudLoader(cloud);
			cloudLoader.load(model_file);
			
			cloudLoader.addEventListener(CloudLoader.CLOUD_UPDATED, function (e:Event):void {
				cloud.status.text = cloud.numPoints.toString() + "/" + cloudLoader.vertexCount.toString() + " points";
			} );
			cloudLoader.addEventListener(CloudLoader.CLOUD_COMPLETE, function (e:Event):void {
				cloud.status.text = "Loading complete! " + cloud.numPoints.toString() + " points";
				stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler );
			} );
			
			// event listeners 
			stage.addEventListener(MouseEvent.MOUSE_DOWN, cloud.cloudMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, cloud.cloudMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, cloud.cloudMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, cloud.cloudMouseWheel);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, cloud.keyDownHandler);
			
		}
		
		private function enterFrameHandler( event : Event ) : void
		{
			scene.render();
		}
		
	}
}