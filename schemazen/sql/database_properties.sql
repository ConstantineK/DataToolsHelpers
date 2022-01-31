select
    [compatibility_level],
    [collation_name],
    [is_auto_close_on],
    [is_auto_shrink_on],
    [snapshot_isolation_state],
    [is_read_committed_snapshot_on],
    [recovery_model_desc],
    [page_verify_option_desc],
    [is_auto_create_stats_on],
    [is_auto_update_stats_on],
    [is_auto_update_stats_async_on],
    [is_ansi_null_default_on],
    [is_ansi_nulls_on],
    [is_ansi_padding_on],
    [is_ansi_warnings_on],
    [is_arithabort_on],
    [is_concat_null_yields_null_on],
    [is_numeric_roundabort_on],
    [is_quoted_identifier_on],
    [is_recursive_triggers_on],
    [is_cursor_close_on_commit_on],
    [is_local_cursor_default],
    [is_trustworthy_on],
    [is_db_chaining_on],
    [is_parameterization_forced],
    [is_date_correlation_on]
from sys.databases