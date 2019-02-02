# frozen_string_literal: true

require 'wings/active_fedora_converter'

module Wings
  module Valkyrie
    module Postgres
      class ResourceFactory < ::Valkyrie::Persistence::Postgres::ResourceFactory
        # @return [ActiveFedora::Base] ActiveFedora
        #   resource for the Valkyrie resource.
        def from_resource(resource:)
          Wings::ActiveFedoraConverter.new(resource: resource).convert
        end
      end
    end
  end
end
