<?php
/**
 * Because most of the Wordpress paths has been so heavily modified in `wp-config.php`,
 * and Wordpress is so much hardcoded on storing uploads in wp-content/uploads, and for the native files structure in general...
 * We need to help it to properly resolve new, customized, upload path.
 *
 * INCOMING DATA:
 * >>> $paths = [
 * >>>    "path"    => "/var/www/example.com/wordpress//var/www/example.com/public_html/uploads/2020/05"
 * >>>    "url"     => "https://example.com//var/www/example.com/public_html/uploads/2020/05"
 * >>>    "subdir"  => "/2020/05"
 * >>>    "basedir" => "/var/www/example.com/wordpress//var/www/example.com/public_html/uploads"
 * >>>    "baseurl" => "https://example.com//var/www/example.com/public_html/uploads"
 * >>>    "error"   => ""
 * >>> ];
 *
 * EXPECTED RESULT:
 * >>> $paths = [
 * >>>    "path"    => "/var/www/example.com/public_html/uploads/2020/05"
 * >>>    "url"     => "https://example.com/uploads/2020/05"
 * >>>    "subdir"  => "/2020/05"
 * >>>    "basedir" => "/var/www/example.com/public_html/uploads"
 * >>>    "baseurl" => "https://example.com/uploads"
 * >>>    "error"   => ""
 * >>> ];
 */

function bpwp_fix_upload_dir_path($value) {
    // basedir, path
    return !is_string($value) ? $value : str_replace(
        array(
            WORDPRESS_DIR.DIRECTORY_SEPARATOR.UPLOADS.DIRECTORY_SEPARATOR,
            WORDPRESS_DIR.UPLOADS.DIRECTORY_SEPARATOR,
            WORDPRESS_DIR.DIRECTORY_SEPARATOR.UPLOADS,
            WORDPRESS_DIR.UPLOADS,
        ),
        array(
            UPLOADS.DIRECTORY_SEPARATOR,
            UPLOADS.DIRECTORY_SEPARATOR,
            UPLOADS,
            UPLOADS,
        ),
        $value
    );
}

function bpwp_fix_upload_dir_url($value) {
    // baseurl, url
    return !is_string($value) ? $value : str_replace(
        array(
            "/".UPLOADS.DIRECTORY_SEPARATOR,
            "/".UPLOADS
        ),
        array(
            "/".UPLOADS_DIR_NAME.DIRECTORY_SEPARATOR,
            "/".UPLOADS_DIR_NAME,
        ),
        $value
    );
}


add_filter('upload_dir', function (array $paths) {
    $paths = array_map("bpwp_fix_upload_dir_path", $paths);
    $paths = array_map("bpwp_fix_upload_dir_url", $paths);
    return $paths;
}, 99999);
