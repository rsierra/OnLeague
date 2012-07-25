require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminCloseWeek
end

module RailsAdmin
  module Config
    module Actions
      class CloseWeek < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-check'
        end

        register_instance_option :controller do
          Proc.new do
            flash[:notice] = "Week closed"

            redirect_to back_or_index
          end
        end
      end
    end
  end
end
