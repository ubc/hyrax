# frozen_string_literal: true

module Wings
  module Valkyrie
    module Postgres
      class MetadataAdapter < ::Valkyrie::Persistence::Postgres::MetadataAdapter
        # @return [Valkyrie::ID] Identifier for this metadata adapter.
        def id
          @id ||= begin
            to_hash = "wings_postgres"
            ::Valkyrie::ID.new(Digest::MD5.hexdigest(to_hash))
          end
        end

        # @return [Class] {Wings::Valkyrie::Postgres::ResourceFactory}
        def resource_factory
          @resource_factory ||= Wings::Valkyrie::Postgres::ResourceFactory.new(adapter: self)
        end
      end
    end
  end
end
