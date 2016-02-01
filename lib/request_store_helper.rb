class RequestStoreHelper
  def self.store_user(current_user)
    user_hash = HashWithIndifferentAccess.new
    user_hash[:user] = { email: current_user.email, name: current_user.full_name, role: current_user.role.name, id: current_user.id,
                         entity: current_user.entity.name, entity_id: current_user.entity.id, entity_subdomain: current_user.entity.subdomain }.with_indifferent_access

    RequestStore.store[:user] = user_hash
  end

  def self.store_user_agent(request)
    user_agent = UserAgent.parse(request.env['HTTP_USER_AGENT'])
    user_agent_hash = HashWithIndifferentAccess.new
    user_agent_hash[:user_agent] = { browser: user_agent.browser, version: user_agent.version.to_s, platform: user_agent.platform }.with_indifferent_access

    RequestStore.store[:user_agent] = user_agent_hash
  end

  def self.store_session(session)
    session_hash = HashWithIndifferentAccess.new
    session_hash[:session_id] = session[:session_id]

    RequestStore.store[:session] = session_hash
  end

  def self.store_request(request)
    request_hash = HashWithIndifferentAccess.new
    request_hash[:request_id] = request.uuid

    RequestStore.store[:request] = request_hash
  end

  def self.store_request_context(current_user, session = nil, request = nil)
    if current_user
      store_user(current_user)
    end

    if session
      store_session(session)
    end

    if request
      store_request(request)
      store_user_agent(request)
    end
  end

  def self.clear_request_context
    RequestStore.clear!
  end

  def self.merge_request_context
    request_context = [RequestStore[:user], RequestStore[:session], RequestStore[:request], RequestStore[:user_agent]]
    Hash[*request_context.map(&:to_a).flatten]
  end
end
