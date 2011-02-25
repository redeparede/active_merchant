module ActiveMerchant #:nodoc:
  module Validateable #:nodoc:
    def valid?
      errors.clear

      before_validate if respond_to?(:before_validate, true)
      validate if respond_to?(:validate, true)

      errors.empty?
    end

    def initialize(attributes = {})
      self.attributes = attributes
    end

    def errors
      @errors ||= Errors.new(self)
    end

    private

    def attributes=(attributes)
      unless attributes.nil?
        for key, value in attributes
          send("#{key}=", value )
        end
      end
    end

    # This hash keeps the errors of the object
    class Errors < HashWithIndifferentAccess

      DEFAULT_ERROR_MESSAGES = {
        :blank => "cannot be blank",
        :empty => "cannot be empty",
        :invalid => "is invalid",
        :required => "is required"
      }

      def initialize(base)
        @base = base
      end

      def count
        size
      end

      # returns a specific fields error message.
      # if more than one error is available we will only return the first. If no error is available
      # we return an empty string
      def on(field)
        self[field].to_a.first
      end

      def add(field, error)
        self[field] ||= []
        self[field] << message_error(error)
      end

      def add_to_base(error)
        add(:base, error)
      end

      def each_full
        full_messages.each { |msg| yield msg }
      end

      def full_messages
        result = []

        self.each do |key, messages|
          if key == 'base'
            result << "#{messages.first}"
          else
            result << "#{key.to_s.humanize} #{messages.first}"
          end
        end

        result
      end

      private
      # returns a specific message error for <tt>error</tt> attribute
      # <tt>error</tt>: A string message or symbol. If it is a string,
      # returns it as message error. If it is a symbol, try to use it
      # as a key on I18n.translation with specific scope from class or
      # "active_merchant.errors" as default. If translation not exist,
      # use DEFAULT_ERROR_MESSAGES messages or stringify the symbol and
      # use it as message error
      #
      # E.g:
      #   # on ActiveMerchant::Billing::CreditCard model
      #   some_credit_card_instance.errors.add(:number, :invalid)
      #
      # That will try to get message:
      # 1) on I18n translations by key: active_merchant.billing.credit_card.errors.invalid
      # 2) on I18n translations by key: with key active_merchant.errors.invalid
      # 3) DEFAULT_ERROR_MESSAGES[invalid]
      # 4) So, :invalid.to_s.humanize.downcase
      def message_error(error)
        return error if error.is_a?(String)
        klass = @base.class.name.gsub("::", ".").underscore.downcase
        default_message_error = I18n.t(error, :scope => "active_merchant.errors", :default => DEFAULT_ERROR_MESSAGES[error] || error.to_s.humanize.downcase)
        I18n.t(error, :scope => "#{klass}.errors", :default => default_message_error)
      end
    end
  end
end