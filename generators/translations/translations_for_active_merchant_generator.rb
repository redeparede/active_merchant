class TranslationsForActiveMerchantGenerator < Rails::Generator::Base
  LOCALE_DIR = "config/locales/"

  def manifest
    record do |m|
      m.directory LOCALE_DIR
      m.file LOCALE_DIR + 'active_merchant_en.yml', LOCALE_DIR + "active_merchant_en.yml"
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name}"
    end
end
