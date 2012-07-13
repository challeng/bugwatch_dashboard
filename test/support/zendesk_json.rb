class ZendeskJson

  class << self

    def tickets(opts={})
      <<-JSON
{
   "tickets":[
      {
         "url":"https://subdomain.zendesk.com/api/v2/tickets/2.json",
         "id":#{opts[:id] || 2},
         "external_id":null,
         "via":{
            "channel":"web"
         },
         "created_at": "#{opts[:created_at] || "2012-06-06T19:07:14Z"}",
         "updated_at":"2012-06-18T18:33:19Z",
         "type":"#{opts[:type] || "problem"}",
         "subject":"#{opts[:subject] || "Issue with something"}",
         "description":"fix it!",
         "priority":"#{opts[:priority] || "urgent"}",
         "status":"#{opts[:status] || "closed"}",
         "recipient":null,
         "requester_id":222455098,
         "submitter_id":222455098,
         "assignee_id":222455098,
         "organization_id":21812768,
         "group_id":20258648,
         "collaborator_ids":[],
         "forum_topic_id":null,
         "problem_id":null,
         "has_incidents":false,
         "due_at":null,
         "tags":[],
         "fields":[]
      }
   ],
   "next_page":null,
   "previous_page":null,
   "count":1
}
      JSON
    end

  end

end