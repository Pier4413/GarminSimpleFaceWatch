import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Position;
import Toybox.Sensor;

class FirstWatchFaceView extends WatchUi.WatchFace {

    hidden const PI = 3.1415;

    /* Load the fonts */
    var fontXTiny = loadResource(Rez.Fonts.fontXTiny);
    var fontTiny = loadResource(Rez.Fonts.fontTiny);
    var fontMedium = loadResource(Rez.Fonts.fontMedium);
    var fontLarge = loadResource(Rez.Fonts.fontLarge);

    /* Mid size of fonts (used for alignement reason) */
    var size_2_XTiny = Toybox.Graphics.getFontHeight(fontXTiny)/2;
    var size_2_Tiny = Toybox.Graphics.getFontHeight(fontTiny)/2;
    var size_2_Medium = Toybox.Graphics.getFontHeight(fontMedium)/2;
    var size_2_Large = Toybox.Graphics.getFontHeight(fontLarge)/2;

    /* Init usefull vars (like center of the watch) */
    var centerX;
    var centerY;
    var radiusX;
    var radiusY;

    /* Empty data (like empty string for example) */
    var emptyText = "";

    /* Bluetooth informations to be used */
    var xPosBT = 25;
    var yPosBT = 100;
    var labelBT = "BTLabel";
    var textBT = "$1$";
    var colorBT = "Cyan";

    /* Notifications informations to be used */
    var xPosNT = 25;
    var yPosNT = 100;
    var labelNT = "NTLabel";
    var textNT = "$1$: $2$";
    var colorNT = "White";

    /* DND informations to be used */
    var xPosDND = 25;
    var yPosDND = 100;
    var labelDND = "DNDLabel";
    var textDND = "$1$";
    var colorDND = "Red";

    /* Date informations to be used */
    var xPosDate = 25;
    var yPosDate = 100;
    var labelDate = "DateLabel";
    var textDate = "$1$.\n$2$";
    var colorDate = "White";

    /* Time informations to be used */
    var xPosTime = 25;
    var yPosTime = 100;
    var labelTime = "TimeLabel";
    var textTime = "$1$:$2$";
    var colorTime = "Red";

    /* UTC informations to be used */
    var xPosUTC = 25;
    var yPosUTC = 100;
    var labelUTC = "UTCLabel";
    var textUTC = textTime;
    var colorUTC = "Green";

    /* Battery informations to be used */
    var xPosBattery = 25;
    var yPosBattery = 100;
    var labelBattery = "BatLabel";
    var textBattery = "$1$$2$";
    var colorBattery = "Green";

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

        // Calculation of the value
        centerX = dc.getWidth()/2;
        centerY = dc.getHeight()/2;
        radiusX = dc.getWidth()/2;
        radiusY = dc.getHeight()/2;

        // FORMULA : Here we calculate all the positions of elements. Because position can depend on font size, you must modify the formula if you modify the used font
        // FORMULA : Even if in theory center - radius is always equal to zero (due to our definitions above), we do the calculation because of the rounding and because our formulas could evolve for utilitarian reasons
        /* Bluetooth position calculation */
        xPosBT = centerX - radiusX + 25;
        yPosBT = centerY - 3*size_2_XTiny;

        /* Notifications position calculation*/
        xPosNT = centerX - radiusX + 25;
        yPosNT = centerY - size_2_XTiny;

        /* DND position calculation */
        xPosDND = centerX - radiusX + 25;
        yPosDND = centerY + size_2_XTiny;
        
        /* Date informations to be used */
        xPosDate = centerX + radiusX - 25;
        yPosDate = centerY - 2*size_2_Medium;

        /* Time position calculation */
        xPosTime = centerX;
        yPosTime = centerY - size_2_Large;

        /* UTC position calculation */
        xPosUTC = centerX;
        yPosUTC = centerY - radiusY + size_2_Medium + 5;

        /* Battery position calculation */
        xPosBattery = centerX;
        yPosBattery = centerY + radiusY - 2*size_2_Medium - 5;

        // Check if military mode. If yes then change the format of the time
        if (Application.Properties.getValue("UseMilitaryFormat")) {
            textTime = "$1$$2$";
            textUTC = textTime;
        }

        // Load the layout
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
      
        View.onUpdate(dc);

        // Hour and minute in the local timezone
        setTime();

        // Date in the local timezone
        setDate();

        // Data connexion with the phone (phone connected, notifications, DND mode, ...)
        setDatas();

        // Hour and minute in the UTC Timezone
        setUTCTime();

        // Step informations
        setStepsGoal(dc);

