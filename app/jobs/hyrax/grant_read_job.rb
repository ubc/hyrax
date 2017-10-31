module Hyrax
  # Grants the user's read access on the provided FileSet
  class GrantReadJob < ApplicationJob
    queue_as Hyrax.config.ingest_queue_name

    # @param [String] file_set_id - the identifier of the object to grant access to
    # @param [String] user_key - the user to add
    def perform(file_set_id, user_key)
      file_set = Queries.find_by(id: file_set_id)
      file_set.read_users += [user_key]
      persister.save(resource: file_set)
    end
  end
end
