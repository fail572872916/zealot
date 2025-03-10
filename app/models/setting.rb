# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  extend ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::TranslationHelper

  before_save   :convert_third_party_enabled_value, if: :third_party_auth_scope?
  before_save   :mark_restart_flag, if: :need_restart?

  cache_prefix { 'v2' }

  REPO_URL = 'https://github.com/tryzealot/zealot'

  class << self
    def present_schemes
      [
        t('settings.default_schemes.beta', default: nil),
        t('settings.default_schemes.adhoc', default: nil),
        t('settings.default_schemes.production', default: nil)
      ].compact
    end

    def present_roles
      {
        user: t('settings.default_role.user', default: nil),
        developer: t('settings.default_role.developer', default: nil),
        admin: t('settings.default_role.admin', default: nil)
      }
    end

    def site_https
      Rails.env.production? || ENV['ZEALOT_USE_HTTPS'].present?
    end

    def site_configs
      group_configs.each_with_object({}) do |(scope, items), obj|
        obj[scope] = items.each_with_object({}) do |item, inner|
          key = item[:key]
          value = send(key.to_sym)
          inner[key] = {
            value: value,
            readonly: item[:readonly]
          }
        end
      end
    end

    def need_restart?
      Rails.configuration.x.restart_required == true
    end

    def restart_required!
      Rails.configuration.x.restart_required = true
    end

    def clear_restart_flag!
      Rails.configuration.x.restart_required = false
    end

    def find_or_default(var:)
      find_by(var: var) || new(var: var)
    end

    def group_configs
      defined_fields.select { |v| v[:options][:display] == true }.group_by { |v| v[:scope] || :misc }
    end

    def host
      "#{protocol}#{site_domain}"
    end

    def protocol
      site_https ? 'https://' : 'http://'
    end

    def url_options
      {
        host: site_domain,
        protocol: protocol,
        trailing_slash: false
      }
    end

    def repo_url
      REPO_URL
    end

    def default_domain
      site_https ? 'localhost' : "localhost:#{ENV['ZEALOT_PORT'] || 3000}"
    end
  end

  # 系统配置
  scope :general do
    field :site_title, default: 'Zealot', type: :string, display: true,
          validates: { presence: true, length: { in: 3..16 } }
    field :site_domain, default: (ENV['ZEALOT_DOMAIN'] || default_domain), type: :string,
          restart_required: true, display: true
    field :site_locale, default: Rails.configuration.i18n.default_locale.to_s, type: :string, display: true,
          validates: { presence: true, inclusion: { in: Rails.configuration.i18n.available_locales.map(&:to_s) } }
    field :site_https, default: site_https, type: :boolean, readonly: true, display: true

    field :admin_email, default: (ENV['ZEALOT_ADMIN_EMAIL'] || 'admin@zealot.com'), type: :string, readonly: true
    field :admin_password, default: (ENV['ZEALOT_ADMIN_PASSWORD'] || 'ze@l0t'), type: :string, readonly: true
  end

  # 预值
  scope :presets do
    field :default_schemes, default: present_schemes, type: :array, display: true
    field :default_role, default: 'user', type: :string, display: true,
          validates: { presence: true, inclusion: { in: present_roles.keys.map(&:to_s) } }
  end

  # 模式开关
  scope :switch_mode do
    field :registrations_mode, default: ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_REGISTER_ENABLED'] || 'true'),
          type: :boolean, display: true
    field :guest_mode, default: ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_GUEST_MODE'] || 'false'),
          type: :boolean, restart_required: true, display: true
    field :keep_uploads, default: ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_KEEP_UPLOADS'] || 'true'),
          type: :boolean, restart_required: true, display: true
    field :demo_mode, default: ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_DEMO_MODE'] || 'false'),
          type: :boolean, readonly: true, display: true
  end

  # 第三方登录
  scope :third_party_auth do
    field :feishu, type: :hash, display: true, restart_required: true, default: {
      enabled: ActiveModel::Type::Boolean.new.cast(ENV['FEISHU_ENABLED'] || false),
      app_id: ENV['FEISHU_APP_ID'],
      app_secret: ENV['FEISHU_APP_SECRET'],
    }

    field :gitlab, type: :hash, display: true, restart_required: true, default: {
      enabled: ActiveModel::Type::Boolean.new.cast(ENV['GITLAB_ENABLED'] || false),
      site: ENV['GITLAB_SITE'] || 'https://gitlab.com/api/v4',
      scope: ENV['GITLAB_SCOPE'] || 'read_user',
      app_id: ENV['GITLAB_APP_ID'],
      secret: ENV['GITLAB_SECRET'],
    }

    field :google_oauth, type: :hash, display: true, restart_required: true, default: {
      enabled: ActiveModel::Type::Boolean.new.cast(ENV['GOOGLE_OAUTH_ENABLED'] || false),
      client_id: ENV['GOOGLE_CLIENT_ID'],
      secret: ENV['GOOGLE_SECRET'],
    }

    field :ldap, type: :hash, display: true, restart_required: true, default: {
      enabled: ActiveModel::Type::Boolean.new.cast(ENV['LDAP_ENABLED'] || false),
      host: ENV['LDAP_HOST'],
      port: ENV['LDAP_PORT'] || '389',
      encryption: ENV['LDAP_METHOD'] || ENV['LDAP_ENCRYPTION'] || 'plain', # LDAP_METHOD will be abandon in the future
      bind_dn: ENV['LDAP_BIND_DN'],
      password: ENV['LDAP_PASSWORD'],
      base: ENV['LDAP_BASE'],
      uid: ENV['LDAP_UID'] || 'sAMAccountName'
    }
  end

  # 邮件配置
  scope :stmp do
    field :mailer_default_from, default: ENV['ACTION_MAILER_DEFAULT_FROM'], type: :string,
          restart_required: true, display: true
    field :mailer_default_to, default: ENV['ACTION_MAILER_DEFAULT_TO'], type: :string,
          restart_required: true, display: true
    field :mailer_options, type: :hash, restart_required: true, display: true, default: {
      address: ENV['SMTP_ADDRESS'],
      port: ENV['SMTP_PORT'].to_i,
      domain: ENV['SMTP_DOMAIN'],
      username: ENV['SMTP_USERNAME'],
      password: ENV['SMTP_PASSWORD'],
      auth_method: ENV['SMTP_AUTH_METHOD'],
      enable_starttls_auto: ActiveModel::Type::Boolean.new.cast(ENV['SMTP_ENABLE_STARTTLS_AUTO']),
    }
  end

  # 备份
  field :backup, type: :hash, readonly: true, default: {
    path: 'public/backup',
    keep_time: 604800,
    pg_schema: 'public',
  }

  # 版本信息（只读）
  scope :information do
    field :version, default: (ENV['ZEALOT_VERSION'] || 'development'), type: :string, readonly: true
    field :vcs_ref, default: (ENV['ZEALOT_VCS_REF'] || ENV['HEROKU_SLUG_COMMIT']), type: :string, readonly: true
    field :build_date, default: ENV['ZEALOT_BUILD_DATE'], type: :string, readonly: true
  end

  # 统计
  scope :analytics do
    field :google_analytics_id, default: ENV['GOOGLE_ANALYTICS_ID'], type: :string, display: true
  end

  def readonly?
    self.class.get_field(var.to_sym).try(:[], :readonly) === true
  end

  def field_validates
    validates.each_with_object([]) do |validate, obj|
      next unless value = validate_value(validate)

      obj << value
    end
  end

  def inclusion?
    inclusions = validates.select {|v| v.is_a?(ActiveModel::Validations::InclusionValidator) }
    inclusions&.first
  end

  def inclusion_values
    return unless inclusion = inclusion?

    delimiters = inclusion.send(:delimiter)
    delimiters = delimiters.call if delimiters.respond_to?(:call)
    delimiters.each_with_object({}) do |value, obj|
      key = t("settings.#{var}.#{value}", default: value)
      obj[key] = value
    end
  end

  def default_value
    present[:default]
  end

  def type
    present[:type]
  end

  def validates
    @validates ||= self.class.validators_on(var)
  end

  def present
    @present ||= self.class.get_field(var)
  end

  private

  def mark_restart_flag
    self.class.restart_required!
  end

  def need_restart?
    value_of(var, source: :restart_required) == true
  end

  def convert_third_party_enabled_value
    new_value = value.dup
    new_value['enabled'] = ActiveModel::Type::Boolean.new.cast(value['enabled'])
    self.value = new_value
  end

  def validate_value(validate)
    case validate
    when ActiveModel::Validations::PresenceValidator
      t('errors.messages.blank')
    when ActiveRecord::Validations::LengthValidator
      minimum = validate.options[:minimum]
      maximum = validate.options[:maximum]
      t('errors.messages.length_range', minimum: minimum, maximum: maximum)
    when ActiveModel::Validations::InclusionValidator
      t('errors.messages.optional_value', value: inclusion_values.values.join(', '))
    end
  end

  def third_party_auth_scope?
    value_of(var, source: :scope) == :third_party_auth
  end

  def value_of(key, source:)
    scope = Setting.defined_fields
                   .select { |s| s[:key] == key }
                   .map { |s| s[source] || s[:options][source] }

    scope.any? ? scope.first : false
  end
end
