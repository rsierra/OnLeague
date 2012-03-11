# RailsAdmin config file. Generated on March 02, 2012 18:04
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|

  # If your default_local is different from :en, uncomment the following 2 lines and set your default locale here:
  require 'i18n'
  I18n.default_locale = :es

  config.current_user_method { current_admin } # auto-generated

  # If you want to track changes on your models:
  config.audit_with :history, Admin

  # Or with a PaperTrail: (you need to install it first)

  # Set the admin name here (optional second array element will appear in a beautiful RailsAdmin red ©)
  config.main_app_name = ['onLeague', 'Admin']
  # or for a dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  config.authorize_with :cancan

  #  ==> Global show view settings
  # Display empty fields in show views
  # config.compact_show_view = false

  #  ==> Global list view settings
  # Number of default rows per-page:
  # config.default_items_per_page = 20

  #  ==> Included models
  # Add all excluded models here:
  # config.excluded_models = [Admin, OauthProvider, User]

  # Add models here if you want to go 'whitelist mode':
  config.included_models = [User, OauthProvider, League]

  # Application wide tried label methods for models' instances
  # config.label_methods << :description # Default is [:name, :title]

  #  ==> Global models configuration
  # config.models do
  #   # Configuration here will affect all included models in all scopes, handle with care!
  #
  #   list do
  #     # Configuration here will affect all included models in list sections (same for show, export, edit, update, create)
  #
  #     fields_of_type :date do
  #       # Configuration here will affect all date fields, in the list section, for all included models. See README for a comprehensive type list.
  #     end
  #   end
  # end
  #
  #  ==> Model specific configuration
  # Keep in mind that *all* configuration blocks are optional.
  # RailsAdmin will try his best to provide the best defaults for each section, for each field.
  # Try to override as few things as possible, in the most generic way. Try to avoid setting labels for models and attributes, use ActiveRecord I18n API instead.
  # Less code is better code!
  # config.model MyModel do
  #   # Cross-section field configuration
  #   object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #   label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #   label_plural 'My models'      # Same, plural
  #   weight -1                     # Navigation priority. Bigger is higher.
  #   parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #   navigation_label              # Sets dropdown entry's name in navigation. Only for parents!
  #   # Section specific configuration:
  #   list do
  #     filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #     items_per_page 100    # Override default_items_per_page
  #     sort_by :id           # Sort column (default is primary key)
  #     sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     # Here goes the fields configuration for the list view
  #   end
  # end



  # Your model's configuration, to help you get started:

  # All fields marked as 'hidden' won't be shown anywhere in the rails_admin unless you mark them as visible. (visible(true))

  config.model OauthProvider do
    parent User
    object_label_method :provider

    # Found associations:
    configure :user, :belongs_to_association
    # Found columns:
    configure :id, :integer
    configure :provider, :string
    configure :uid, :string
    configure :uname, :string
    configure :uemail, :string
    configure :user_id, :integer
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      field :provider
      field :user
      field :uname
      field :uemail
      field :uid

      filters [:provider, :user, :uname, :uemail]
    end
    export do; end
    show do
      field :provider
      field :user
      field :uname
      field :uemail
      field :uid
      field :created_at do
        visible true
      end
    end
    edit do; end
    create do; end
    update do; end
  end

  config.model User do
    object_label_method :name

    # Found associations:
    configure :oauth_providers, :has_many_association
    # Found columns:
    configure :id, :integer
    configure :email, :string
    configure :password, :password
    configure :password_confirmation, :password
    configure :reset_password_token, :string
    configure :reset_password_sent_at, :datetime
    configure :remember_created_at, :datetime
    configure :sign_in_count, :integer
    configure :current_sign_in_at, :datetime
    configure :last_sign_in_at, :datetime
    configure :current_sign_in_ip, :string
    configure :last_sign_in_ip, :string
    configure :confirmation_token, :string
    configure :confirmed_at, :datetime
    configure :confirmation_sent_at, :datetime
    configure :unconfirmed_email, :string
    configure :failed_attempts, :integer
    configure :unlock_token, :string
    configure :locked_at, :datetime
    configure :created_at, :datetime
    configure :updated_at, :datetime
    configure :name, :string

    # Sections:
    list do
      field :name
      field :email
      field :sign_in_count
      field :failed_attempts
      field :created_at do
        visible true
      end

      filters [:name, :email]
    end
    export do; end
    show do
      field :name
      field :email
      field :oauth_providers
      field :sign_in_count
      field :failed_attempts
      field :current_sign_in_at
      field :current_sign_in_ip
      field :last_sign_in_at
      field :last_sign_in_ip
      field :confirmed_at
      field :locked_at
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do
      field :name
      field :email
      field :password
      field :password_confirmation
    end
    create do; end
    update do; end
  end

  config.model League do
    object_label_method :name

    # Found columns:
    configure :id, :integer
    configure :name, :string
    configure :week, :integer
    configure :season, :integer
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      field :name
      field :week
      field :season

      filters [:name]
    end
    export do; end
    show do
      field :name
      field :week
      field :season
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do; end
    create do; end
    update do; end
  end
end
