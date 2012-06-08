class PivotalXml
  class << self

    STORY_ID = 99
    PROJECT_ID = 50

    def create_bug
      <<-XML
<?xml version="1.0" ?>
<activity>
  <id type="integer">12345</id>
  <version type="integer">5</version>
  <event_type>story_create</event_type>
  <occurred_at type="datetime">2010/01/01 19:50:00 UTC</occurred_at>
  <author>author_name</author>
  <project_id type="integer">#{PROJECT_ID}</project_id>
  <description>new bug</description>
  <stories type="array">
    <story>
      <id type="integer">#{STORY_ID}</id>
      <url>http://www.pivotaltracker.com/</url>
      <name>Doesn't work</name>
      <story_type>bug</story_type>
      <description>this is a test</description>
      <current_state>unscheduled</current_state>
      <requested_by>requester_name</requested_by>
    </story>
  </stories>
</activity>
      XML
    end

    def update_start
      story_update "started"
    end

    def update_finished
      story_update "finished"
    end

    def update_delivered
      story_update "delivered"
    end

    def update_accepted
      story_update "accepted", true
    end

    private

    def story_update(state, accepted=false)
      <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<activity>
   <id type="integer">12346</id>
   <version type="integer">6</version>
   <event_type>story_update</event_type>
   <occurred_at type="datetime">2010/01/01 19:54:59 UTC</occurred_at>
   <author>author_name</author>
   <project_id type="integer">#{PROJECT_ID}</project_id>
   <description>user started "Doesn't work"</description>
   <stories type="array">
      <story>
         <id type="integer">#{STORY_ID}</id>
         <url>http://www.pivotaltracker.com/</url>
         <current_state>#{state}</current_state>#{
      %q{<accepted_at type="datetime">2010/01/01 19:55:08 UTC</accepted_at>} if accepted
          }
      </story>
   </stories>
</activity>
      XML
    end

  end
end