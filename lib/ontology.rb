module Ontology
  ONT_API = Settings.ontology_internal + '/clusters/municipalities/trees'

  module_function

  def api_client
    @api_client ||= OpenGov::Client.new
  end

  def match_nodes(breakdown_type, params)
    request_body = { strict: false, list_hierarchy: false }.merge(params)
    url = "#{ONT_API}/#{breakdown_type}/match-nodes"
    resp = api_client.post(url, expects: [200],
                                headers: { 'Content-Type' => 'application/json' },
                                body: MultiJson.dump(request_body))

    { 'matches' => [], 'unmatched' => [] }.merge(resp.body)
  end
end
