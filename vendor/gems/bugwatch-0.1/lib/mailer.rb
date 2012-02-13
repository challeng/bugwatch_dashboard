class Mailer

  class << self

    def send_feedback(feedback, commit)
      send_mail(commit.committer.email, message(feedback, commit))
    end

    def formatted_feedback(feedback)
      feedback.map do |(file, bug_fixes)|
        grouped_fixes = bug_fixes.group_by(&:klass)
        formatted = grouped_fixes.flat_map do |(klass, fixes)|
          [get_klass_level_feedback(klass, fixes), get_method_level_feedback(fixes)]
        end
        [file, formatted].join("\n")
      end.join("\n\n")
    end

    def get_klass_level_feedback(klass_name, bug_fixes)
      klass_level_bug_fixes = bug_fixes.reject(&:function)
      total_klass_score = klass_level_bug_fixes.map {|bug_fix| bug_fix.score}.reduce(:+) || 0
      formatted_fixes = klass_level_bug_fixes.map do |bug_fix|
        "- #{bug_fix.sha}: #{bug_fix.date}"
      end
      ["\t\t#{klass_name} (#{total_klass_score})", formatted_fixes].join("\n\t\t")
    end

    def get_method_level_feedback(bug_fixes)
      method_level_bug_fixes = bug_fixes.select(&:function).group_by(&:function)
      method_level_bug_fixes.map do |(method_name, fixes)|
        method_total_score = fixes.map(&:score).reduce(:+)
        formatted_bug_fixes = fixes.map do |bug_fix|
          "\t\t\t- #{bug_fix.sha}: #{bug_fix.date}"
        end
        ["\t\t\t##{method_name} (#{method_total_score})", formatted_bug_fixes]
      end.join("\n")
    end

    def message(feedback, commit)
      %Q{
      Hello #{commit.committer.name},

      When reviewing the following commit: #{commit.sha}
      The following classes and functions were found to be historically buggy:

      File | Class (bug score) | Method (bug score)

      #{formatted_feedback(feedback)}

      Please review these changes closely.
      }
    end

    def send_mail(to, body)
      Pony.mail({
        :to => to,
        :via => :smtp,
        :via_options => {
          :address              => 'smtp.gmail.com',
          :port                 => '587',
          :enable_starttls_auto => true,
          :user_name            => mail_config['gmail']['user'],
          :password             => Base64.decode64(mail_config['gmail']['password']),
          :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
          :domain               => "gmail.com" # the HELO domain provided by the client to the server
        },
        :body => body,
        :subject => "Bugwatch Report"
      })
    end

    def mail_config
      $mailer_config ||= JSON.parse(File.read(File.expand_path('../../config/mail.json', __FILE__)))
    end

  end

end