module Worthwhile
  #  To use this module, include it in your Actor class
  #  and then add its interpreters wherever you want them to run.
  #  They should be called _before_ apply_attributes is called because
  #  they intercept values in the attributes Hash.
  #
  #  @example
  #  class MyActorClass < BaseActor
  #     include Worthwile::ManagesEmbargoesActor
  #
  #     def create
  #       interpret_visibility && super
  #     end
  #
  #     def update
  #       interpret_visibility && super
  #     end
  #  end
  #
  module ManagesEmbargoesActor
    extend ActiveSupport::Concern

    # Interprets embargo & lease visibility if necessary
    # returns false if there are any errors
    def interpret_visibility
      interpret_embargo_visibility && interpret_lease_visibility
    end

    # If user has set visibility to embargo, interprets the relevant information and applies it
    # Returns false if there are any errors and sets an error on the curation_concern
    def interpret_embargo_visibility
      # clear embargo_release_date even if it isn't being used. Otherwise it sets the embargo_date
      # even though they didn't select embargo on the form.
      date = attributes.delete(:embargo_release_date)
      if attributes[:visibility] != Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
        # Remove the embargo visibility so it doesn't get set later in the chain
        attributes.delete(:visibility_during_embargo)
        attributes.delete(:visibility_after_embargo)
        true
      elsif !date
        curation_concern.errors.add(:visibility, 'When setting visibility to "embargo" you must also specify embargo release date.')
        false
      else
        attributes.delete(:visibility)
        curation_concern.apply_embargo(date, attributes.delete(:visibility_during_embargo),
                                       attributes.delete(:visibility_after_embargo))
        true
      end
    end

    # If user has set visibility to lease, interprets the relevant information and applies it
    # Returns false if there are any errors and sets an error on the curation_concern
    def interpret_lease_visibility
      # clear lease_expiration_date even if it isn't being used. Otherwise it sets the lease_expiration 
      # even though they didn't select lease on the form.
      date = attributes.delete(:lease_expiration_date)
      if attributes[:visibility] != Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE
        # Remove the lease visibility so it doesn't get set later in the chain
        attributes.delete(:visibility_during_lease)
        attributes.delete(:visibility_after_lease)
        true
      elsif !date
        curation_concern.errors.add(:visibility, 'When setting visibility to "lease" you must also specify lease expiration date.')
        false
      else
        curation_concern.apply_lease(date, attributes.delete(:visibility_during_lease),
                                       attributes.delete(:visibility_after_lease))
        attributes.delete(:visibility)
        true
      end
    end

    # def apply_embargo_visibility(assets)
    #   response = {}
    #   Array(assets).each do |asset|
    #     response[asset.pid] = asset.apply_embargo_visibility!
    #   end
    #   response
    # end

    # def apply_lease_visibility(assets)
    #   response = {}
    #   Array(assets).each do |asset|
    #     response[asset.pid] = asset.apply_lease_visibility!
    #   end
    #   response
    # end
  end
end
