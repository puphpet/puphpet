class puphpet_cron (
  $cron
) {

  each( $cron['jobs'] ) |$key, $job| {
    # Deletes empty cron jobs
    $job_values = delete_values($job, '')

    create_resources(cron, { "${key}" => $job_values })
  }

}




