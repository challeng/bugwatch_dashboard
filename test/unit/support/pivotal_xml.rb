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
      story current_state: "started"
    end

    def update_finished
      story current_state: "finished"
    end

    def update_delivered
      story current_state: "delivered"
    end

    def update_accepted
      story current_state: "accepted", accepted: true
    end

    def story_deleted
      story current_state: "deleted", event_type: "story_delete"
    end

    def story(opts={})
      <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<activity>
   <id type="integer">12346</id>
   <version type="integer">6</version>
   <event_type>#{opts[:event_type] || "story_update"}</event_type>
   <occurred_at type="datetime">2010/01/01 19:54:59 UTC</occurred_at>
   <author>author_name</author>
   <project_id type="integer">#{opts[:project_id] || PROJECT_ID}</project_id>
   <description>user started "Doesn't work"</description>
   <stories type="array">
      <story>
         <id type="integer">#{opts[:id] || STORY_ID}</id>
         <url>http://www.pivotaltracker.com/</url>
         <story_type>bug</story_type>
         <current_state>#{opts[:current_state] || "unscheduled"}</current_state>#{
      %q{<accepted_at type="datetime">2010/01/01 19:55:08 UTC</accepted_at>} if opts[:accepted]
          }
      </story>
   </stories>
</activity>
      XML
    end

    def stories(opts={})
      <<-XML
<stories type="array" filter="type:bug" count="1" total="1">
  <story>
    <id type="integer">#{opts[:id] || 12345}</id>
    <project_id type="integer">#{PROJECT_ID}</project_id>
    <story_type>bug</story_type>
    <url>http://www.pivotaltracker.com/story/show/12345</url>
    <current_state>#{opts[:current_state] || "started"}</current_state>
    <description>abc</description>
    <name>#{opts[:name] || "test"}</name>
    <requested_by>owner</requested_by>
    <owned_by>owner</owned_by>
    <created_at type="datetime">2012/06/11 17:25:47 UTC</created_at>
    <updated_at type="datetime">2012/06/13 17:21:50 UTC</updated_at>
  </story>
</stories>
      XML
    end

  end
end