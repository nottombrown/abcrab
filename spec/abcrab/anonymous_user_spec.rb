require 'spec_helper'
AnonymousUser = Abcrab::AnonymousUser

describe AnonymousUser do


  describe 'abc_test' do
    it 'should sample a value if there was nothing previous' do
      user = AnonymousUser.new({},{})
      value = user.abc_test('mohawk', ["awesome"])
      value.should == 'awesome'

    end
    it 'should not overwrite an existing value' do
      user = AnonymousUser.new({},{})
      user.abc_test('mohawk', ["awesome"])

      # Try to overwrite the value
      value = user.abc_test('mohawk', ["lame"])
      value.should == 'awesome'
    end

    it 'should add the value to mixpanel_hash' do
      user = AnonymousUser.new({},{})
      value = user.abc_test('mohawk', ["awesome"])

      user.mixpanel_hash['abc_mohawk'].should == 'awesome'
    end

  end

  describe 'mixpanel tracking' do
    it 'should create a mixpanel_guid and persist it to the session' do
      user = AnonymousUser.new({},{})
      user.session['mixpanel_guid'].should be
    end
  end


  describe 'Member#update_from_anonymous_user' do
    it 'should add empty strings' do
      @member = create(:member)
      @anon_user = AnonymousUser.new({}, {})
      @member.update_from_anonymous_user(@anon_user)
      # @member.utm_source.should == ''
    end

    it 'should add all the source fields' do
      @member = create(:member)
      @anon_user = AnonymousUser.new({}, {
        'utm_source' => "barstoolsports",
      })
      @member.update_from_anonymous_user(@anon_user)

      @anon_user.session['utm_source'].should == 'barstoolsports'
      @anon_user.source_attributes['utm_source'].should == 'barstoolsports'
      @member.utm_source.should == 'barstoolsports'
    end
  end

  describe '#initialize' do
    it 'should set source fields to '' if they are not included in params' do
      session = {}
      params = {
        'utm_source' => "google",
      }
      user = AnonymousUser.new(session, params)
      user.session['utm_campaign'].should == '' # not nil
    end

    it 'should not overwrite session after created' do
      session = {
        'utm_source' => "facebook",
      }
      params = {
        'utm_source' => "google",
      }
      user = AnonymousUser.new(session, params)
      user.session['utm_source'].should == 'facebook' # not "google"
    end

    it 'should not overwrite empty string params after created' do
      session = {
        'utm_source' => "",
      }
      params = {
        'utm_source' => "facebook",
      }
      user = AnonymousUser.new(session, params)
      user.session['utm_source'].should == "" # not "facebook"
    end

    it 'should not add non-source related session values to the session' do
      session = {}
      params = {
        'utm_source' => "facebook",
        'cool_beans' => "crazy",
      }

      user = AnonymousUser.new(session, params)
      user.session['cool_beans'].should == nil
    end


    it 'should not change non-source related session values if we dont add anything' do
      session = {
        'cool_beans' => "do_not_change",
        }
      params = {}

      user = AnonymousUser.new(session, params)
      user.session['cool_beans'].should == 'do_not_change'
    end

    it 'should not change non-source related session values' do
      session = {
        'cool_beans' => "do_not_change",
        }
      params = {
        'cool_beans' => "omg_changed",
      }

      user = AnonymousUser.new(session, params)
      user.session['cool_beans'].should == 'do_not_change'
    end
  end
end

