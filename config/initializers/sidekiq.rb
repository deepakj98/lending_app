Sidekiq.configure_server do |config|
  config.on(:startup) do
    yaml_config = YAML.load_file(Rails.root.join('config/sidekiq.yml'))
    schedule = yaml_config.dig('scheduler', 'schedule') || yaml_config.dig(:scheduler, :schedule)

    if schedule
      Sidekiq.schedule = schedule
      SidekiqScheduler::Scheduler.instance.reload_schedule!
    else
      Rails.logger.warn "Sidekiq schedule is missing or malformed in sidekiq.yml"
    end
  end
end
