<?php

add_action('init', 'bpwp_force_easyupdatesmanager', 11);
add_action('pre_current_active_plugins', 'bpwp_hide_easyupdatesmanager', 0);

define('BPWP_PLUGIN_EASYUPDATESMANAGER', 'stops-core-theme-and-plugin-updates/main.php');

function bpwp_force_easyupdatesmanager() {
    # Make sure plugin is always active
    activate_plugin(BPWP_PLUGIN_EASYUPDATESMANAGER);
    # Hide option for deactivating plugin
    add_filter('plugin_action_links', function ($actions, $plugin_file) {
        if (array_key_exists('deactivate', $actions) && $plugin_file === BPWP_PLUGIN_EASYUPDATESMANAGER) {
            unset($actions['deactivate']);
        }
        return $actions;
    }, 10, 2);
}

# Hide plugin from installed plugins list
function bpwp_hide_easyupdatesmanager() {
    global $wp_list_table;

    $myplugins = $wp_list_table->items;
    foreach ($myplugins as $key => $val) {
        if ($key === BPWP_PLUGIN_EASYUPDATESMANAGER) {
            unset($wp_list_table->items[$key]);
            break;
        }
    }
}
