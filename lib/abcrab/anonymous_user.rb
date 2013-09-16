module Abcrab
  class AnonymousUser
    SOURCE_FIELDS = [
      'utm_source',
      'utm_campaign',
      'utm_medium',
      'utm_term',
      'utm_content',
      'referring_url',
      'referring_domain',
      'first_controller',
    ] if not defined? SOURCE_FIELDS

    # Either takes the relevant fields from the session or initializes from
    # parameters.
    #
    # Once the session is set, we won't modify it again
    def initialize(session, params)
      @session = session
      # Set up all non-included fields to be the empty string
      param_fields_with_default = SOURCE_FIELDS.inject({}) do |obj, field|
        obj[field] = (params[field] || '')
        obj
      end
      
      # Set up mixpanel_guid
      @session['mixpanel_guid'] ||= (params['mixpanel_guid'] || SecureRandom.uuid)
      @session.reverse_merge!(param_fields_with_default)
    end

    def session
      @session
    end

    def mixpanel_guid
      @session['mixpanel_guid']
    end

    def source_attributes
      fields = SOURCE_FIELDS.map(&:to_s)
      @session.to_hash.slice(*fields)
    end

    # A/B testing
    #
    #
    #

    # Run an abc_test and persist the value to the session
    def abc_test(name, options)

      mp_name = "abc_#{name}"
      # Add it to @session['experiments'] which will be registered with mixpanel in every subsequent track_event and will get pushed into
      option = options.sample

      # Only overwrite if there was nothing before
      experiments_hash[mp_name] ||= option
    end


    # Mixpanel tracking
    #
    #
    #

    # Asynchronously tracks the event
    #
    def track_event(name, event_properties={})
      MixpanelJob.track(name, event_properties, mixpanel_hash, experiments_hash)
    end

    # Mixpanel needs a 'distinct_id' attribute in order to persist correctly
    def mixpanel_hash
      source_attributes.merge(
        'distinct_id' => mixpanel_guid,
        'state' => 'anonymous_user',
      ).merge(experiments_hash)
    end

    def experiments_hash
      @session['experiments'] ||= {}
      @session['experiments']
    end

  end



end