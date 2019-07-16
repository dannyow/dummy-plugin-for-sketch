const FRAMEWORK_NAME = 'DummyPlugin';
const VERSION = '1.0.0';
const IDENTIFIER = 'me.buffered.DummySketchPlugin';

function isFrameworkLoaded() {
    return Boolean(NSClassFromString('DummyPluginController'));
}

/**
 * Handles startup action.
 */
function onStartup(context) {
    if (!isFrameworkLoaded()) {
        const contentsPath = context.scriptPath.stringByDeletingLastPathComponent().stringByDeletingLastPathComponent();
        const resourcesPath = contentsPath.stringByAppendingPathComponent('Resources');

        const result = Mocha.sharedRuntime().loadFrameworkWithName_inDirectory(FRAMEWORK_NAME, resourcesPath);
        if (!result) {
            const alert = NSAlert.alloc().init();
            alert.alertStyle = NSAlertStyleCritical;
            alert.messageText = 'Loading framework for “' + FRAMEWORK_NAME + '” failed';
            alert.informativeText = 'Please try disabling and enabling the plugin or restarting Sketch.';

            alert.runModal();

            return;
        }
    }

    log('DummyPlugin:onStartup plugin controller Enabled');
    DummyPluginController.sharedController().startPlugin();
}

/**
 * Handles shutdown action.
 */
function onShutdown(context) {
    if (isFrameworkLoaded()) {
        log('DummyPlugin:onShutdown plugin controller Disabled');
        DummyPluginController.sharedController().stopPlugin();
    }
}

/**
 * Handles selection change action.
 */
function onSelectionChanged(context) {
    if (isFrameworkLoaded()) {
        log('DummyPlugin:onSelectionChanged passing context data');
        DummyPluginController.sharedController().selectionDidChange(context);
    }
}

/**
 * Handles togglePanel command.
 */
function sendPing(context) {
    if (isFrameworkLoaded()) {
        log('DummyPlugin:sendPing');
        const response = DummyPluginController.sharedController().sendPing(context);
        log(response);
    }
}
