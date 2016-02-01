class OgSession
  MOCK_SESSION = {
    id: 241,
    email: 'baggins@opengov.com',
    first_name: 'Frodo',
    last_name: 'Baggins',
    role: {
      name: 'opengov_admin'
    },
    abilities: {
      entity: {
        create: false,
        destroy: false
      },
      report: {
        create: false,
        destroy: false
      }
    },
    demote_at: nil,
    environment: 'production',
    entity: {
      id: 'controlpanel',
      name: 'OpenGov',
      address: 'Mountain View, CA',
      subdomain: 'controlpanel',
      homepage_url: 'http://www.opengov.com',
      logo: 'https://s3.amazonaws.com/delphius-rds-1/entities/logos/000/000/015/header_image/opengov-logo.png?1414256757',
      entity_id: 15,
      color: {
        color: '#bf3f3f',
        index: 0
      },
      fiscal_year_start_month: 7,
      fiscal_year_start_date_formatted: 'July 01',
      default_report_id: nil,
      budget_101: true,
      feature_permissions: [
      ],
      abilities: {
        update: false
      }
    }
  }

  API_KEY_SESSION = {
    id: -1,
    role: {
      name: 'opengov_user'
    },
    entity: {
      id: 'controlpanel',
      entity_id: 15
    }
  }

  attr_reader :entity_subdomain, :entity_id

  def initialize(options = {})
    uri = ::URI.parse(Settings.opengov_internal)

    origin = (uri.scheme ? "#{uri.scheme}://" : '//')
    origin += uri.hostname
    origin += (uri.port && uri.port != uri.default_port ? ":#{uri.port}" : '')

    if options[:mock]
      @mocked = true
      @session = MOCK_SESSION.deep_dup
    elsif options[:api_key]
      headers = { 'Authorization' => "Token token=#{options[:api_key]}" }
      Excon.head("#{origin}/api/v1/chart_of_accounts?limit=1", headers: headers, expects: [200, 204])
      @session = API_KEY_SESSION.deep_dup
    else
      cookie = options[:cookie]
      return false unless cookie
      resp = Excon.get("#{origin}/api/v1/session", headers: { 'Cookie' => cookie }, expects: [200])
      @session = MultiJson.load(resp.body).deep_symbolize_keys
    end

    @valid = true
    @origin = origin

    @session.freeze

    # User's Home Entity ID
    @entity_subdomain = self[:entity, :id]
    @entity_id = self[:entity, :entity_id]

    # OG user?
    if self[:role, :name] =~ /\Aopengov_/ && @entity_subdomain == 'controlpanel'
      @og_user = true
      @comparisons_valid = true
    end

    # Comparisons allowed?
    feature_permissions = self[:entity, :feature_permissions]
    if feature_permissions && feature_permissions.include?('comparisons')
      @comparisons_valid = true
    end
  rescue
    @valid = false
    @og_user = false
    @comparisons_valid = false
  end

  def [](*args)
    args.inject(@session) { |memo, arg| memo[arg.to_sym] } # rubocop:disable SingleLineBlockParams
  rescue NoMethodError
    nil
  end

  def can_view?(params)
    return true if @og_user

    return params[:entity_subdomain] == entity_subdomain if params[:entity_subdomain]
    return params[:entity_id] == entity_id if params[:entity_id]

    false
  end

  def valid?
    @valid
  end

  def og_user?
    @og_user
  end

  def comparisons?
    @comparisons_valid
  end
end
