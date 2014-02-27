Monkey Test
===========

File list
---------
- _monkey.sh - main script
    - _source_config_check.sh - check the config file was sourced
    - _dev_check.sh  - check the device, such as adb, sdcard and so on
    - _image.sh - get image
    - _flash.sh - flash image
    - _test_prepare.sh - prepare for test
    - _test.sh - do test
        - _test_keep.sh - generate orng script and run it
            - _test_keep_poweron.sh - keep lcd on(to do)
    - _log.sh - log, get, parse, tar and push
        - _log_filename.sh - generete log filename
        - _log_parse_slog.sh - ffos log parse
        - _log_parse_ffos.sh - slog parse
    - gen_script.sh - inherit
    - ssh_passwd.sh - ingerit
- configs/ - test config folder
    - 6821-hudson-config - 6821 hudson version test configure file
    - 7710-hudson-config - 7710 hudson version test configure file
    - monkey-config-template - test configure template
    - run-6821-hudson.sh - run 6821 hudson test
    - run-7710-hudson.sh - run 7710 hudson test
- bin/
- sc/

Slog parse
----------
- <log-folder>/slog_external - slog get from /sdcard/slog
- <log-folder>/slog_internal - slog get from /data/slog
- output file: <log-folder>/slot_report
- slog parse is same as Android system, expect the 'Android Bug Information'
- Deal slog result as what android projects do, please.

FFOS log parse
--------------
- <log-folder>/mozilla - files get from /data/b2g/mozilla
- output folder: <log-folder>/minidump/
    - summary - all dmp file list
    - <file's named by dmp file> - the corresponding dmp file's stack information
- For every different dmp file, file a bug on bugzilla. 