        // Battery infos
        setBatteryCharge(dc);
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }

    function setBatteryCharge(dc) as Void {
        
        /* Sys stats */
        var stats = System.getSystemStats();

        if(stats.charging) {
            fillLabel(labelBattery, colorBattery, fontMedium, xPosBattery, yPosBattery, Lang.format(textBattery, [loadResource(Rez.Strings.charging), emptyText]));
        }
        var startAngle = 360;
        var finalAngle = 270;
        var endAngle = startAngle + (finalAngle - startAngle)*stats.battery/100; // FORMULA : finalAngle - startAngle is negative for CLOCKWISE and positive for COUNTER_CLOCKWISE
        
        var image = Application.loadResource( Rez.Drawables.battery) as BitmapResource;
        dc.drawBitmap(centerX + radiusX - 65, centerY + radiusY - 65, image);
        drawAnArc(dc, centerX, centerY, radiusX - 10, Graphics.ARC_CLOCKWISE, startAngle, finalAngle, "Red");
        drawAnArc(dc, centerX, centerY, radiusX - 10, Graphics.ARC_CLOCKWISE, startAngle, endAngle, colorBattery);
    }

    function setDatas() as Void {

        /* Sys infos */
        var sysInfos = System.getDeviceSettings();

        if(sysInfos.phoneConnected) {
            fillLabel(labelBT, colorBT, fontXTiny, xPosBT, yPosBT, Lang.format(textBT, [loadResource(Rez.Strings.bt_short)]));
            if(sysInfos.notificationCount) {
                fillLabel(labelNT, colorNT, fontXTiny, xPosNT, yPosNT, Lang.format(textNT, [loadResource(Rez.Strings.nt_short), sysInfos.notificationCount]));
            } else {
                fillLabel(labelNT, colorNT, fontXTiny, xPosNT, yPosNT, Lang.format(textNT, [loadResource(Rez.Strings.nt_short), 0]));
            }
        } else {
            fillLabel(labelBT, colorBT, fontXTiny, xPosBT, yPosBT, emptyText);
            fillLabel(labelNT, colorNT, fontXTiny, xPosNT, yPosNT, Lang.format(textNT, [loadResource(Rez.Strings.nt_short), "--"]));
        }

        if(sysInfos has :doNotDisturb && sysInfos.doNotDisturb) {
            fillLabel(labelDND, colorDND, fontXTiny, xPosDND, yPosDND, Lang.format(textDND, [loadResource(Rez.Strings.dnd_short)]));
        } else {
            fillLabel(labelDND, colorDND, fontXTiny, xPosDND, yPosDND, emptyText);
        }
    }

    function setStepsGoal(dc) as Void {
         var stats = System.getSystemStats();

        var startAngle = 90;
        var finalAngle = 180;
        var endAngle = startAngle - (startAngle - finalAngle)*stats.battery/100; // FORMULA : finalAngle - startAngle is negative for CLOCKWISE and positive for COUNTER_CLOCKWISE
        
        var image = Application.loadResource( Rez.Drawables.battery) as BitmapResource;
        dc.drawBitmap(centerX + radiusX - 65, centerY + radiusY - 65, image);
        
        dc.setColor(Application.Properties.getValue(colorBattery) as Number, Application.Properties.getValue("White") as Number);
        dc.drawArc(centerX, centerY, radiusX - 10, Graphics.ARC_CLOCKWISE, startAngle, endAngle);
    }

    function setDate() as Void {
        // Get the current date
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

        // Update the view
        fillLabel(labelDate, colorDate, fontMedium, xPosDate, yPosDate, Lang.format(textDate, [today.day_of_week, today.day]));
    }

    function setTime() as Void {
        fillLabel(labelTime, colorTime, fontLarge, xPosTime, yPosTime, Lang.format(textTime, formatTime(System.getClockTime())));
    }

    function setUTCTime() as Void {
        fillLabel(labelUTC, colorUTC, fontTiny, xPosUTC, yPosUTC, Lang.format(textTime, formatTime(Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT))));
    }

    function fillLabel(identifier, color, font, xPos, yPos, text) {
        var label = View.findDrawableById(identifier) as Text;

        if(label != null) {
            label.setColor(Application.Properties.getValue(color) as Number);
            label.setLocation(xPos, yPos);
            label.setFont(font);
            label.setText(text);
        } else {
            System.println("Called an unknown label : "+identifier);
        }
    }

    function formatTime(time) {
        var hours = time.hour;
        var minutes = time.min;

        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        
        hours = hours.format("%02d");
        minutes = minutes.format("%02d");

        return [hours, minutes];
    }

    function drawAnArc(dc, x, y, startAngle, endAngle, radius, direction, color) {
        dc.setColor(Application.Properties.getValue(color) as Number, Application.Properties.getValue("Black") as Number);
        dc.drawArc(x, y, radius, direction, startAngle, endAngle);
    }
}
