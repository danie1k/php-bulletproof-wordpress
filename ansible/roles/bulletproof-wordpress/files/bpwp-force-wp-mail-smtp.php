<?php

add_action('pre_current_active_plugins', function () {
    global $wp_list_table;

    $PLUGIN = 'wp-mail-smtp/wp_mail_smtp.php';

    # Make sure plugin is always active
    activate_plugin($PLUGIN);

    # Hide option for deactivating plugin
    add_filter('plugin_action_links', function ($actions, $plugin_file) use ($PLUGIN) {
        if (array_key_exists('deactivate', $actions) && $plugin_file === $PLUGIN) {
            unset($actions['deactivate']);
        }
        return $actions;
    }, 10, 2);

    # Hide plugin from installed plugins list
    $myplugins = $wp_list_table->items;
    foreach ($myplugins as $key => $val) {
        if ($key === $PLUGIN) {
            unset($wp_list_table->items[$key]);
            break;
        }
    }
}, 0);
