const FRAMEWORK_NAME = 'DummyPlugin';
const VERSION = '1.0.1';
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
        
        removeQuarantineFlagIfNeeded(resourcesPath.stringByAppendingPathComponent(FRAMEWORK_NAME+".framework"));
        
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

function removeQuarantineFlagIfNeeded(frameworkPath) {
    if(!shouldRemoveQuarantineFlag()){
        return;
    }
    
    log("About to remove >com.apple.quarantine< attribute from: '"+frameworkPath+"'" );
    const xattr = "/usr/bin/xattr";
    const args = ["-r", "-d", "com.apple.quarantine", frameworkPath];

    const task = NSTask.launchedTaskWithLaunchPath_arguments(xattr, args);
    task.waitUntilExit();
}

function shouldRemoveQuarantineFlag(){
    try {
        if (NSAppKitVersionNumber >= NSAppKitVersionNumber10_14_5) {
            return true
        }
    } catch (e) { }
    
    return false
}
