<?php

add_action('init', 'bpwp_force_disable_autoupdates', 11);
add_action('pre_current_active_plugins', 'bpwp_hide_easyupdatesmanager', 0);

function bpwp_force_disable_autoupdates() {
    $PLUGIN_NAME = 'stops-core-theme-and-plugin-updates/main.php';

    # Make sure "Easy Updates Manager" plugin is always active
    activate_plugin($PLUGIN_NAME);

    # Hide option for deactivating plugin
    add_filter('plugin_action_links', function ($actions, $plugin_file) {
        if (array_key_exists('deactivate', $actions) && $plugin_file === $PLUGIN_NAME) {
            unset($actions['deactivate']);
        }
        return $actions;
    }, 10, 2);

    # Make sure plugin is always set do DISABLE ALL updates
    update_option('MPSUM', ['core' => ['all_updates' => 'off']]);
}

# Hide plugin from installed plugins list
function bpwp_hide_easyupdatesmanager() {
    global $wp_list_table;

    $myplugins = $wp_list_table->items;
    foreach ($myplugins as $key => $val) {
        if ($key === 'stops-core-theme-and-plugin-updates/main.php') {
            unset($wp_list_table->items[$key]);
        }
    }
}
