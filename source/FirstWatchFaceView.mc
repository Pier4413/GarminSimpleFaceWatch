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
    var fontXLarge = loadResource(Rez.Fonts.fontXLarge);
    var fontXXLarge = loadResource(Rez.Fonts.fontXXLarge);

    /* Mid size of fonts (used for alignement reason) */
    var size_2_XTiny = Toybox.Graphics.getFontHeight(fontXTiny)/2;
    var size_2_Tiny = Toybox.Graphics.getFontHeight(fontTiny)/2;
    var size_2_Medium = Toybox.Graphics.getFontHeight(fontMedium)/2;
    var size_2_Large = Toybox.Graphics.getFontHeight(fontLarge)/2;
    var size_2_XLarge = Toybox.Graphics.getFontHeight(fontXLarge)/2;
    var size_2_XXLarge = Toybox.Graphics.getFontHeight(fontXXLarge)/2;

    /* Init usefull vars (like center of the watch) */
    var centerX;
    var centerY;
    var radiusX;
    var radiusY;

    /* Empty data (like empty string for example) */
    var emptyFormat = "$1$"; // The empty format
    var emptyText = ""; // The empty text
    var noData = "--"; // The no data text
    var emptyArc = "Red"; // The empty arc color
    var backgroundColor = "Black"; // The background color
    var numberFormat = "%02d"; // The number format
    var emptyCircle = "Red"; // For the circle empty
    var defaultForeground = 0xFFFFFF as Number; // Default value for foreground
    var defaultBackground = 0x000000 as Number; // Default value for background

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
    var textDate = "$1$\n$2$";
    var colorDate = "White";

    /* Time informations to be used */
    var xPosTime = 25;
    var yPosTime = 100;
    var labelTime = "TimeLabel";
    var textTime = "$1$:$2$";
    var colorTime = "Red";
    var militaryOption = "UseMilitaryFormat";

    /* UTC informations to be used */
    var xPosUTC = 25;
    var yPosUTC = 100;
    var labelUTC = "UTCLabel";
    var textUTC = "UTC\n$1$:$2$";
    var colorUTC = "Green";

    /* Battery informations to be used */
    var xPosBattery = 25;
    var yPosBattery = 100;
    var labelBattery = "BatLabel";
    var textBattery = "$1$$2$";
    var colorBattery = "Green";

    /* Steps informations to be used */
    var xPosSteps = 25;
    var yPosSteps = 100;
    var labelSteps = "StepsLabel";
    var textSteps = "$1$/$2$";
    var colorSteps = "Green";

    /* HR informations to be used */
    var xPosHR = 25;
    var yPosHR = 100;
    var labelHR = "HRLabel";
    var textHR = "$1$";
    var colorHR = "Green";

    /* Altitude informations to be used */
    var xPosAltitude = 25;
    var yPosAltitude = 100;
    var labelAltitude = "AltitudeLabel";
    var textAltitude = "$1$$2$";
    var colorAltitude = "Green";

    /* Temperature informations to be used */
    var xPosTemperature = 25;
    var yPosTemperature = 100;
    var labelTemperature = "TemperatureLabel";
    var textTemperature = "$1$$2$";
    var colorTemperature = "Green";

    /* Rain informations to be used */
    var xPosRain = 25;
    var yPosRain = 100;
    var labelRain = "RainLabel";
    var textRain = "$1$%";
    var colorRain = "Green";

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
        yPosDate = centerY - 2*size_2_Tiny;

        /* Time position calculation */
        xPosTime = centerX;
        yPosTime = centerY - size_2_XXLarge;

        /* UTC position calculation */
        xPosUTC = centerX;
        yPosUTC = centerY - radiusY + size_2_Medium + 5;

        /* Battery position calculation */
        xPosBattery = centerX;
        yPosBattery = centerY + radiusY - 2*size_2_Medium - 5;

        /* Steps position calculation*/
        xPosSteps = centerX;
        yPosSteps = centerY - radiusY + 2*size_2_Medium + 5;

        /* HR position calculation*/
        xPosHR = centerX - radiusX/2 + 15;
        yPosHR = centerY + radiusY/2;

        /* Altitude position calculation*/
        xPosAltitude = centerX + radiusX/2 - 15;
        yPosAltitude = centerY + radiusY/2;

        /* Temperature position calculation*/
        xPosTemperature = centerX;
        yPosTemperature = centerY + radiusY/4;

        /* Rain position calculation*/
        xPosRain = centerX;
        yPosRain = centerY + 2*radiusY/3;

        

        // Load the layout
        setLayout(Rez.Layouts.WatchFace(dc));

        dc.setPenWidth(3);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
      
        View.onUpdate(dc);

        /* INFO Load and work on the components */
        setBatteryCharge(dc); // INFO : Battery component
        setDND(dc); // INFO : DND Mode Component
        setNotificationsAndPhone(dc); // INFO : Notifications number and phone connexion component
        setHeartRate(dc); // INFO : Heartrate component
        setAltitude(dc); // INFO : Altitude component
        setRain(dc); // INFO : Rain chance component
        setTemperature(dc); // INFO : Temperature component
        setStepsGoal(dc); // INFO : Steps goal/done component
        setTime(dc); // INFO : Time (hour minute) component
        setUTCTime(dc); // INFO : UTC Time component
        setDate(dc); // INFO : Date component
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }

    /**
     * Component of the battery level
     * @param dc The device context
     */
    function setBatteryCharge(dc) as Void {
        
        /* Sys stats */
        var stats = System.getSystemStats();

        if(stats.charging) {
            fillLabel(labelBattery, colorBattery, fontMedium, xPosBattery, yPosBattery, textBattery, [loadResource(Rez.Strings.charging), emptyText]);
        }
        var startAngle = 270;
        var finalAngle = 360;
        var endAngle = startAngle + (finalAngle - startAngle)*stats.battery/100; // FORMULA : finalAngle - startAngle is negative for CLOCKWISE and positive for COUNTER_CLOCKWISE
        
        var image = Application.loadResource( Rez.Drawables.battery) as BitmapResource;
        dc.drawBitmap(centerX + radiusX - 3*image.getHeight()-1, centerY + radiusY - 3*image.getHeight()-1, image);
        drawAnArc(dc, centerX, centerY, startAngle, finalAngle, radiusX - 5, chooseDirection(startAngle, finalAngle), emptyArc);
        if(endAngle - startAngle > 1) {
            drawAnArc(dc, centerX, centerY, startAngle, endAngle, radiusX - 5, chooseDirection(startAngle, finalAngle), colorBattery);
        }
    }

    /**
     * Component of the DND mode
     * @param dc The device context
     */
    function setDND(dc) as Void {
        var sysInfos = System.getDeviceSettings();

        if(sysInfos has :doNotDisturb && sysInfos.doNotDisturb) {
            fillLabel(labelDND, colorDND, fontXTiny, xPosDND, yPosDND, textDND, [loadResource(Rez.Strings.dnd_short)]);
        } else {
            fillLabel(labelDND, colorDND, fontXTiny, xPosDND, yPosDND, emptyFormat, [emptyText]);
        }
    }

    /**
     * Component of the notifications and phone connectivity mode
     * @param dc The device context
     */
    function setNotificationsAndPhone(dc) as Void {
        var sysInfos = System.getDeviceSettings();

        if(sysInfos.phoneConnected) {
            fillLabel(labelBT, colorBT, fontXTiny, xPosBT, yPosBT, textBT, [loadResource(Rez.Strings.bt_short)]);
            if(sysInfos.notificationCount) {
                fillLabel(labelNT, colorNT, fontXTiny, xPosNT, yPosNT, textNT, [loadResource(Rez.Strings.nt_short), sysInfos.notificationCount]);
            } else {
                fillLabel(labelNT, colorNT, fontXTiny, xPosNT, yPosNT, textNT, [loadResource(Rez.Strings.nt_short), 0]);
            }
        } else {
            fillLabel(labelBT, colorBT, fontXTiny, xPosBT, yPosBT, emptyFormat, [emptyText]);
            fillLabel(labelNT, colorNT, fontXTiny, xPosNT, yPosNT, textNT, [loadResource(Rez.Strings.nt_short), noData]);
        }
    }

    /**
     * Component of the heart rate value
     * @param dc The device context
     */
    function setHeartRate(dc) as Void {
        /* User infos */
        var infos = Activity.getActivityInfo(); // INFO : Get the data of the user (heartrate, altitude, ...)
        
        /* HR Rate */
        var heartRate = Application.loadResource( Rez.Drawables.heart) as BitmapResource;
        drawACircle(dc, xPosHR, yPosHR, dc.getWidth() / 10, emptyCircle);
        dc.drawBitmap(xPosHR - heartRate.getWidth() / 2, yPosHR - heartRate.getHeight(), heartRate);

        if(infos.currentHeartRate != null) {
            fillLabel(labelHR, colorHR, fontXTiny, xPosHR, yPosHR, textHR, [infos.currentHeartRate]);
        } else {
            fillLabel(labelHR, colorHR, fontXTiny, xPosHR, yPosHR, textHR, [noData]);
        }
    }

    /**
     * Component of the altitude value
     * @param dc The device context
     */
    function setAltitude(dc) as Void {
        var infos = Activity.getActivityInfo(); // INFO : Get the data of the user (heartrate, altitude, ...)
        var sysInfos = System.getDeviceSettings();

        var altitude = Application.loadResource( Rez.Drawables.altitude) as BitmapResource;
        drawACircle(dc, xPosAltitude, yPosAltitude, dc.getWidth() / 10, emptyCircle);
        dc.drawBitmap(xPosAltitude - altitude.getWidth() / 2, yPosAltitude - altitude.getHeight(), altitude);

        if(infos.altitude != null) {
            var infosAltitude = infos.altitude.toNumber();
            var unit = sysInfos.elevationUnits == System.UNIT_METRIC ? "m" : "ft";
            
            if(infosAltitude > 999 or infosAltitude < -999 && sysInfos.elevationUnits == System.UNIT_METRIC) {
                infosAltitude = infosAltitude.toFloat() / 1000;
                unit = "km";
            }

            infosAltitude = infosAltitude.format(numberFormat);

            fillLabel(labelAltitude, colorAltitude, fontXTiny, xPosAltitude, yPosAltitude, textAltitude, [infosAltitude, unit]);
        }
        else {
            fillLabel(labelAltitude, colorAltitude, fontXTiny, xPosAltitude, yPosAltitude, textAltitude, [noData]);
        }
    }

    /**
     * Component of the rain probability value
     * @param dc The device context
     */
    function setRain(dc) as Void {
        var weather = Weather.getCurrentConditions();
        var rain = Application.loadResource( Rez.Drawables.rain) as BitmapResource;
        dc.drawBitmap(xPosRain - rain.getWidth()/2 - size_2_XTiny, yPosRain - rain.getHeight()/2 + size_2_XTiny, rain);
        if(weather.precipitationChance) {
            fillLabel(labelRain, colorRain, fontXTiny, xPosRain+rain.getWidth()/2+size_2_XTiny, yPosRain, textRain, [weather.precipitationChance]);
        } else {
            fillLabel(labelRain, colorRain, fontXTiny, xPosRain, yPosRain, emptyFormat, [noData]);
        }
    }

    /**
     * Component of the temperature value
     * @param dc The device context
     */
    function setTemperature(dc) as Void {
        var sysInfos = System.getDeviceSettings();
        var weather = Weather.getCurrentConditions();
        var tempUnit = sysInfos.temperatureUnits == System.UNIT_METRIC ? "°C" : "°F";
        var temperature = Application.loadResource( Rez.Drawables.temperature) as BitmapResource;
        dc.drawBitmap(xPosTemperature - temperature.getWidth()/2 - size_2_XTiny, yPosTemperature - temperature.getHeight()/2 + size_2_XTiny, temperature);
        if(weather.temperature) {
            fillLabel(labelTemperature, colorTemperature, fontXTiny, xPosTemperature+temperature.getWidth()/2+size_2_XTiny, yPosTemperature, textTemperature, [weather.temperature, tempUnit]);
        } else {
            fillLabel(labelTemperature, colorTemperature, fontXTiny, xPosTemperature, yPosTemperature, emptyFormat, [noData]);
        }
    }

    /**
     * Component of the steps goal/done values
     * @param dc The device context
     */
    function setStepsGoal(dc) as Void {

        
        var hist = ActivityMonitor.getInfo();
        var stepsGoal = hist.stepGoal;
        var stepsDone = hist.steps;

        var startAngle = 90;
        var finalAngle = 180;
        var endAngle = startAngle + (finalAngle - startAngle)*(stepsDone+1)/stepsGoal; // FORMULA : finalAngle - startAngle is negative for CLOCKWISE and positive for COUNTER_CLOCKWISE
        
        if(endAngle > finalAngle) {
            endAngle = finalAngle; // FORMULA : To avoid more than 100% goal and big arcs
        }

        var image = Application.loadResource( Rez.Drawables.steps) as BitmapResource;
        dc.drawBitmap(centerX - radiusX + 2*image.getHeight()+1, centerY - radiusY + 2*image.getHeight()+1, image);
        
        drawAnArc(dc, centerX, centerY, startAngle, finalAngle, radiusX - 5, chooseDirection(startAngle, finalAngle), emptyArc);
        if(endAngle - startAngle > 1) { 
            drawAnArc(dc, centerX, centerY, startAngle, endAngle, radiusX - 5, chooseDirection(startAngle, finalAngle), colorSteps);
        }
    }


    /**
     * Component of the date
     * @param dc The device context
     */
    function setDate(dc) as Void {
        // Get the current date
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

        // Update the view
        fillLabel(labelDate, colorDate, fontTiny, xPosDate, yPosDate, textDate, [today.day_of_week, today.day]);
    }


    /**
     * Component of the local time
     * @param dc The device context
     */
    function setTime(dc) as Void {
        fillLabel(labelTime, colorTime, fontXXLarge, xPosTime, yPosTime, textTime, formatTime(System.getClockTime()));
    }

    /**
     * Component of the UTC time
     * @param dc The device context
     */
    function setUTCTime(dc) as Void {
        fillLabel(labelUTC, colorUTC, fontTiny, xPosUTC, yPosUTC, textUTC, formatTime(Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT)));
    }

    /**
     * Fills a label
     * @param identifier The id in the layout xml file
     * @param color The color id as a String
     * @param font The font to use for the text
     * @param xPos The X position of the upper left corner
     * @param yPos The Y position of the upper right corner
     * @param textFormat The format of the text (with $1$, $2$, ...) for Lang.format
     * @param parameters The parameters of the text for Lang.format
     */
    function fillLabel(identifier, color, font, xPos, yPos, textFormat, parameters) as Void {
        var label = View.findDrawableById(identifier) as Text;

        if(label != null) {
            var loadedColor = defaultForeground;
            
            try {
                loadedColor = Application.Properties.getValue(color) as Number;
            } catch(e instanceof Lang.Exception) {
                System.println("Color Exception fillLabel : "+e.getErrorMessage());
            } 
            label.setColor(loadedColor);
            label.setLocation(xPos, yPos);
            label.setFont(font);
            label.setText(Lang.format(textFormat, parameters));
        } else {
            System.println("Called an unknown label : "+identifier); // INFO : This is a log
        }
    }

    /**
     * Format a time object to send back an array with the hour properly formatted and minutes properly formatted
     * @param time A time object to format
     * @return An array of properly formatted time [hours, minutes] with care of 12 hour type
     */
    function formatTime(time) as Array<Number>{
        var hours = time.hour;
        var minutes = time.min;

        if (!System.getDeviceSettings().is24Hour && hours > 12) {
            hours = hours - 12;
        }

        try {
            // Check if military mode. If yes then change the format of the time
            // BUG There is a bug in CIQ when modifying properties so this part is commented until a hack is found
            /*System.println(Application.Properties.getValue("UseMilitaryFormat"));
            if (Application.Properties.getValue("UseMilitaryFormat")) {
                textTime = "$1$$2$";
                textUTC = "UTC\n$1$$2$";
            } else {
                textTime = "$1$:$2$";
                textUTC = "UCT\n$1$:$2$";
            }*/
        } catch(e instanceof Lang.Exception) {
            System.println("Military zone exception : "+e.getErrorMessage());
        }
        
        hours = hours.format(numberFormat);
        minutes = minutes.format(numberFormat);

        return [hours, minutes];
    }

    /**
     * Draw an arc on the device context provided with the parameters
     * @param dc The device context
     * @param x The X position of the center of the arc
     * @param y The Y position of the center of the arc
     * @param startAngle The starting angle
     * @param endAngle The ending angle
     * @param radius The radius of the arc
     * @param direction The direction as CLOCKWISE and COUNTER_CLOCKWISE
     * @param color The color of the arc as a String
     */
    function drawAnArc(dc, x, y, startAngle, endAngle, radius, direction, color) as Void {
        var foreground = defaultForeground;
        var background = defaultBackground;
        try {
            foreground = Application.Properties.getValue(color) as Number;
            background = Application.Properties.getValue(backgroundColor) as Number;
        } catch(e instanceof Lang.Exception) {
            System.println("Color Exception drawAnArc : "+e.getErrorMessage());
        }
        dc.setColor(foreground, background);
        dc.drawArc(x, y, radius, direction, startAngle, endAngle);
    }

    /**
     * Draw a circle on the device context provided with the parameters
     * @param dc The device context
     * @param x The X position of the center of the circle
     * @param y The Y position of the center of the circle
     * @param radius The radius of the circle
     * @param color The color of the circle as a String
     */
    function drawACircle(dc, x, y, radius, color) as Void {
        var foreground = defaultForeground;
        var background = defaultBackground;
        try {
            foreground = Application.Properties.getValue(color) as Number;
            background = Application.Properties.getValue(backgroundColor) as Number;
        } catch(e instanceof Lang.Exception) {
            System.println("Color Exception drawACircle : "+e.getErrorMessage());
        }
        dc.setColor(foreground, background);
        dc.drawCircle(x, y, radius);
    }

    /**
     * Choose the direction with the starting angle and the ending angle with the formula
     * //FORMULA finalAngle - startAngle is negative for CLOCKWISE and positive for COUNTER_CLOCKWISE
     * @param startAngle The starting angle
     * @param endAngle The ending angle
     */
    function chooseDirection(startAngle, endAngle) as Number {
        return endAngle - startAngle < 0 ? Graphics.ARC_CLOCKWISE : Graphics.ARC_COUNTER_CLOCKWISE;
    }
}
