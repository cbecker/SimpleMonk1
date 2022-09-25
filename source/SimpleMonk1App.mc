import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.WatchUi as Ui;

// TODO: move these to SimpleMonk1View and avoid globals
var gSmallFont;
var gSmallBoldFont;
var gUltraSmallFont;
var gHoursFont;
var gMinutesFont;
var gSmallNumbersFont;
var gSmallNumbersBoldFont;
var gIconsFont;

class SimpleMonk1App extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
        gSmallFont = Ui.loadResource(Rez.Fonts.id_abc_s_1);
        gSmallBoldFont = Ui.loadResource(Rez.Fonts.id_abc_s_3);
        gUltraSmallFont = Ui.loadResource(Rez.Fonts.id_abc_s_1);
        gHoursFont = Ui.loadResource(Rez.Fonts.id_large_m_4);
        gMinutesFont = Ui.loadResource(Rez.Fonts.id_large_m_3); // TODO: change
        gSmallNumbersFont = Ui.loadResource(Rez.Fonts.id_num_s_1);
        gSmallNumbersBoldFont = Ui.loadResource(Rez.Fonts.id_num_s_3);
        gIconsFont = Ui.loadResource(Rez.Fonts.id_icons);
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new SimpleMonk1View() ] as Array<Views or InputDelegates>;
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

}

function getApp() as SimpleMonk1App {
    return Application.getApp() as SimpleMonk1App;
}