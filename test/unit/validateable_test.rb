require 'test_helper'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class Dood
      include ActiveMerchant::Validateable

      attr_accessor :name, :email, :country

      def validate
        errors.add "name", :empty if name.blank?
        errors.add "email", "cannot be empty" if email.blank?
        errors.add_to_base "The country cannot be blank" if country.blank?
      end
    end
  end
end

class ValidateableTest < Test::Unit::TestCase
  include ActiveMerchant

  def setup
    @dood = Dood.new
    @current_locale = I18n.locale
  end

  def teardown
    I18n.locale = @current_locale
  end

  def test_validation
    assert ! @dood.valid?
    assert ! @dood.errors.empty?
  end

  def test_assigns
    @dood = Dood.new(:name => "tobi", :email => "tobi@neech.de", :country => 'DE')

    assert_equal "tobi", @dood.name
    assert_equal "tobi@neech.de", @dood.email
    assert @dood.valid?
  end

  def test_multiple_calls
    @dood.name = "tobi"
    assert !@dood.valid?

    @dood.email = "tobi@neech.de"
    assert !@dood.valid?

    @dood.country = 'DE'
    assert @dood.valid?
  end

  def test_messages
    @dood.valid?
    assert_equal "cannot be empty", @dood.errors.on('name')
    assert_equal "cannot be empty", @dood.errors.on('email')
    assert_equal nil, @dood.errors.on('doesnt_exist')

  end

  def test_full_messages
    @dood.valid?
    assert_equal ["Email cannot be empty", "Name cannot be empty", "The country cannot be blank"], @dood.errors.full_messages.sort
  end

  def test_default_error_messages_for_blank
    @dood.errors.add(:name, :blank)
    assert_equal "cannot be blank", @dood.errors.on(:name)
  end

  def test_default_error_messages_for_empty
    @dood.errors.add(:name, :empty)
    assert_equal "cannot be empty", @dood.errors.on(:name)
  end

  def test_default_error_messages_for_invalid
    @dood.errors.add(:name, :invalid)
    assert_equal "is invalid", @dood.errors.on(:name)
  end

  def test_default_error_messages_for_required
    @dood.errors.add(:name, :required)
    assert_equal "is required", @dood.errors.on(:name)
  end

  def test_error_message_for_blank_with_translation
    I18n.backend.store_translations :en, :active_merchant => {:errors => {:blank => "blank is invalid"}}
    I18n.backend.store_translations :pt, :active_merchant => {:errors => {:blank => "deve ser preenchido"}}

    @dood.errors.add(:name, :blank)
    assert_equal "blank is invalid", @dood.errors.on(:name)

    I18n.locale = :pt

    @dood.errors.clear
    @dood.errors.add(:name, :blank)
    assert_equal "deve ser preenchido", @dood.errors.on(:name)
  end

  def test_error_message_translated_using_priority_order
    I18n.backend.store_translations :pt, :active_merchant => {:billing => { :dood => {:errors => {:blank => "nunca deve estar em branco"}}}}

    I18n.locale = :pt
    @dood.errors.clear
    @dood.errors.add(:name, :blank)
    assert_equal "nunca deve estar em branco", @dood.errors.on(:name)
  end
end
