<?php

add_filter(
    'upload_dir',
    function (array $paths) {
        foreach ($paths as $key => &$item) {
            if (is_string($item)) {
                $item = str_replace(
                    [
                        DIRECTORY_SEPARATOR.WWW_DIR,
                        ABSPATH.UPLOADS_DIR_NAME,
                    ],
                    [
                        DIRECTORY_SEPARATOR,
                        WWW_DIR.DIRECTORY_SEPARATOR.UPLOADS_DIR_NAME,
                    ],
                    $item,
                );
            }
        }

        return $paths;
    },
    99
);
