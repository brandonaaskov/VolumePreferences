/**
 * Brightcove VolumePreferences (6 January 2011)
 *
 * REFERENCES:
 *	 Website: http://opensource.brightcove.com
 *	 Source: http://github.com/brightcoveos
 *
 * AUTHORS:
 *	 Brandon Aaskov <baaskov@brightcove.com>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the “Software”),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, alter, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to
 * whom the Software is furnished to do so, subject to the following conditions:
 *   
 * 1. The permission granted herein does not extend to commercial use of
 * the Software by entities primarily engaged in providing online video and
 * related services.
 *  
 * 2. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT ANY WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, SUITABILITY, TITLE,
 * NONINFRINGEMENT, OR THAT THE SOFTWARE WILL BE ERROR FREE. IN NO EVENT
 * SHALL THE AUTHORS, CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY WHATSOEVER, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE, INABILITY TO USE, OR OTHER DEALINGS IN THE SOFTWARE.
 *  
 * 3. NONE OF THE AUTHORS, CONTRIBUTORS, NOR BRIGHTCOVE SHALL BE RESPONSIBLE
 * IN ANY MANNER FOR USE OF THE SOFTWARE.  THE SOFTWARE IS PROVIDED FOR YOUR
 * CONVENIENCE AND ANY USE IS SOLELY AT YOUR OWN RISK.  NO MAINTENANCE AND/OR
 * SUPPORT OF ANY KIND IS PROVIDED FOR THE SOFTWARE.
 */

package
{
	import com.brightcove.api.APIModules;
	import com.brightcove.api.CustomModule;
	import com.brightcove.api.events.MediaEvent;
	import com.brightcove.api.modules.VideoPlayerModule;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	public class VolumePreferences extends CustomModule
	{
		private var _videoPlayerModule:VideoPlayerModule;
		private var _volumeSharedObject:SharedObject = SharedObject.getLocal('volume-preference');
		private var _videoMuted:Boolean = false;
		private var _currentVolume:Number;
		private var _volumeChangeTimer:Timer = new Timer(1000, 1);
		
		//----------------------------------------------------------------- INITIALIZATION
		public function VolumePreferences()
		{
			trace('@project VolumePreferences');
			trace('@author Brandon Aaskov (Brightcove)');
			trace('@lastModified 01.06.12 1334 EST');
			trace('@version 1.0.0');
		}
		
		override protected function initialize():void
		{
			_videoPlayerModule = player.getModule(APIModules.VIDEO_PLAYER) as VideoPlayerModule;
			
			_currentVolume = _videoPlayerModule.getVolume();
			setupEventListeners();
			setInitialVolume(_volumeSharedObject.data.volume, _volumeSharedObject.data.muted);
		}
		
		private function setupEventListeners():void
		{
			_videoPlayerModule.addEventListener(MediaEvent.VOLUME_CHANGE, onVolumeChange);
			_videoPlayerModule.addEventListener(MediaEvent.MUTE_CHANGE, onMuteChange);
			
			_volumeChangeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}
		
		private function setInitialVolume(pVolume:Number, pMuted:Boolean):void
		{
			if(pMuted)
			{
				_videoPlayerModule.mute();
			}
			else
			{
				_videoPlayerModule.setVolume(pVolume);	
			}
		}
		//----------------------------------------------------------------- 
		
		
		//----------------------------------------------------------------- EVENT LISTENERS
		private function onVolumeChange(pEvent:MediaEvent):void
		{
			_videoMuted = false;
			_currentVolume = _videoPlayerModule.getVolume();
			
			if(!_volumeChangeTimer.running)
			{
				_volumeChangeTimer.start();
			}
		}
		
		private function onMuteChange(pEvent:MediaEvent):void
		{
			saveVolumePreference(_currentVolume, _videoPlayerModule.isMuted());
		}
		
		private function onTimerComplete(pEvent:TimerEvent):void
		{
			trace(_currentVolume);
			saveVolumePreference(_currentVolume);
		}
		//-----------------------------------------------------------------
		
		
		//----------------------------------------------------------------- PRIVATE FUNCTIONS
		private function saveVolumePreference(pVolume:Number, pMuted:Boolean = false):void
		{
			_volumeSharedObject.data.volume = pVolume;
			_volumeSharedObject.data.muted = pMuted;
			
			_volumeSharedObject.flush();
		}
		//-----------------------------------------------------------------
	}
}