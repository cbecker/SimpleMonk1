import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
using Toybox.System as Sys;

class TextAndFont
{
    public var text, font, color, trailingSpacePx;
    
    public function initialize( text, font, color ) {
      self.text = text;
      self.font = font;
      self.color = color;
      self.trailingSpacePx = 0;
    }
    
    public function addTrailingPx(value) {
    	self.trailingSpacePx += value;
    	return self;
    }
}

function drawTextCentered(x as Lang.Numeric, y as Lang.Numeric, dc as Dc, arr as Lang.Array<TextAndFont>) as Void {
	var textDims = new [arr.size()];
	
	var totalTextHeight = 0;
	var totalTextWidth = 0;
	for (var i=0; i < arr.size(); ++i) {
		textDims[i] = dc.getTextDimensions(arr[i].text, arr[i].font);
		
		textDims[i][0] += arr[i].trailingSpacePx;
		
		totalTextWidth += textDims[i][0];
		totalTextHeight += textDims[i][1];
	}
    
    var curX = x - totalTextWidth / 2;
    for (var i=0; i < arr.size(); ++i) {
    	dc.setColor(arr[i].color, Graphics.COLOR_TRANSPARENT);
    	dc.drawText(curX, y - textDims[i][1] / 2, 
        	arr[i].font, arr[i].text, Graphics.TEXT_JUSTIFY_LEFT);
        curX += textDims[i][0];
    }
}

class SimpleMonk1View extends WatchUi.WatchFace {

	private var m_needsRedraw;

    function initialize() {
    	self.m_needsRedraw = true;
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    	self.m_needsRedraw = true;
    }
    
    function drawTime(x as Lang.Numeric, y as Lang.Numeric, dc as Dc) as Void {
        // Get the current time and format it correctly
        var clockTime = System.getClockTime();
        
        var hours = clockTime.hour;
        var mins = clockTime.min.format("%02d");
        
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        hours = hours.format("%d");
        
        drawTextCentered(x, y, dc,
        	[new TextAndFont(hours, gHoursFont, Graphics.COLOR_WHITE).addTrailingPx(5), new TextAndFont(mins, gMinutesFont, Graphics.COLOR_WHITE)]);

    }
    
    function drawBatAndSteps(x as Lang.Numeric, y as Lang.Numeric, dc as Dc) as Void {
        
        var myStats = System.getSystemStats();
        var batPerc = myStats.battery.format("%.f");
        
        var hist = ActivityMonitor.getInfo();
        var stepsK = (hist.steps / 1000.0).format("%.1f");
        
        drawTextCentered(x, y, dc,
        	[new TextAndFont("S", gIconsFont, Graphics.COLOR_GREEN),
        	 new TextAndFont(" " + batPerc + " ", gSmallNumbersFont, Graphics.COLOR_WHITE), 
        	 new TextAndFont("V", gIconsFont, Graphics.COLOR_WHITE),
        	 new TextAndFont(" " + stepsK, gSmallNumbersFont, Graphics.COLOR_WHITE), 
        	 new TextAndFont(" K", gUltraSmallFont, Graphics.COLOR_WHITE)]);
    }
    
    function drawDate(x as Lang.Numeric, y as Lang.Numeric, dc as Dc) as Void {
    	var greg = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    	var dayName = greg.day_of_week.toUpper() + "  ";
    	var dayNum = greg.day.toString();
    	var monthName = "  " + greg.month.toUpper();
    	
    	drawTextCentered(x, y, dc, 
    		[new TextAndFont(dayName, gSmallFont, Graphics.COLOR_WHITE),
    		 new TextAndFont(dayNum ,gSmallNumbersBoldFont, Graphics.COLOR_WHITE),
    		 new TextAndFont(monthName, gSmallFont, Graphics.COLOR_WHITE)]);
    }
    
    function drawBar(x as Lang.Numeric, y as Lang.Numeric, 
    			     barWidth as Lang.Numeric, barHeight as Lang.Numeric, 
    				 curValue as Lang.Numeric, maxValue as Lang.Numeric, dc as Dc) as Void {
    				 
         var x0 = x - barWidth / 2;
         var x1 = x + barWidth / 2;
         var y0 = y - barHeight / 2;
         var y1 = y + barHeight / 2;
         
         // clamp current value
         curValue = curValue < maxValue ? curValue : maxValue;
         
         var filledWidth = Math.floor(curValue * barWidth / maxValue);
         var emptyWidth = barWidth - filledWidth;
         
		 dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
		 dc.fillRectangle(x0, y0, filledWidth, barHeight);
		 
		 dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
		 dc.fillRectangle(x0 + filledWidth, y0, emptyWidth, barHeight);
 	}
 	
 	// Draws the watch face from scratch.
 	// TODO: use incremental drawing if possible
 	function redraw(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK); 
	 	dc.clear();
	 	
        var dispWidth = dc.getWidth();
        var dispHeight = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); 

    	drawDate(dispWidth / 2, dispHeight * 0.17, dc);

		self.drawTime(dispWidth / 2, dispHeight / 2, dc);
		
    	drawTextCentered(dispWidth / 2, dispHeight * 0.75, dc,
        	[new TextAndFont("ONE", gSmallBoldFont, Graphics.COLOR_WHITE),  
        	 new TextAndFont(" - NET. NT", gSmallFont, Graphics.COLOR_WHITE)]);
        
    	self.drawBatAndSteps(dispWidth / 2, dispHeight * 0.85, dc);
    	
    	var hist = ActivityMonitor.getInfo();
    	var barWidth = 50;
    	var barHeight = 10;
    	var barCurValue = hist.activeMinutesWeek.total;
    	var barMaxValue = hist.activeMinutesWeekGoal;
    	drawBar(dispWidth / 2, dispHeight * 0.94,
    		barWidth, barHeight, barCurValue, barMaxValue, dc);
    }


    // Update the view
    function onUpdate(dc as Dc) as Void {
    
        // dirty hack: draw only when seconds are zero as we only display
        // minutes and we're ok with a 1-minute refresh rate
	    var clockTime = System.getClockTime();
	    if (self.m_needsRedraw || clockTime.sec == 0) {
	    	self.redraw(dc);
	    	self.m_needsRedraw = false;
	    }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
