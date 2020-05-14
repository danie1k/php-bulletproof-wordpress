# Bulletproof-Wordpress
Bulletproof* Wordpress deployment automation based on Ansible & Composer

# Table of Contents
1. [Installation](#installation)
2. [Basic Wordpress Configuration](#basic-wordpress-configuration)
    1. [Database settings](#database-settings)
    2. [Secret keys](#secret-keys)
3. [Extended Wordpress Configuration](#extended-wordpress-configuration)
    1. [HTTPS detection mechanism](#https-detection-mechanism)
    2. [Paths customization](#paths-customization)
    3. [Cron](#cron)
4. [SMTP Configuration](#smtp-configuration)
    1. [Global settings](#global-settings)
    2. [Mailer-specific settings](#mailer-specific-settings)
        1. [PHP](#php)
        2. [SMTP.com](#smtpcom)
        3. [Pepipost](#pepipost)
        4. [Sendinblue](#sendinblue)
        5. [Mailgun](#mailgun)
        6. [SendGrid](#sendgrid)
        7. [Classic SMTP server](#classic-smtp-server)
5. [Advanced options](#advanced-options)
6. [License](#license)

## Installation
To begin run the following command in Bash-compatible terminal:
```bash
bash <(curl -s https://raw.githubusercontent.com/danie1k/php-bulletproof-wordpress/dev/.github/installer.sh)
```

*Work in progress, more to come...*

## Basic Wordpress Configuration

### Database settings

| Ansible Variable        | PHP equivalent          |                          |
|-------------------------|-------------------------|--------------------------|
| `bpwp_db_host`          | `DB_HOST`               | *required*               |
| `bpwp_db_name`          | `DB_NAME`               | *required*               |
| `bpwp_db_user`          | `DB_USER`               | *required*               |
| `bpwp_db_password`      | `DB_PASSWORD`           | *required*               |
| `bpwp_db_charset`       | `DB_CHARSET`            | `utf8mb4` by default     |
| `bpwp_db_collate`       | `DB_COLLATE`            | `utf8mb4_bin` by default |
| `bpwp_db_table_prefix`  | `$table_prefix`         | `wp_` by default         |
| `bpwp_db_client_flags`  | `MYSQL_CLIENT_FLAGS`    | *optional*               |

### Secret keys
*TIP: Use https://api.wordpress.org/secret-key/1.1/salt/ to generate all the following keys.*

| Ansible Variable        | PHP equivalent          |                          |
|-------------------------|-------------------------|--------------------------|
| `bpwp_auth_key`         | `AUTH_KEY`              | *required*               |
| `bpwp_secure_auth_key`  | `SECURE_AUTH_KEY`       | *required*               |
| `bpwp_logged_in_key`    | `LOGGED_IN_KEY`         | *required*               |
| `bpwp_nonce_key`        | `NONCE_KEY`             | *required*               |
| `bpwp_auth_salt`        | `AUTH_SALT`             | *required*               |
| `bpwp_secure_auth_salt` | `SECURE_AUTH_SALT`      | *required*               |
| `bpwp_logged_in_salt`   | `LOGGED_IN_SALT`        | *required*               |
| `bpwp_nonce_salt`       | `NONCE_SALT`            | *required*               |

## Extended Wordpress Configuration

### HTTPS detection mechanism
Select how WordPress should detect that a page is loaded via HTTPS, it strongly depends on your web server & DNS configuration. 

| Ansible Variable    | Default value |
|---------------------|---------------|
| `bpwp_https_method` | `SERVER_PORT` |

Available options:

| Value                             | Description/Usage case                      |
|-----------------------------------|---------------------------------------------|
| `true` (boolean)                  | Force HTTPS always on                       |
| `false` (boolean)                 | Force HTTPS always off                      |
| `SERVER_PORT`                     | Check if `$_SERVER['SERVER_PORT']` is `443` |
| `HTTP_X_FORWARDED_PROTO`          | Load balancer, reverse proxy, Nginx         |
| `HTTP_X_FORWARDED_SSL`            | Reverse proxy                               |
| `HTTP_CLOUDFRONT_FORWARDED_PROTO` | AWS CloudFront                              |
| `HTTP_X_FORWARDED_SCHEME`         | KeyCDN                                      |
| `HTTP_X_ARR_SSL`                  | Windows Azure ARR                           |

### Paths customization
All directories in this section are publicly exposed!

| Ansible Variable              | Description                                                                                                    |                       |
|-------------------------------|----------------------------------------------------------------------------------------------------------------|-----------------------|
| `bpwp_wp_uploads_dir_name`    | Directory name for storing [Must Use Plugins](https://wordpress.org/support/article/must-use-plugins/)         | Default: `uploads`    |
| `bpwp_wp_plugins_dir_name`    | Directory name for storing [uploaded media files](https://wordpress.org/support/article/media-library-screen/) | Default: `plugins`    |
| `bpwp_wp_themes_dir_name`     | Directory name for storing [Themes](https://wordpress.org/support/article/using-themes/)                       | Default: `themes`     |
| `bpwp_wp_mu_plugins_dir_name` | Directory name for storing [Must Use Plugins](https://wordpress.org/support/article/must-use-plugins/)         | Default: `mu-plugins` |

### Cron
It is highly recommended to use Crontab-based cron to drive Wordpress, over built-in one.  
Check following links fore more information:
* https://support.hostgator.com/articles/specialized-help/technical/wordpress/how-to-replace-wordpress-cron-with-a-real-cron-job
* https://easyengine.io/tutorials/wordpress/wp-cron-crontab/

| Ansible Variable        | Description                                                     | Type (default value) |
|-------------------------|-----------------------------------------------------------------|----------------------|
| `bpwp_custom_cron`      | Disables Wordpress built-in Cron and sets system crontab entry. | boolean (`true`)     |
| `bpwp_cron_minute`      | *Used only if `bpwp_custom_cron` is enabled.* Every 10 minutes. | string (`*/10`)      |
| `bpwp_cron_hour`        | *Used only if `bpwp_custom_cron` is enabled.*                   | string (`*`)         |
| `bpwp_cron_day`         | *Used only if `bpwp_custom_cron` is enabled.*                   | string (`*`)         |
| `bpwp_cron_month`       | *Used only if `bpwp_custom_cron` is enabled.*                   | string (`*`)         |
| `bpwp_cron_weekday`     | *Used only if `bpwp_custom_cron` is enabled.*                   | string (`*`)         |

## SMTP Configuration
BPWP SMTP support is provided with third-party Wordpress plugin: https://wordpress.org/plugins/wp-mail-smtp/

### Global settings

| Setting name         | Ansible Variable                 | Description                                                                                    | Type (default value) |
|----------------------|----------------------------------|------------------------------------------------------------------------------------------------|----------------------|
|                      | `bpwp_smtp_enabled`              | Turns on/off SMTP support                                                                      | boolean (`true`)     |
| **From Email**       | `bpwp_smtp_mail_from`            | The email address which emails are sent from                                                   | string, **required** |
| **From Name**        | `bpwp_smtp_mail_from_name`       | The name which emails are sent from                                                            | string, **required** |
| **Force From Email** | `bpwp_smtp_mail_from_force`      | The From Email setting above will be used for all emails, ignoring values set by other plugins | boolean (`false`)    |
| **Force From Name**  | `bpwp_smtp_mail_from_name_force` | The From Name setting above will be used for all emails, ignoring values set by other plugins  | boolean (`false`)    |
| **Return Path**      | `bpwp_smtp_set_return_path`      | Return Path indicates where non-delivery receipts - or bounce messages - are to be sent.<br />If disabled, bounce messages may be lost. Some providers may ignore this option. | boolean (`true`) |
| **Mailer**           | `bpwp_smtp_mailer`               | Mailer engine. Possible values: `php`, `smtp.com`, `sendinblue`, `mailgun`, `sendgrid`, `smtp` | string (`php`) |

### Mailer-specific settings

#### PHP
*No settings*

#### SMTP.com
Full documentation: https://wpmailsmtp.com/docs/how-to-set-up-the-smtp-com-mailer-in-wp-mail-smtp

| Setting name         | Ansible Variable                 | Description                                                                                    | Type (default value) |
|----------------------|----------------------------------|------------------------------------------------------------------------------------------------|----------------------|
| **API Key**          | `bpwp_smtp_smtpcom_api_key`      | [API Key from SMTP.com](https://my.smtp.com/settings/api)                                      | string, **required** |
| **Sender Name**      | `bpwp_smtp_smtpcom_channel`      | [Sender Name from SMTP.com](https://my.smtp.com/senders/)                                      | string, **required** |

#### Pepipost
Full documentation: https://wpmailsmtp.com/docs/how-to-set-up-the-pepipost-mailer-in-wp-mail-smtp

| Setting name         | Ansible Variable                 | Description                                                                                    | Type (default value) |
|----------------------|----------------------------------|------------------------------------------------------------------------------------------------|----------------------|
| **API Key**          | `bpwp_smtp_pepipost_api_key`      | [API Key from Pepipost](https://app.pepipost.com/app/settings/integration)                    | string, **required** |

#### Sendinblue
Full documentation: https://wpmailsmtp.com/docs/how-to-set-up-the-sendinblue-mailer-in-wp-mail-smtp

| Setting name         | Ansible Variable                 | Description                                                                                    | Type (default value) |
|----------------------|----------------------------------|------------------------------------------------------------------------------------------------|----------------------|
| **API Key**          | `bpwp_smtp_sendinblue_api_key`   | [v3 API Key from Sendinblue](https://account.sendinblue.com/advanced/api)                      | string, **required** |

#### Mailgun
Full documentation: https://wpmailsmtp.com/docs/how-to-set-up-the-mailgun-mailer-in-wp-mail-smtp

| Setting name         | Ansible Variable                 | Description                                                                                    | Type (default value) |
|----------------------|----------------------------------|------------------------------------------------------------------------------------------------|----------------------|
| **Private API Key**  | `bpwp_smtp_mailgun_api_key`      | [Private API Key from Mailgun](https://app.mailgun.com/app/account/security/api_keys)          | string, **required** |
| **Domain Name**      | `bpwp_smtp_mailgun_domain`       | [Domain Name from Sendinblue](https://app.mailgun.com/app/domains)                             | string, **required** |
| **Region**           | `bpwp_smtp_mailgun_region`       | Define which endpoint you want to use for sending messages. [More information on Mailgun.com](https://www.mailgun.com/regions). | string, (`US`) |

#### SendGrid
Full documentation: https://wpmailsmtp.com/docs/how-to-set-up-the-sendgrid-mailer-in-wp-mail-smtp

| Setting name         | Ansible Variable                 | Description                                                                                    | Type (default value) |
|----------------------|----------------------------------|------------------------------------------------------------------------------------------------|----------------------|
| **API Key**          | `bpwp_smtp_sendgrid_api_key`     | [API Key from SendGrid](https://app.sendgrid.com/settings/api_keys)                            | string, **required** |

#### Classic SMTP server
Full documentation: https://wpmailsmtp.com/docs/how-to-set-up-the-other-smtp-mailer-in-wp-mail-smtp/

| Setting name         | Ansible Variable                 | Description                                                                                    | Type (default value) |
|----------------------|----------------------------------|------------------------------------------------------------------------------------------------|----------------------|
| **SMTP Host**        | `bpwp_smtp_host`                 |                                                                                                | string, **required** |
| **Encryption**       | `bpwp_smtp_ssl`                  | Possible values: `null`, `ssl`, `tls` (note: TLS is not STARTTLS)                              | string, **required** |
| **SMTP Port**        | `bpwp_smtp_port`                 | No encryption - `25` / SSL - `465` / TLS - `587`                                               | int, **required**    |
| **Auto TLS**         | `bpwp_smtp_autotls`              |                                                                                                | boolean (`true`)     |
| **Authentication**   | `bpwp_smtp_auth`                 |                                                                                                | boolean (`true`)     |
| **SMTP Username**    | `bpwp_smtp_user`                 |                                                                                                | string, **required** |
| **SMTP Password**    | `bpwp_smtp_pass`                 |                                                                                                | string, **required** |

## Advanced options
**Warning! Any changes made to files on remote server will be lost during Ansible-based deployment!**

| Ansible Variable              | Description                                       |                 |
|-------------------------------|---------------------------------------------------|-----------------|
| `bpwp_wp_disallow_file_edit`  | Disable the Plugin and Theme Editor?              | Default: `true` |
| `bpwp_wp_disallow_file_mods`  | Disable Plugin and Theme Update and Installation? | Default: `true` |
| `bpwp_wp_disable_autoupdates` | Disable Wordpress auto-updates using [Easy Updates Manager](https://wordpress.org/plugins/stops-core-theme-and-plugin-updates/) plugin | Default: `true` |

## License

MIT

----

\* *Highly secured*
