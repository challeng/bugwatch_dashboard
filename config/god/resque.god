rails_env   = ENV['RAILS_ENV']  || "production"
rails_root  = ENV['RAILS_ROOT'] || "/var/groupon/fixcache/current"

queues = %w(analysis)

God.contact(:email) do |c|
  c.name = 'Jacob'
  c.group = 'jacobr'
  c.to_email = 'jacobr@groupon.com'
end

queues.each do |queue|
  God.watch do |w|
    w.name     = "resque-worker-#{queue}"
    w.group    = 'resque'
    w.interval = 30.seconds
    w.dir = rails_root
    # w.start_grace   = 60.seconds
    # w.restart_grace = 60.seconds
    
    w.env      = { "QUEUE" => queue,
                   "RAILS_ENV" => rails_env }
    
    w.start    = "bundle exec rake -f #{rails_root}/Rakefile environment resque:work"

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 400.megabytes
        c.times = 2
        c.notify = {:contacts => ['email'], :category => 'resque workers memory_usage'}
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.notify = {:contacts => ['email'], :category => 'resque workers init'}
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
        c.notify = {:contacts => ['email'], :category => 'resque workers started'}
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
        c.notify = {:contacts => ['email'], :category => 'resque workers starting'}
      end
    end
  end
end
